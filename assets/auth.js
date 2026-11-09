/**
 * 全站共用的 Supabase 会话小工具。
 * 依赖：Supabase JS SDK + supabase-config.js（需先加载）。
 */
(function () {
    var AUTHOR_EMAIL_DOMAIN = 'authors.akb.example.com';

    function getClient() {
        return window.supabaseClient || null;
    }

    /** 联系方式 → Supabase Auth 邮箱。已含 @ 的按邮箱处理，其余使用站内专用域名。 */
    function contactToEmail(contact) {
        var value = String(contact || '').trim();
        if (!value) return '';
        if (value.indexOf('@') !== -1) return value.toLowerCase();
        var local = value.toLowerCase().replace(/[^a-z0-9._-]/g, '');
        return local ? local + '@' + AUTHOR_EMAIL_DOMAIN : '';
    }

    async function getSession() {
        var client = getClient();
        if (!client) return null;
        var result = await client.auth.getSession();
        return result.data ? result.data.session : null;
    }

    async function getUser() {
        var client = getClient();
        if (!client) return null;
        var result = await client.auth.getUser();
        return result.data ? result.data.user : null;
    }

    async function getProfile() {
        var client = getClient();
        var user = await getUser();
        if (!client || !user) return null;
        var base = 'id, nickname, contact, qq, luogu, cf, role, status';
        var withAvatar = base + ', avatar_url';
        var result = await client.from('profiles')
            .select(withAvatar + ', signature, honors')
            .eq('id', user.id)
            .single();
        // 兼容还没执行 phase16-author-profile-fields.sql 的数据库
        if (result.error && /signature|honors/i.test(result.error.message || '')) {
            result = await client.from('profiles')
                .select(withAvatar)
                .eq('id', user.id)
                .single();
            if (!result.error && result.data) {
                result.data.signature = '';
                result.data.honors = [];
            }
        }
        // 兼容还没执行 phase3-columns.sql 的数据库
        if (result.error && /avatar_url/i.test(result.error.message || '')) {
            result = await client.from('profiles')
                .select(base)
                .eq('id', user.id)
                .single();
            if (!result.error && result.data) {
                result.data.avatar_url = null;
                result.data.signature = '';
                result.data.honors = [];
            }
        }
        return result.error ? null : result.data;
    }

    async function signOutToLogin() {
        var client = getClient();
        try {
            if (client) await client.auth.signOut();
        } finally {
            window.location.href = 'login.html';
        }
    }

    function bindLogout() {
        document.querySelectorAll('#logout-link').forEach(function (link) {
            link.addEventListener('click', function (event) {
                event.preventDefault();
                signOutToLogin();
            });
        });
    }

    async function refreshAuthLinks() {
        var logoutLinks = document.querySelectorAll('#logout-link[data-auth-toggle="hide"]');
        var loginLinks = document.querySelectorAll('#login-link[data-auth-toggle="hide"]');
        var accountLinks = document.querySelectorAll('#account-link[data-auth-toggle="hide"]');
        if (!logoutLinks.length && !loginLinks.length && !accountLinks.length) return;
        var session = await getSession();
        logoutLinks.forEach(function (link) {
            link.style.display = session ? '' : 'none';
        });
        loginLinks.forEach(function (link) {
            link.style.display = session ? 'none' : '';
        });
        accountLinks.forEach(function (link) {
            link.style.display = session ? '' : 'none';
        });
    }

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function formatTime(value) {
        if (!value) return '—';
        var date = new Date(value);
        if (isNaN(date.getTime())) return String(value);
        return date.toLocaleString('zh-CN', { hour12: false });
    }

    window.AKB = {
        AUTHOR_EMAIL_DOMAIN: AUTHOR_EMAIL_DOMAIN,
        contactToEmail: contactToEmail,
        getSession: getSession,
        getUser: getUser,
        getProfile: getProfile,
        signOutToLogin: signOutToLogin,
        escapeHtml: escapeHtml,
        formatTime: formatTime
    };

    document.addEventListener('DOMContentLoaded', function () {
        bindLogout();
        refreshAuthLinks();
    });
})();
