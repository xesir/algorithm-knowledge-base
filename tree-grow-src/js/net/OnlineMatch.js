import * as Rooms from './RoomService.js';
import { getSession } from './AuthService.js';

/**
 * 联机对局控制器。
 *
 * 同步模型：房主权威。房主是红方，负责校验落子并把完整局面快照写入房间；
 * 客人是蓝方，只提交行动意图，收到房主快照/行动后再在本地重放。
 *
 * 依赖 context 提供的对局操作（由 main.js 注入），本模块不直接碰 Canvas。
 */
export class OnlineMatch {
    constructor(context) {
        this.ctx = context;
        this.active = false;
        this.started = false;
        this.room = null;
        this.role = null;          // 'host' | 'guest'
        this.side = null;          // 'red' | 'blue'
        this.appliedVersion = 0;
        this.actionSeq = 0;
        this.lastIntentSeq = 0;
        this.appliedSeq = 0;
        this.pendingLastAction = null;
        this.pendingIntent = false;
        this.finishing = false;
        this.pollTimer = null;
        this.intentQueue = [];
        this.processingIntent = false;
        this.userId = null;
    }

    isActive() { return this.active; }
    isHost() { return this.role === 'host'; }
    isGuest() { return this.role === 'guest'; }
    isSetupPhase() {
        return this.active && (this.room?.status === 'waiting' || this.room?.status === 'base');
    }
    isMyTurn() {
        return this.active && this.started && this.ctx.getCurrentTurn() === this.side;
    }
    isLocked() { return this.pendingIntent; }
    getRoom() { return this.room; }
    getSide() { return this.side; }

    async createRoom() {
        const session = await getSession();
        if (!session) throw new Error('请先登录 AKB 账号');
        this.userId = session.user.id;
        const profile = await this.ctx.getProfile();
        const seeds = this.ctx.prepareHostMap();
        const room = await Rooms.createRoom({
            mapSeeds: seeds,
            nickname: profile?.nickname || '房主'
        });
        this.attach(room, 'host');
        this.ctx.onRoomChange?.(room);
        return room;
    }

    async joinRoom(code) {
        const session = await getSession();
        if (!session) throw new Error('请先登录 AKB 账号');
        this.userId = session.user.id;
        const room = await Rooms.joinRoomByCode(code);
        if (!room) throw new Error('房间不存在');
        this.attach(room, room.host_id === this.userId ? 'host' : 'guest');
        await this.handleRoom(room, { initial: true });
        return room;
    }

    attach(room, role) {
        this.active = true;
        this.started = false;
        this.finishing = false;
        this.room = room;
        this.role = role;
        this.side = role === 'host' ? 'red' : 'blue';
        this.appliedVersion = room.version || 0;
        this.actionSeq = room.version || 0;
        this.appliedSeq = room.version || 0;
        this.lastIntentSeq = 0;
        this.pendingLastAction = null;
        this.pendingIntent = false;
        this.intentQueue = [];

        this.ctx.loadSeeds(room.map_seeds);
        Rooms.subscribeRoom(room.id, {
            onRoom: next => { this.handleRoom(next).catch(error => this.reportError(error)); },
            onAction: row => { this.handleIntent(row).catch(error => this.reportError(error)); }
        });
        this.startPolling();
    }

    startPolling() {
        this.stopPolling();
        this.pollTimer = window.setInterval(() => {
            this.pollOnce().catch(() => {});
        }, 2500);
    }

    stopPolling() {
        if (this.pollTimer !== null) {
            window.clearInterval(this.pollTimer);
            this.pollTimer = null;
        }
    }

    async pollOnce() {
        if (!this.active || !this.room) return;
        const room = await Rooms.getRoom(this.room.id);
        if (!room) return;
        await this.handleRoom(room);

        if (this.isHost()) {
            const rows = await Rooms.fetchActions(room.id, this.lastIntentSeq);
            for (const row of rows) {
                this.lastIntentSeq = Math.max(this.lastIntentSeq, row.seq);
                await this.handleIntent(row);
            }
        }
    }

    reportError(error) {
        console.warn('[TreeGrow] 联机错误', error);
        this.ctx.showFeedback?.(error?.message || '联机操作失败', 'warning', 2600);
    }

    async handleRoom(room, { initial = false } = {}) {
        if (!this.active) return;
        this.room = room;
        this.ctx.onRoomChange?.(room);

        if (room.status === 'closed') {
            this.ctx.showFeedback?.('房间已关闭', 'warning', 2600);
            this.stop();
            this.ctx.onMatchStopped?.('closed');
            return;
        }

        if (room.status === 'waiting') {
            this.ctx.showGameWaiting?.(room);
            return;
        }

        if (room.status === 'base') {
            this.ctx.showGameScreen?.();
            this.ctx.setBases?.(room.red_base_id, room.blue_base_id);
            if (this.isHost()) {
                this.ctx.setGamePhase?.(room.red_base_id ? 'selectBlue' : 'selectRed');
                this.ctx.setHint?.(room.red_base_id
                    ? '红方基地已确定，等待蓝方选择基地…'
                    : '请点击地图区域，为红方选择基地。');
                if (room.red_base_id && room.blue_base_id) await this.startHostPlaying(room, false);
            } else {
                this.ctx.setGamePhase?.('selectBlue');
                this.ctx.setHint?.(room.red_base_id
                    ? '红方已选好基地，请点击地图区域选择你的蓝方基地。'
                    : '等待红方选择基地…');
            }
            return;
        }

        if (room.status === 'playing') {
            if (this.isHost()) {
                if (!this.started) await this.startHostPlaying(room, Boolean(room.state));
                else if (room.version > this.appliedVersion) this.applyRoomVersion(room);
            } else if (!this.started) {
                this.startGuestPlaying(room);
            } else if (room.version > this.appliedVersion) {
                this.handleGuestRoomAdvance(room);
            }
            return;
        }

        if (room.status === 'finished') {
            this.handleFinished(room, initial);
        }
    }

    applyRoomVersion(room) {
        this.appliedVersion = room.version;
        this.actionSeq = Math.max(this.actionSeq, room.version);
    }

    async startHostPlaying(room, fromSnapshot) {
        if (this.started) {
            this.applyRoomVersion(room);
            return;
        }
        this.ctx.showGameScreen?.();
        if (fromSnapshot && room.state) {
            this.ctx.applySnapshot(room.state, room.red_base_id, room.blue_base_id);
        } else {
            this.ctx.startHostGame(room.red_base_id, room.blue_base_id);
        }
        this.started = true;
        this.applyRoomVersion(room);

        if (!room.state) {
            this.actionSeq = Math.max(1, this.actionSeq + 1);
            const state = this.ctx.getStateJson();
            const lastAction = { type: 'setup', seq: this.actionSeq };
            const updated = await Rooms.syncState(room.id, state, this.actionSeq, lastAction);
            if (updated) {
                this.room = updated;
                this.applyRoomVersion(updated);
                this.ctx.onRoomChange?.(updated);
            }
        }
    }

    startGuestPlaying(room) {
        if (this.started || !room.state) return;
        this.ctx.showGameScreen?.();
        this.ctx.applySnapshot(room.state, room.red_base_id, room.blue_base_id);
        this.started = true;
        this.appliedVersion = room.version || 0;
        this.appliedSeq = room.version || 0;
        this.handleGuestRoomAdvance(room);
    }

    handleGuestRoomAdvance(room) {
        const action = room.last_action;
        const canReplay = action && Number.isFinite(action.seq) && action.seq > this.appliedSeq &&
            action.type !== 'setup';

        this.appliedVersion = room.version;
        if (!canReplay) {
            this.ctx.applySnapshot(room.state, room.red_base_id, room.blue_base_id);
            this.appliedSeq = room.version;
            this.pendingIntent = false;
            return;
        }

        this.appliedSeq = action.seq;
        this.pendingIntent = true;
        const done = ok => {
            this.pendingIntent = false;
            if (!ok) {
                this.ctx.applySnapshot(room.state, room.red_base_id, room.blue_base_id);
                this.ctx.showFeedback?.('局面已重新同步', 'info', 1800);
            }
        };

        if (action.type === 'skip') {
            this.ctx.applyRemoteSkip?.(action, done);
        } else {
            this.ctx.applyRemoteGrowth?.(action, done);
        }
    }

    async handleIntent(row) {
        if (!this.active || !this.isHost() || !row || !row.payload) return;
        this.lastIntentSeq = Math.max(this.lastIntentSeq, row.seq || 0);
        const payload = row.payload;
        if (!Number.isFinite(payload.seq) || payload.seq <= this.actionSeq) return;
        if (row.actor_id === this.userId) return;
        if (this.intentQueue.some(item => item.seq === payload.seq)) return;
        this.intentQueue.push(payload);
        await this.drainIntents();
    }

    async drainIntents() {
        if (this.processingIntent) return;
        this.processingIntent = true;
        try {
            while (this.intentQueue.length > 0) {
                const payload = this.intentQueue[0];
                if (this.ctx.isBusy?.()) {
                    await new Promise(resolve => window.setTimeout(resolve, 220));
                    continue;
                }
                this.intentQueue.shift();
                if (!this.started || payload.owner !== this.ctx.getCurrentTurn()) {
                    // 过期或不属于当前回合的意图：直接丢弃，等待房主下一次快照覆盖。
                    continue;
                }
                this.actionSeq = Math.max(this.actionSeq, payload.seq);
                if (payload.type === 'skip') {
                    this.pendingLastAction = { type: 'skip', owner: payload.owner, seq: payload.seq };
                    this.ctx.applyLocalSkip?.();
                } else {
                    this.pendingLastAction = {
                        type: 'growth',
                        owner: payload.owner,
                        seq: payload.seq,
                        parentNodeId: payload.parentNodeId,
                        targetAreaId: payload.targetAreaId
                    };
                    const ok = this.ctx.applyLocalGrowth?.(payload);
                    if (!ok) {
                        this.pendingLastAction = null;
                        await this.pushSnapshot();
                    }
                }
            }
        } finally {
            this.processingIntent = false;
        }
    }

    selectBase(areaId) {
        if (!this.active || !this.room) return;
        if (this.room.status !== 'base' && this.room.status !== 'waiting') return;
        if (this.isHost() && this.room.red_base_id !== null) {
            this.ctx.showFeedback?.('红方基地已确定，等待蓝方选择…', 'info', 1800);
            return;
        }
        if (this.isGuest() && this.room.blue_base_id !== null) return;
        if (this.isGuest() && this.room.red_base_id === null) {
            this.ctx.showFeedback?.('等待红方先选择基地…', 'info', 1800);
            return;
        }
        if (this.room.red_base_id === areaId) {
            this.ctx.showFeedback?.('该区域已被红方占用，请选择其他区域。', 'warning');
            return;
        }
        Rooms.setBase(this.room.id, areaId)
            .then(room => this.handleRoom(room))
            .catch(error => this.reportError(error));
    }

    async submitMove(parentNodeId, targetAreaId) {
        if (!this.active || !this.isGuest() || !this.started) return;
        if (!this.isMyTurn()) {
            this.ctx.showFeedback?.('还没轮到你的回合。', 'warning');
            return;
        }
        if (this.pendingIntent) return;
        const seq = (this.room?.version || 0) + 1;
        this.pendingIntent = true;
        this.ctx.showFeedback?.('行动已提交，等待房主确认…', 'info', 1800);
        try {
            await Rooms.submitIntent(this.room.id, seq, {
                type: 'growth',
                owner: 'blue',
                seq,
                parentNodeId,
                targetAreaId
            });
        } catch (error) {
            this.pendingIntent = false;
            this.reportError(error);
        }
    }

    async submitSkip() {
        if (!this.active || !this.isGuest() || !this.started) return;
        if (!this.isMyTurn()) return;
        if (this.pendingIntent) return;
        const seq = (this.room?.version || 0) + 1;
        this.pendingIntent = true;
        this.ctx.showFeedback?.('跳过请求已提交，等待房主确认…', 'info', 1800);
        try {
            await Rooms.submitIntent(this.room.id, seq, {
                type: 'skip',
                owner: 'blue',
                seq
            });
        } catch (error) {
            this.pendingIntent = false;
            this.reportError(error);
        }
    }

    /** 房主本地落子/跳过前调用，记录待同步的行动。 */
    noteLocalAction(action) {
        if (!this.isHost() || !this.active) return;
        const base = Math.max(this.actionSeq, this.room?.version || 0);
        this.actionSeq = base + 1;
        this.pendingLastAction = { ...action, seq: this.actionSeq };
    }

    /** 每次回合真正切换（含战斗结算完成）后由 main.js 调用。 */
    onLocalStateSettled() {
        if (!this.active || !this.isHost() || this.finishing) return;
        const action = this.pendingLastAction;
        if (!action) return;
        this.pendingLastAction = null;
        const version = action.seq;
        const state = this.ctx.getStateJson();
        Rooms.syncState(this.room.id, state, version, action)
            .then(room => {
                if (!room) return;
                this.room = room;
                this.applyRoomVersion(room);
                this.ctx.onRoomChange?.(room);
            })
            .catch(error => this.reportError(error));
    }

    async pushSnapshot() {
        if (!this.isHost() || !this.active) return;
        const version = Math.max(this.actionSeq, this.room?.version || 0) + 1;
        this.actionSeq = version;
        const action = { type: 'resync', seq: version };
        const room = await Rooms.syncState(this.room.id, this.ctx.getStateJson(), version, action);
        if (room) {
            this.room = room;
            this.applyRoomVersion(room);
            this.ctx.onRoomChange?.(room);
        }
    }

    /** 房主在本地判定胜负后调用。 */
    onLocalMatchFinished(winner) {
        if (!this.active || !this.isHost() || this.finishing) return;
        this.finishing = true;
        const action = this.pendingLastAction;
        this.pendingLastAction = null;
        const state = this.ctx.getStateJson();
        const result = this.ctx.getResultJson();
        Rooms.finishRoom(this.room.id, { winner, state, lastAction: action, result })
            .then(() => this.ctx.onRoomChange?.({ ...this.room, status: 'finished', winner }))
            .catch(error => this.reportError(error))
            .finally(() => this.stopPolling());
    }

    handleFinished(room, initial) {
        this.finishing = true;
        this.stopPolling();
        if (this.isHost()) {
            this.ctx.showOnlineFinished?.(room);
            return;
        }
        const action = room.last_action;
        const needReplay = !initial && action && Number.isFinite(action.seq) &&
            action.seq > this.appliedSeq && action.type === 'growth';
        if (needReplay) {
            this.appliedSeq = action.seq;
            this.pendingIntent = true;
            this.ctx.applyRemoteGrowth?.(action, () => {
                this.ctx.showOnlineFinished?.(room);
                this.pendingIntent = false;
            });
        } else {
            this.ctx.showOnlineFinished?.(room);
        }
    }

    async leave() {
        const room = this.room;
        this.stop();
        if (room) {
            try { await Rooms.leaveRoom(room.id); } catch (error) { console.warn(error); }
        }
        this.ctx.onMatchStopped?.('leave');
    }

    stop() {
        this.active = false;
        this.started = false;
        this.stopPolling();
        Rooms.unsubscribeRoom();
        this.room = null;
        this.role = null;
        this.side = null;
        this.pendingLastAction = null;
        this.pendingIntent = false;
        this.intentQueue = [];
    }
}
