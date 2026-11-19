import { requireClient } from './supabase.js';

const ROOM_COLUMNS = [
    'id', 'code', 'host_id', 'guest_id', 'host_nickname', 'guest_nickname',
    'status', 'map_seeds', 'red_base_id', 'blue_base_id', 'state',
    'last_action', 'result', 'version', 'winner',
    'created_at', 'updated_at', 'finished_at'
].join(', ');

const CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
let roomChannel = null;

function rpcError(error) {
    return new Error((error && (error.message || error.details || error.hint)) || '联机请求失败');
}

function unwrap(result) {
    if (result.error) throw rpcError(result.error);
    return result.data;
}

export function generateRoomCode(length = 6) {
    const bytes = new Uint8Array(length);
    if (window.crypto && window.crypto.getRandomValues) {
        window.crypto.getRandomValues(bytes);
    } else {
        for (let i = 0; i < length; i++) bytes[i] = Math.floor(Math.random() * 256);
    }
    return Array.from(bytes, byte => CODE_ALPHABET[byte % CODE_ALPHABET.length]).join('');
}

export async function createRoom({ mapSeeds, nickname }) {
    const client = requireClient();
    const { data: userData, error: userError } = await client.auth.getUser();
    if (userError || !userData?.user) throw new Error('请先登录');
    const hostId = userData.user.id;

    for (let attempt = 0; attempt < 6; attempt++) {
        const code = generateRoomCode();
        const result = await client
            .from('tree_grow_rooms')
            .insert({
                code,
                host_id: hostId,
                host_nickname: nickname || '房主',
                status: 'waiting',
                map_seeds: mapSeeds
            })
            .select(ROOM_COLUMNS)
            .single();

        if (!result.error) return result.data;
        if (result.error.code !== '23505') throw rpcError(result.error);
    }
    throw new Error('房间码生成失败，请重试');
}

export async function joinRoomByCode(code) {
    const client = requireClient();
    const result = await client.rpc('tree_grow_join_room', { p_code: String(code || '').trim().toUpperCase() });
    if (result.error) throw rpcError(result.error);
    return Array.isArray(result.data) ? result.data[0] : result.data;
}

export async function getRoom(roomId) {
    const client = requireClient();
    const result = await client
        .from('tree_grow_rooms')
        .select(ROOM_COLUMNS)
        .eq('id', roomId)
        .maybeSingle();
    if (result.error) throw rpcError(result.error);
    return result.data || null;
}

export async function listWaitingRooms(limit = 20) {
    const client = requireClient();
    const since = new Date(Date.now() - 30 * 60 * 1000).toISOString();
    const result = await client
        .from('tree_grow_rooms')
        .select('id, code, host_nickname, created_at')
        .eq('status', 'waiting')
        .gte('created_at', since)
        .order('created_at', { ascending: false })
        .limit(limit);
    if (result.error) throw rpcError(result.error);
    return result.data || [];
}

export async function setBase(roomId, areaId) {
    const client = requireClient();
    const result = await client.rpc('tree_grow_set_base', {
        p_room_id: roomId,
        p_area_id: areaId
    });
    if (result.error) throw rpcError(result.error);
    return Array.isArray(result.data) ? result.data[0] : result.data;
}

export async function syncState(roomId, state, version, lastAction) {
    const client = requireClient();
    const result = await client.rpc('tree_grow_sync_state', {
        p_room_id: roomId,
        p_state: state,
        p_version: version,
        p_last_action: lastAction || null
    });
    if (result.error) throw rpcError(result.error);
    return Array.isArray(result.data) ? result.data[0] : result.data;
}

export async function submitIntent(roomId, seq, payload) {
    const client = requireClient();
    const result = await client.rpc('tree_grow_submit_intent', {
        p_room_id: roomId,
        p_seq: seq,
        p_payload: payload
    });
    if (result.error) throw rpcError(result.error);
}

export async function finishRoom(roomId, { winner, state, lastAction, result }) {
    const client = requireClient();
    const rpc = await client.rpc('tree_grow_finish_room', {
        p_room_id: roomId,
        p_winner: winner,
        p_state: state || null,
        p_last_action: lastAction || null,
        p_result: result || null
    });
    if (rpc.error) throw rpcError(rpc.error);
}

export async function leaveRoom(roomId) {
    const client = requireClient();
    const result = await client.rpc('tree_grow_leave_room', { p_room_id: roomId });
    if (result.error) throw rpcError(result.error);
}

export async function fetchActions(roomId, afterSeq = 0) {
    const client = requireClient();
    const result = await client
        .from('tree_grow_actions')
        .select('id, actor_id, seq, payload, created_at')
        .eq('room_id', roomId)
        .gt('seq', afterSeq)
        .order('seq', { ascending: true })
        .limit(50);
    if (result.error) throw rpcError(result.error);
    return result.data || [];
}

/** 订阅房间与行动变化。Realtime 未开启时静默失败，由调用方轮询兜底。 */
export function subscribeRoom(roomId, { onRoom, onAction } = {}) {
    const client = requireClient();
    unsubscribeRoom();
    try {
        roomChannel = client
            .channel('tree-grow-room-' + roomId)
            .on('postgres_changes', {
                event: 'UPDATE',
                schema: 'public',
                table: 'tree_grow_rooms',
                filter: 'id=eq.' + roomId
            }, payload => { if (onRoom && payload.new) onRoom(payload.new); })
            .on('postgres_changes', {
                event: 'INSERT',
                schema: 'public',
                table: 'tree_grow_actions',
                filter: 'room_id=eq.' + roomId
            }, payload => { if (onAction && payload.new) onAction(payload.new); })
            .subscribe(status => {
                if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
                    console.warn('[TreeGrow] Realtime 订阅未建立，改用轮询');
                }
            });
    } catch (error) {
        console.warn('[TreeGrow] Realtime 订阅失败', error);
        roomChannel = null;
    }
    return roomChannel;
}

export function unsubscribeRoom() {
    if (!roomChannel) return;
    try {
        const client = requireClient();
        client.removeChannel(roomChannel);
    } catch (error) {
        console.warn('[TreeGrow] 取消订阅失败', error);
    }
    roomChannel = null;
}
