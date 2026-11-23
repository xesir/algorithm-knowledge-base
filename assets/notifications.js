/**
 * 通知栏：右下角悬浮铃铛 + 抽屉（系统通知 / 私聊）。
 * 依赖：Supabase SDK + supabase-config.js + assets/auth.js（window.AKB）。
 * 数据表与函数见 supabase/phase23-notifications-chat.sql。
 * 未登录也会显示入口（面板内提示登录）；表不存在时在面板内给出执行提示，不影响页面其它功能。
 */
(function () {
    'use strict';

    var state = {
        client: null,
        me: '',
        inited: false,
        open: false,
        tab: 'system',
        notifications: [],
        contacts: [],
        contactsLoaded: false,
        peer: null,
        pollTimer: null,
        badgeTimer: null,
        sending: false
    };
    var ui = {};

    var SQL_HINT = '通知功能尚未启用：请先在 Supabase SQL Editor 执行 supabase/phase23-notifications-chat.sql';

    // 神秘入口：管理员免密，普通用户需要通行密码（与生长树游戏内门户一致）
    var MYSTERY_PASSWORD = 'gcx34580';
    var PORTAL_ACCESS_KEY = 'treeGrow:portalAccess:v1';
    var PORTAL_URL = 'tree-grow/';

    function byId(id) { return document.getElementById(id); }

    function esc(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function fmtTime(value) {
        if (window.AKB && typeof window.AKB.formatTime === 'function') return window.AKB.formatTime(value);
        return value || '';
    }

    function isMissingTable(error) {
        return /does not exist|Could not find the table|schema cache|relation .* does not exist/i.test((error && error.message) || '');
    }

    function hintHtml() {
        return '<div class="akb-notify-empty">' + esc(SQL_HINT) + '</div>';
    }

    function guestHtml(kind) {
        var text = kind === 'chat'
            ? '登录后才能和其他用户一对一聊天。'
            : '登录后才能收到系统通知，例如别人对你的专栏提交了修改工单。';
        var extra = window.supabaseClient ? '' :
            '<br><small>当前页面未连上 Supabase（SDK 未加载或网络受限），登录也会失败。</small>';
        return '<div class="akb-notify-empty">' + text +
            '<br><a href="login.html">去登录</a>' + extra + '</div>';
    }

    function loggedIn() {
        return !!(state.client && state.me);
    }

    // 侧边栏加一个文字入口，避免只看得到右下角小铃铛
    function mountSidebarEntry() {
        if (document.getElementById('akb-notify-sidebar')) return;
        var actions = document.querySelector('.sidebar-auth-actions');
        if (actions) {
            var button = document.createElement('button');
            button.type = 'button';
            button.id = 'akb-notify-sidebar';
            button.className = 'sidebar-auth-btn';
            button.textContent = '🔔 通知与聊天';
            button.addEventListener('click', function () { setOpen(true); });
            button.setAttribute('data-akb-open', '');
            actions.insertBefore(button, actions.firstChild);
            return;
        }
        // 后台（admin.html）没有 .sidebar-auth-actions，放进侧边栏底部
        var footer = document.querySelector('.admin-sidebar-footer');
        if (!footer) return;
        var link = document.createElement('button');
        link.type = 'button';
        link.id = 'akb-notify-sidebar';
        link.textContent = '🔔 通知与聊天';
        link.style.cssText = 'display:flex;align-items:center;gap:.4rem;padding:.35rem .45rem;' +
            'border:none;border-radius:.35rem;background:none;color:#94a3b8;font-size:.75rem;' +
            'cursor:pointer;text-align:left;font-family:inherit;';
        link.addEventListener('click', function () { setOpen(true); });
        link.setAttribute('data-akb-open', '');
        footer.insertBefore(link, footer.firstChild);
    }

    // ---------- 结构 ----------
    function mount() {
        var html = '' +
            '<button class="akb-notify-fab" id="akb-notify-fab" type="button" aria-label="通知与聊天" aria-expanded="false">' +
            '<span aria-hidden="true">🔔</span>' +
            '<span class="akb-notify-badge" id="akb-notify-badge" hidden></span>' +
            '</button>' +
            '<section class="akb-notify-panel" id="akb-notify-panel" role="dialog" aria-label="通知栏" hidden>' +
            '<header class="akb-notify-head">' +
            '<strong>通知栏</strong>' +
            '<div class="akb-notify-head-actions">' +
            '<button type="button" id="akb-notify-refresh" title="刷新" aria-label="刷新">↻</button>' +
            '<button type="button" id="akb-notify-close" title="关闭" aria-label="关闭">✕</button>' +
            '</div>' +
            '</header>' +
            '<div class="akb-notify-tabs">' +
            '<button type="button" data-akb-tab="system" class="active">系统通知 <span class="akb-notify-tab-count" id="akb-count-system"></span></button>' +
            '<button type="button" data-akb-tab="chat">聊天 <span class="akb-notify-tab-count" id="akb-count-chat"></span></button>' +
            '</div>' +
            '<div class="akb-notify-panes">' +
            '<div class="akb-notify-pane" data-akb-pane="system">' +
            '<div class="akb-notify-list" id="akb-notify-list"></div>' +
            '</div>' +
            '<div class="akb-notify-pane" data-akb-pane="chat" hidden>' +
            '<div id="akb-chat-list-view">' +
            '<input id="akb-chat-search" type="search" placeholder="搜索昵称，选择聊天对象" autocomplete="off">' +
            '<div id="akb-chat-contacts"></div>' +
            '</div>' +
            '<div id="akb-chat-thread-view" hidden>' +
            '<div class="akb-chat-thread-head">' +
            '<button type="button" id="akb-chat-back" aria-label="返回联系人">←</button>' +
            '<strong id="akb-chat-peer-name"></strong>' +
            '</div>' +
            '<div class="akb-chat-messages" id="akb-chat-messages"></div>' +
            '<p class="akb-chat-error" id="akb-chat-error" hidden></p>' +
            '<form class="akb-chat-form" id="akb-chat-form">' +
            '<input id="akb-chat-input" type="text" maxlength="2000" placeholder="输入文字消息…" autocomplete="off">' +
            '<button type="submit" id="akb-chat-send">发送</button>' +
            '</form>' +
            '</div>' +
            '</div>' +
            '</div>' +
            '<footer class="akb-notify-foot">' +
            '<button type="button" id="akb-mystery-entry">🌱 神秘入口</button>' +
            '</footer>' +
            '</section>';

        var holder = document.createElement('div');
        holder.innerHTML = html;
        while (holder.firstChild) document.body.appendChild(holder.firstChild);

        mountSidebarEntry();

        ui.fab = byId('akb-notify-fab');
        ui.badge = byId('akb-notify-badge');
        ui.panel = byId('akb-notify-panel');
        ui.tabs = Array.prototype.slice.call(document.querySelectorAll('[data-akb-tab]'));
        ui.panes = Array.prototype.slice.call(document.querySelectorAll('[data-akb-pane]'));
        ui.list = byId('akb-notify-list');
        ui.countSystem = byId('akb-count-system');
        ui.countChat = byId('akb-count-chat');
        ui.chatListView = byId('akb-chat-list-view');
        ui.chatThreadView = byId('akb-chat-thread-view');
        ui.chatSearch = byId('akb-chat-search');
        ui.chatContacts = byId('akb-chat-contacts');
        ui.chatMessages = byId('akb-chat-messages');
        ui.chatPeerName = byId('akb-chat-peer-name');
        ui.chatInput = byId('akb-chat-input');
        ui.chatSend = byId('akb-chat-send');
        ui.chatError = byId('akb-chat-error');

        bindEvents();
    }

    function bindEvents() {
        ui.fab.addEventListener('click', function () { setOpen(!state.open); });
        byId('akb-notify-close').addEventListener('click', function () { setOpen(false); });
        byId('akb-notify-refresh').addEventListener('click', function () {
            refreshBadge();
            if (state.tab === 'chat' && state.peer) {
                loadMessages(true);
            } else {
                loadTab(state.tab, true);
            }
        });
        ui.tabs.forEach(function (tab) {
            tab.addEventListener('click', function () {
                loadTab(tab.getAttribute('data-akb-tab'));
            });
        });
        ui.list.addEventListener('click', function (event) {
            var item = event.target.closest('[data-notify-index]');
            if (!item) return;
            var record = state.notifications[Number(item.getAttribute('data-notify-index'))];
            if (record && record.link) {
                setOpen(false);
                window.location.href = record.link;
            }
        });
        ui.chatSearch.addEventListener('input', function () { renderContacts(); });
        ui.chatContacts.addEventListener('click', function (event) {
            var row = event.target.closest('[data-chat-peer]');
            if (!row) return;
            var contact = state.contacts.filter(function (item) {
                return item.id === row.getAttribute('data-chat-peer');
            })[0];
            if (contact) openThread(contact);
        });
        byId('akb-chat-back').addEventListener('click', closeThread);
        byId('akb-chat-form').addEventListener('submit', sendMessage);
        byId('akb-mystery-entry').addEventListener('click', openMysteryEntry);
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape' && state.open) setOpen(false);
        });
        document.addEventListener('click', function (event) {
            if (!state.open) return;
            if (ui.panel.contains(event.target) || ui.fab.contains(event.target)) return;
            if (event.target.closest && event.target.closest('[data-akb-open]')) return;
            setOpen(false);
        });
    }

    // ---------- 神秘入口 ----------
    function hasPortalAccess() {
        try { return window.sessionStorage.getItem(PORTAL_ACCESS_KEY) === '1'; } catch (err) { return false; }
    }

    function grantPortalAccess() {
        try { window.sessionStorage.setItem(PORTAL_ACCESS_KEY, '1'); } catch (err) { /* 隐私模式下忽略 */ }
    }

    function isAdminProfile(profile) {
        return !!(profile && profile.role === 'admin' && profile.status !== 'pending');
    }

    function askPortalPassword() {
        var input = window.prompt('神秘入口需要通行密码：');
        if (input === null) return;
        if (String(input).trim() !== MYSTERY_PASSWORD) {
            window.alert('密码不正确');
            return;
        }
        grantPortalAccess();
        window.location.href = PORTAL_URL;
    }

    function openMysteryEntry() {
        if (hasPortalAccess()) {
            window.location.href = PORTAL_URL;
            return;
        }
        var profilePromise = (window.AKB && typeof window.AKB.getProfile === 'function')
            ? window.AKB.getProfile()
            : Promise.resolve(null);
        Promise.resolve(profilePromise).then(function (profile) {
            if (isAdminProfile(profile)) {
                grantPortalAccess();
                window.location.href = PORTAL_URL;
            } else {
                askPortalPassword();
            }
        }, askPortalPassword);
    }

    // ---------- 面板 ----------
    function setOpen(open) {
        state.open = open;
        ui.panel.hidden = !open;
        ui.fab.setAttribute('aria-expanded', open ? 'true' : 'false');
        if (open) {
            loadTab(state.tab);
            refreshBadge();
        } else {
            stopPolling();
        }
    }

    function loadTab(tab, force) {
        state.tab = tab;
        ui.tabs.forEach(function (button) {
            button.classList.toggle('active', button.getAttribute('data-akb-tab') === tab);
        });
        ui.panes.forEach(function (pane) {
            pane.hidden = pane.getAttribute('data-akb-pane') !== tab;
        });
        if (!loggedIn()) {
            if (tab === 'system') ui.list.innerHTML = guestHtml('system');
            else ui.chatContacts.innerHTML = guestHtml('chat');
            return;
        }
        if (tab === 'system') {
            loadNotifications(force);
        } else if (tab === 'chat') {
            if (!state.contactsLoaded || force) loadContacts();
            else renderContacts();
        }
    }

    // ---------- 系统通知 ----------
    async function loadNotifications() {
        if (!state.client) return;
        if (!state.notifications.length) ui.list.innerHTML = '<div class="akb-notify-empty">正在加载…</div>';
        var result = await state.client
            .from('notifications')
            .select('id, kind, title, body, link, read_at, created_at')
            .order('created_at', { ascending: false })
            .limit(50);
        if (result.error) {
            ui.list.innerHTML = isMissingTable(result.error)
                ? hintHtml()
                : '<div class="akb-notify-empty">读取通知失败：' + esc(result.error.message) + '</div>';
            return;
        }
        state.notifications = result.data || [];
        renderNotifications();
        markNotificationsRead();
    }

    function renderNotifications() {
        if (!state.notifications.length) {
            ui.list.innerHTML = '<div class="akb-notify-empty">暂无系统通知</div>';
            return;
        }
        ui.list.innerHTML = state.notifications.map(function (item, index) {
            var unread = !item.read_at;
            return '<button type="button" class="akb-notify-item' + (unread ? ' unread' : '') + '" data-notify-index="' + index + '">' +
                '<div class="akb-notify-item-title">' +
                (unread ? '<span class="akb-notify-dot"></span>' : '') +
                esc(item.title || '通知') +
                '</div>' +
                (item.body ? '<div class="akb-notify-item-body">' + esc(item.body) + '</div>' : '') +
                '<div class="akb-notify-item-time">' + esc(fmtTime(item.created_at)) + '</div>' +
                '</button>';
        }).join('');
    }

    async function markNotificationsRead() {
        var ids = state.notifications.filter(function (item) { return !item.read_at; })
            .map(function (item) { return item.id; });
        if (!ids.length) return;
        var result = await state.client.from('notifications')
            .update({ read_at: new Date().toISOString() })
            .in('id', ids);
        if (!result.error) {
            state.notifications.forEach(function (item) { item.read_at = item.read_at || new Date().toISOString(); });
            refreshBadge();
        }
    }

    // ---------- 聊天：联系人 ----------
    async function loadContacts() {
        ui.chatContacts.innerHTML = '<div class="akb-notify-empty">正在加载…</div>';
        var result = await state.client.rpc('chat_directory', { p_query: null });
        if (result.error) {
            ui.chatContacts.innerHTML = isMissingTable(result.error) ||
                /function .* does not exist|Could not find the function/i.test(result.error.message || '')
                ? hintHtml()
                : '<div class="akb-notify-empty">读取联系人失败：' + esc(result.error.message) + '</div>';
            return;
        }
        state.contacts = result.data || [];
        state.contactsLoaded = true;
        renderContacts();
    }

    function renderContacts() {
        var keyword = (ui.chatSearch.value || '').trim().toLowerCase();
        var rows = state.contacts.filter(function (item) {
            if (!keyword) return true;
            return String(item.nickname || '').toLowerCase().indexOf(keyword) !== -1;
        });
        if (!rows.length) {
            ui.chatContacts.innerHTML = '<div class="akb-notify-empty">' +
                (state.contacts.length ? '没有匹配的用户' : '暂无可聊天用户') + '</div>';
            return;
        }
        ui.chatContacts.innerHTML = rows.map(function (item) {
            var name = item.nickname || '未命名用户';
            var avatar = item.avatar_url
                ? '<img class="akb-chat-avatar" src="' + esc(item.avatar_url) + '" alt="" loading="lazy">'
                : '<span class="akb-chat-avatar">' + esc(name.slice(0, 1)) + '</span>';
            return '<button type="button" class="akb-chat-contact" data-chat-peer="' + esc(item.id) + '">' +
                avatar + '<span class="akb-chat-contact-name">' + esc(name) + '</span>' +
                '</button>';
        }).join('');
    }

    // ---------- 聊天：会话 ----------
    function openThread(contact) {
        state.peer = contact;
        ui.chatPeerName.textContent = contact.nickname || '未命名用户';
        ui.chatListView.hidden = true;
        ui.chatThreadView.hidden = false;
        ui.chatError.hidden = true;
        ui.chatMessages.innerHTML = '<div class="akb-notify-empty">正在加载…</div>';
        loadMessages(true);
        startPolling();
    }

    function closeThread() {
        stopPolling();
        state.peer = null;
        state.messages = [];
        ui.chatThreadView.hidden = true;
        ui.chatListView.hidden = false;
        renderContacts();
    }

    function startPolling() {
        stopPolling();
        state.pollTimer = setInterval(function () {
            if (!state.open || state.tab !== 'chat' || !state.peer) return;
            loadMessages(false);
        }, 8000);
    }

    function stopPolling() {
        if (state.pollTimer) {
            clearInterval(state.pollTimer);
            state.pollTimer = null;
        }
    }

    async function fetchMessages() {
        var me = state.me;
        var peer = state.peer.id;
        var cols = 'id, sender_id, recipient_id, body, read_at, created_at';
        var pairFilter = 'and(sender_id.eq.' + me + ',recipient_id.eq.' + peer + '),' +
            'and(sender_id.eq.' + peer + ',recipient_id.eq.' + me + ')';
        var result = await state.client.from('chat_messages')
            .select(cols)
            .or(pairFilter)
            .order('created_at', { ascending: true })
            .limit(200);
        if (result.error) {
            // or() 组合语法在旧版 PostgREST 上可能不被支持：退回“我参与的消息”，再在前端筛出这一段会话
            var fallback = await state.client.from('chat_messages')
                .select(cols)
                .or('sender_id.eq.' + me + ',recipient_id.eq.' + me)
                .order('created_at', { ascending: true })
                .limit(500);
            if (fallback.error) return { error: fallback.error, data: [] };
            return {
                error: null,
                data: (fallback.data || []).filter(function (item) {
                    return (item.sender_id === me && item.recipient_id === peer) ||
                        (item.sender_id === peer && item.recipient_id === me);
                })
            };
        }
        return { error: null, data: result.data || [] };
    }

    async function loadMessages(scrollToBottom) {
        if (!state.client || !state.peer) return;
        var result = await fetchMessages();
        if (result.error) {
            ui.chatMessages.innerHTML = isMissingTable(result.error)
                ? hintHtml()
                : '<div class="akb-notify-empty">读取消息失败：' + esc(result.error.message) + '</div>';
            return;
        }
        state.messages = result.data;
        renderMessages(scrollToBottom);
        markMessagesRead();
    }

    function renderMessages(scrollToBottom) {
        if (!state.messages.length) {
            ui.chatMessages.innerHTML = '<div class="akb-notify-empty">还没有消息，打个招呼吧</div>';
            return;
        }
        var nearBottom = ui.chatMessages.scrollHeight - ui.chatMessages.scrollTop - ui.chatMessages.clientHeight < 60;
        ui.chatMessages.innerHTML = state.messages.map(function (item) {
            var mine = item.sender_id === state.me;
            return '<div class="akb-chat-msg ' + (mine ? 'me' : 'them') + '">' +
                esc(item.body) +
                '<span class="akb-chat-msg-time">' + esc(fmtTime(item.created_at)) + '</span>' +
                '</div>';
        }).join('');
        if (scrollToBottom || nearBottom) ui.chatMessages.scrollTop = ui.chatMessages.scrollHeight;
    }

    async function markMessagesRead() {
        if (!state.peer) return;
        var unread = state.messages.some(function (item) {
            return item.recipient_id === state.me && !item.read_at;
        });
        if (!unread) return;
        await state.client.from('chat_messages')
            .update({ read_at: new Date().toISOString() })
            .eq('recipient_id', state.me)
            .eq('sender_id', state.peer.id)
            .is('read_at', null);
        refreshBadge();
    }

    async function sendMessage(event) {
        event.preventDefault();
        if (!state.client || !state.peer || state.sending) return;
        var text = (ui.chatInput.value || '').trim();
        if (!text) return;
        state.sending = true;
        ui.chatSend.disabled = true;
        ui.chatError.hidden = true;
        var result = await state.client.from('chat_messages').insert({
            sender_id: state.me,
            recipient_id: state.peer.id,
            body: text.slice(0, 2000)
        });
        state.sending = false;
        ui.chatSend.disabled = false;
        if (result.error) {
            ui.chatError.textContent = '发送失败：' + result.error.message;
            ui.chatError.hidden = false;
            return;
        }
        ui.chatInput.value = '';
        await loadMessages(true);
    }

    // ---------- 未读角标 ----------
    // 通知：RLS 只返回自己的记录，未读即本人未读。
    // 私聊：只统计“别人发给我、我还没读”的消息；自己发出去的即使对方没读，也不算自己的未读。
    async function countUnread(table) {
        var query = state.client.from(table)
            .select('id', { count: 'exact', head: true })
            .is('read_at', null);
        if (table === 'chat_messages') {
            query = query.eq('recipient_id', state.me);
        }
        var result = await query;
        if (result.error) return 0;
        return result.count == null ? 0 : result.count;
    }

    async function refreshBadge() {
        if (!loggedIn()) {
            ui.badge.hidden = true;
            ui.badge.textContent = '';
            ui.countSystem.textContent = '';
            ui.countChat.textContent = '';
            return;
        }
        var values = await Promise.all([countUnread('notifications'), countUnread('chat_messages')]);
        var system = values[0];
        var chat = values[1];
        var total = system + chat;
        ui.badge.hidden = total === 0;
        ui.badge.textContent = total > 99 ? '99+' : String(total);
        ui.countSystem.textContent = system ? String(system) : '';
        ui.countChat.textContent = chat ? String(chat) : '';
    }

    // ---------- 启动 ----------
    async function init() {
        if (state.inited) return;
        state.inited = true;
        mount();
        if (!window.supabaseClient || !window.AKB) return;
        var session = null;
        try {
            session = await window.AKB.getSession();
        } catch (err) {
            session = null;
        }
        if (!session || !session.user) return;
        state.client = window.supabaseClient;
        state.me = session.user.id;
        refreshBadge();
        state.badgeTimer = setInterval(refreshBadge, 45000);
        // 登录态可能在首屏渲染后才拿到，若面板已经打开则补一次数据
        if (state.open) loadTab(state.tab);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
