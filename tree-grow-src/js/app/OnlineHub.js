import {
    getSession, getProfile, getRating, getLeaderboard,
    signIn, signOut
} from '../net/AuthService.js';
import { listWaitingRooms } from '../net/RoomService.js';
import { loadSdk } from '../net/supabase.js';
import { MYSTERY_PASSWORD, PORTAL_ACCESS_KEY } from '../net/config.js';

const $ = id => document.getElementById(id);

/**
 * 神秘入口 / 小游戏门户 / 联机大厅的界面与账号逻辑。
 * 对局同步交给 OnlineMatch，本类只负责门禁、大厅与房间面板。
 */
export class OnlineHub {
    constructor({ showScreen, onlineMatch }) {
        this.showScreen = showScreen;
        this.match = onlineMatch;
        this.session = null;
        this.profile = null;
        this.rating = null;
        this.gatePurpose = 'portal';
        this.lobbyTimer = null;
        this.rooms = [];
    }

    init() {
        $('mystery-entry-btn')?.addEventListener('click', () => this.openEntry());
        $('gate-close-btn')?.addEventListener('click', () => this.closeGate());
        $('gate-modal')?.addEventListener('click', event => {
            if (event.target === $('gate-modal')) this.closeGate();
        });
        $('gate-login-form')?.addEventListener('submit', event => this.handleLogin(event));
        $('gate-pass-form')?.addEventListener('submit', event => this.handlePassword(event));
        $('gate-signout-btn')?.addEventListener('click', () => this.handleSignOut());

        $('portal-back-btn')?.addEventListener('click', () => this.showScreen('menu'));
        $('portal-enter-tree')?.addEventListener('click', () => this.showScreen('menu'));
        $('portal-login-btn')?.addEventListener('click', () => this.openGate('portal'));
        $('portal-logout-btn')?.addEventListener('click', () => this.handleSignOut());

        $('online-menu-btn')?.addEventListener('click', () => this.openLobby());
        $('lobby-refresh-btn')?.addEventListener('click', () => this.refreshLobby(true));
        $('lobby-back-btn')?.addEventListener('click', () => this.closeLobby());
        $('lobby-create-btn')?.addEventListener('click', () => this.createRoom());
        $('lobby-join-form')?.addEventListener('submit', event => this.handleJoin(event));
        $('lobby-room-list')?.addEventListener('click', event => {
            const button = event.target.closest('[data-join-code]');
            if (button) this.joinRoom(button.dataset.joinCode);
        });
        $('room-copy-btn')?.addEventListener('click', () => this.copyRoomCode());
        $('room-leave-btn')?.addEventListener('click', () => this.leaveRoom());

        $('lobby-code-input')?.addEventListener('input', event => {
            event.target.value = String(event.target.value || '').toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 6);
        });

        loadSdk().then(ok => {
            if (!ok) console.warn('[TreeGrow] 联机 SDK 加载失败，联机入口仍可打开但无法登录。');
        });
        this.syncOnlineEntryVisibility();
    }

    /** 联机大厅只对已通过神秘入口（或管理员）的玩家显示。 */
    syncOnlineEntryVisibility() {
        const button = $('online-menu-btn');
        if (!button) return;
        let unlocked = false;
        try { unlocked = window.sessionStorage.getItem(PORTAL_ACCESS_KEY) === '1'; } catch { /* ignore */ }
        if (!unlocked && this.profile?.role === 'admin') unlocked = true;
        button.hidden = !unlocked;
    }

    async refreshAccount() {
        try {
            const online = await loadSdk();
            if (!online) {
                this.session = null;
                this.profile = null;
                this.rating = null;
                this.renderAccount();
                this.syncOnlineEntryVisibility();
                return { session: null, profile: null };
            }
            this.session = await getSession();
            this.profile = this.session ? await getProfile() : null;
            this.rating = this.profile ? await getRating(this.profile.id) : null;
        } catch (error) {
            console.warn('[TreeGrow] 读取账号失败', error);
            this.session = null;
            this.profile = null;
            this.rating = null;
        }
        this.renderAccount();
        this.syncOnlineEntryVisibility();
        return { session: this.session, profile: this.profile };
    }

    renderAccount() {
        const name = this.profile?.nickname || '未登录';
        const points = this.rating ? Number(this.rating.points) : 1000;
        const isAdmin = this.profile?.role === 'admin';

        const portalName = $('portal-account-name');
        const portalPoints = $('portal-account-points');
        if (portalName) portalName.textContent = this.profile ? `${name}${isAdmin ? ' · 管理员' : ''}` : '未登录';
        if (portalPoints) portalPoints.textContent = this.profile ? `积分 ${points}` : '';

        const loginBtn = $('portal-login-btn');
        const logoutBtn = $('portal-logout-btn');
        if (loginBtn) loginBtn.hidden = Boolean(this.session);
        if (logoutBtn) logoutBtn.hidden = !this.session;

        const account = $('gate-account');
        const signoutBtn = $('gate-signout-btn');
        if (account) {
            account.hidden = !this.session;
            if (this.session && this.profile) {
                account.textContent = `已登录：${name}${isAdmin ? '（管理员，可免密进入）' : '（普通用户，仍需通行密码）'} · 积分 ${points}`;
            } else if (this.session) {
                account.textContent = '已登录，但账号资料读取失败';
            }
        }
        if (signoutBtn) signoutBtn.hidden = !this.session;
    }

    openEntry() {
        try {
            if (window.sessionStorage.getItem(PORTAL_ACCESS_KEY) === '1') {
                this.openPortal();
                return;
            }
        } catch { /* 隐私模式下 sessionStorage 不可用，退回密码门 */ }
        this.openGate('portal');
    }

    async openGate(purpose = 'portal') {
        this.gatePurpose = purpose;
        const modal = $('gate-modal');
        if (!modal) return;
        this.clearGateErrors();
        modal.hidden = false;

        const note = $('gate-note');
        const title = $('gate-title');
        if (title) title.textContent = purpose === 'lobby' ? '联机大厅' : '神秘入口';
        if (note) {
            note.textContent = purpose === 'lobby'
                ? '联机大厅需要绑定 AKB 账号：登录后对局结果会计入积分。管理员登录后可直接进入。'
                : '管理员登录 AKB 账号后可直接进入；普通用户请输入通行密码。';
        }
        const passForm = $('gate-pass-form');
        if (passForm) passForm.hidden = purpose === 'lobby';

        const { session, profile } = await this.refreshAccount();
        if (session && profile?.role === 'admin') {
            try { window.sessionStorage.setItem(PORTAL_ACCESS_KEY, '1'); } catch { /* ignore */ }
            this.closeGate();
            if (purpose === 'lobby') this.openLobby();
            else this.openPortal();
            return;
        }
        $('gate-contact-input')?.focus();
    }

    closeGate() {
        const modal = $('gate-modal');
        if (modal) modal.hidden = true;
    }

    clearGateErrors() {
        for (const id of ['gate-login-error', 'gate-pass-error']) {
            const element = $(id);
            if (element) element.textContent = '';
        }
    }

    async handleLogin(event) {
        event.preventDefault();
        const errorEl = $('gate-login-error');
        const contact = $('gate-contact-input')?.value.trim() || '';
        const password = $('gate-password-input')?.value || '';
        if (errorEl) errorEl.textContent = '';
        if (!contact || !password) {
            if (errorEl) errorEl.textContent = '请填写账号与密码';
            return;
        }

        const submit = event.target.querySelector('button[type="submit"]');
        if (submit) submit.disabled = true;
        try {
            const online = await loadSdk();
            if (!online) throw new Error('联机服务不可用：请联网后刷新页面');
            const profile = await signIn(contact, password);
            this.profile = profile;
            await this.refreshAccount();
            if (profile.role === 'admin') {
                this.closeGate();
                if (this.gatePurpose === 'lobby') this.openLobby();
                else this.openPortal();
                return;
            }
            if (this.gatePurpose === 'lobby') {
                this.closeGate();
                this.openLobby();
                return;
            }
            if (errorEl) errorEl.textContent = '登录成功。普通用户仍需在下方输入通行密码。';
            $('gate-pass-input')?.focus();
        } catch (error) {
            if (errorEl) errorEl.textContent = error?.message || '登录失败';
        } finally {
            if (submit) submit.disabled = false;
        }
    }

    handlePassword(event) {
        event.preventDefault();
        const errorEl = $('gate-pass-error');
        const input = $('gate-pass-input');
        const value = input?.value || '';
        if (errorEl) errorEl.textContent = '';
        if (value !== MYSTERY_PASSWORD) {
            if (errorEl) errorEl.textContent = '通行密码不正确';
            return;
        }
        try { window.sessionStorage.setItem(PORTAL_ACCESS_KEY, '1'); } catch { /* ignore */ }
        if (input) input.value = '';
        this.closeGate();
        this.openPortal();
    }

    async handleSignOut() {
        try { await signOut(); } catch (error) { console.warn(error); }
        this.session = null;
        this.profile = null;
        this.rating = null;
        this.renderAccount();
        this.syncOnlineEntryVisibility();
    }

    async openPortal() {
        this.closeGate();
        this.showScreen('portal');
        await this.refreshAccount();
    }

    async openLobby() {
        const { session, profile } = await this.refreshAccount();
        if (!session || !profile) {
            this.openGate('lobby');
            return;
        }
        this.closeGate();
        const label = $('lobby-account');
        if (label) {
            const points = this.rating ? Number(this.rating.points) : 1000;
            const wins = this.rating ? this.rating.wins : 0;
            const losses = this.rating ? this.rating.losses : 0;
            label.textContent = `${profile.nickname || '玩家'} · 积分 ${points} · ${wins} 胜 ${losses} 负`;
        }
        this.showScreen('lobby');
        this.setRoomPanel(null);
        await this.refreshLobby();
        const activeRoom = this.match?.getRoom?.();
        if (activeRoom) this.renderRoom(activeRoom);
        this.startLobbyTimer();
    }

    closeLobby() {
        if (this.match?.isActive()) {
            if (!window.confirm('离开联机大厅会退出当前房间，是否继续？')) return;
            this.leaveRoom();
            return;
        }
        this.stopLobbyTimer();
        this.showScreen('menu');
    }

    startLobbyTimer() {
        this.stopLobbyTimer();
        this.lobbyTimer = window.setInterval(() => {
            if ($('lobby-screen')?.hidden) return;
            this.refreshLobby().catch(() => {});
        }, 8000);
    }

    stopLobbyTimer() {
        if (this.lobbyTimer !== null) {
            window.clearInterval(this.lobbyTimer);
            this.lobbyTimer = null;
        }
    }

    setLobbyMessage(message, type = 'info') {
        const element = $('lobby-message');
        if (!element) return;
        element.textContent = message || '';
        element.dataset.type = type;
    }

    friendlyRoomError(error) {
        const message = error?.message || '联机操作失败';
        if (/tree_grow_rooms|tree_grow_actions|schema cache|could not find the table|does not exist/i.test(message)) {
            return '联机数据表尚未创建：请先在 Supabase SQL Editor 执行 supabase/phase27-tree-grow-online.sql';
        }
        return message;
    }

    async refreshLobby(showFeedback = false) {
        try {
            const [rooms, leaderboard] = await Promise.all([listWaitingRooms(), getLeaderboard(10)]);
            this.rooms = rooms;
            this.renderRooms(rooms);
            this.renderLeaderboard(leaderboard);
            if (showFeedback) this.setLobbyMessage('已刷新房间列表');
        } catch (error) {
            console.warn('[TreeGrow] 刷新大厅失败', error);
            this.setLobbyMessage(this.friendlyRoomError(error), 'error');
        }
    }

    renderRooms(rooms) {
        const list = $('lobby-room-list');
        if (!list) return;
        list.replaceChildren();
        if (!rooms.length) {
            const empty = document.createElement('p');
            empty.className = 'slot-empty-state';
            empty.textContent = '当前没有等待中的房间，创建一个吧。';
            list.appendChild(empty);
            return;
        }
        for (const room of rooms) {
            const row = document.createElement('div');
            row.className = 'lobby-room';
            const info = document.createElement('div');
            const code = document.createElement('strong');
            code.textContent = room.code;
            const host = document.createElement('small');
            host.textContent = `房主：${room.host_nickname || '玩家'}`;
            info.append(code, host);
            const button = document.createElement('button');
            button.type = 'button';
            button.className = 'toolbar-button';
            button.dataset.joinCode = room.code;
            button.textContent = '加入';
            row.append(info, button);
            list.appendChild(row);
        }
    }

    renderLeaderboard(rows) {
        const list = $('lobby-leaderboard');
        if (!list) return;
        list.replaceChildren();
        if (!rows.length) {
            const empty = document.createElement('li');
            empty.className = 'slot-empty-state';
            empty.textContent = '暂无记录，完成第一局联机后就会出现。';
            list.appendChild(empty);
            return;
        }
        for (const row of rows) {
            const item = document.createElement('li');
            const name = document.createElement('span');
            name.textContent = row.nickname || '玩家';
            const points = document.createElement('strong');
            points.textContent = String(row.points);
            item.append(name, points);
            list.appendChild(item);
        }
    }

    async createRoom() {
        this.setLobbyMessage('正在创建房间…');
        try {
            const room = await this.match.createRoom();
            this.setLobbyMessage('');
            this.renderRoom(room);
            this.stopLobbyTimer();
        } catch (error) {
            this.setLobbyMessage(this.friendlyRoomError(error), 'error');
        }
    }

    async handleJoin(event) {
        event.preventDefault();
        const code = $('lobby-code-input')?.value.trim() || '';
        if (!code) {
            this.setLobbyMessage('请输入 6 位房间码', 'error');
            return;
        }
        await this.joinRoom(code);
    }

    async joinRoom(code) {
        this.setLobbyMessage('正在加入房间…');
        try {
            const room = await this.match.joinRoom(code);
            this.setLobbyMessage('');
            this.renderRoom(room);
            this.stopLobbyTimer();
        } catch (error) {
            this.setLobbyMessage(this.friendlyRoomError(error), 'error');
        }
    }

    async leaveRoom() {
        try { await this.match.leave(); } catch (error) { console.warn(error); }
    }

    setRoomPanel(room) {
        const panel = $('room-panel');
        const grid = $('lobby-grid');
        if (!panel || !grid) return;
        if (!room) {
            panel.hidden = true;
            grid.hidden = false;
            return;
        }
        panel.hidden = false;
        grid.hidden = true;
    }

    renderRoom(room) {
        if (!room) {
            this.setRoomPanel(null);
            return;
        }
        if (room.status === 'closed') {
            this.setRoomPanel(null);
            this.setLobbyMessage('房间已关闭', 'error');
            return;
        }
        this.setRoomPanel(room);
        const code = $('room-code');
        if (code) code.textContent = room.code || '';
        const status = $('room-status');
        if (status) {
            const labels = {
                waiting: '等待对手加入…把房间码发给朋友。',
                base: '选择基地阶段：红方先选，蓝方后选。',
                playing: '对局进行中。',
                finished: '对局已结束。'
            };
            status.textContent = labels[room.status] || '';
        }
        const players = $('room-players');
        if (players) {
            players.replaceChildren();
            const host = document.createElement('div');
            host.className = 'room-player red';
            host.textContent = `红方 · ${room.host_nickname || '房主'}（房主）`;
            const guest = document.createElement('div');
            guest.className = 'room-player blue';
            guest.textContent = `蓝方 · ${room.guest_nickname || '等待加入'}`;
            players.append(host, guest);
        }
        if (room.status === 'playing' || room.status === 'base') {
            this.stopLobbyTimer();
        }
    }

    async copyRoomCode() {
        const code = $('room-code')?.textContent || '';
        if (!code) return;
        try {
            await navigator.clipboard.writeText(code);
            this.setLobbyMessage('房间码已复制');
        } catch {
            this.setLobbyMessage(`房间码：${code}`);
        }
    }

    handleMatchStopped() {
        const next = this.nextScreen || 'lobby';
        this.nextScreen = null;
        this.setRoomPanel(null);
        if (next === 'menu') {
            this.stopLobbyTimer();
            this.showScreen('menu');
            this.refreshAccount().catch(() => {});
            return;
        }
        this.showScreen('lobby');
        this.refreshLobby().catch(() => {});
        this.startLobbyTimer();
        this.refreshAccount().catch(() => {});
    }

    async exitMatchTo(screen = 'lobby') {
        this.nextScreen = screen;
        if (this.match?.isActive()) {
            await this.match.leave();
            return;
        }
        this.setRoomPanel(null);
        this.showScreen(screen);
        if (screen === 'menu') this.stopLobbyTimer();
    }
}
