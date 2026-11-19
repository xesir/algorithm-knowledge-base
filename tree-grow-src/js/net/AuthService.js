import { requireClient } from './supabase.js';

const AUTHOR_EMAIL_DOMAIN = 'authors.akb.example.com';

/** 登录标识 → Supabase Auth 邮箱（与 algorithm-knowledge-base 保持一致）。 */
export function contactToEmail(contact) {
    const value = String(contact || '').trim();
    if (!value) return '';
    if (value.includes('@')) return value.toLowerCase();
    const local = value.toLowerCase().replace(/[^a-z0-9._-]/g, '');
    return local ? local + '@' + AUTHOR_EMAIL_DOMAIN : '';
}

function friendlyAuthError(error) {
    const message = (error && error.message) || '';
    if (/invalid login credentials/i.test(message)) return '账号或密码不正确';
    if (/email not confirmed/i.test(message)) return '账号尚未通过邮箱验证';
    if (/failed to fetch|networkerror|load failed|network request failed|abort/i.test(message)) {
        return '无法连接 Supabase，请检查网络或项目是否已暂停';
    }
    return message || '登录失败';
}

async function resolveLoginEmail(contact, password) {
    const client = requireClient();
    const lower = String(contact || '').toLowerCase();
    if (lower.includes('@')) return lower;
    try {
        const resolved = await client.rpc('resolve_login_email', {
            p_identifier: contact,
            p_password: password
        });
        if (!resolved.error && resolved.data) return resolved.data;
    } catch (error) {
        console.warn('[TreeGrow] resolve_login_email 不可用', error);
    }
    return contactToEmail(contact);
}

export async function getSession() {
    const client = requireClient();
    const result = await client.auth.getSession();
    return result.data ? result.data.session : null;
}

export async function getUser() {
    const client = requireClient();
    const result = await client.auth.getUser();
    return result.data ? result.data.user : null;
}

export async function getProfile() {
    const client = requireClient();
    const user = await getUser();
    if (!user) return null;
    const result = await client
        .from('profiles')
        .select('id, nickname, role, status')
        .eq('id', user.id)
        .single();
    return result.error ? null : result.data;
}

export async function isAdmin() {
    try {
        const profile = await getProfile();
        return Boolean(profile && profile.role === 'admin' && profile.status !== 'pending');
    } catch {
        return false;
    }
}

export async function signIn(contact, password) {
    const client = requireClient();
    const email = await resolveLoginEmail(contact, password);
    const result = await client.auth.signInWithPassword({ email, password });
    if (result.error) throw new Error(friendlyAuthError(result.error));

    const profile = await getProfile();
    if (!profile) {
        await client.auth.signOut();
        throw new Error('账号资料不存在，请联系管理员');
    }
    if (profile.status === 'pending') {
        await client.auth.signOut();
        throw new Error('账号正在等待管理员审核，暂时无法登录');
    }
    return profile;
}

export async function signOut() {
    const client = requireClient();
    await client.auth.signOut();
}

/** 读取积分；未上过场的账号返回 null，调用方按 1000 初始分展示。 */
export async function getRating(userId) {
    const client = requireClient();
    const result = await client
        .from('tree_grow_ratings')
        .select('points, wins, losses, draws, games')
        .eq('user_id', userId)
        .maybeSingle();
    if (result.error) return null;
    return result.data || null;
}

export async function getLeaderboard(limit = 10) {
    const client = requireClient();
    const result = await client
        .from('tree_grow_ratings')
        .select('nickname, points, wins, losses, games')
        .order('points', { ascending: false })
        .order('updated_at', { ascending: true })
        .limit(limit);
    if (result.error) return [];
    return result.data || [];
}
