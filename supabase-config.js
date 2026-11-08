/**
 * Supabase 连接配置（前端公开信息）
 *
 * 使用前把下面两项换成 Supabase 控制台 → Project Settings → API 里的值：
 *   url     = Project URL（形如 https://xxxx.supabase.co）
 *   anonKey = anon public key / publishable key
 *
 * 注意：这里只能放 anon / publishable key。service_role / secret key 拥有绕过 RLS 的权限，
 * 绝对不能出现在静态站点里。
 *
 * 未填写时 window.supabaseClient 为 null，页面只展示 UI，不会发起任何请求。
 */
window.SUPABASE_CONFIG = {
    url: 'https://ajgixlgytxhrsmhnzsmg.supabase.co',
    anonKey: 'sb_publishable_UODhtjUPWCUS6gR-ZCH2AA_KbqeguhB'
};

(function () {
    var cfg = window.SUPABASE_CONFIG;
    var url = (cfg.url || '').trim();
    var anonKey = (cfg.anonKey || '').trim();
    var isPlaceholder = !url || !anonKey || url.indexOf('YOUR_') === 0 || anonKey.indexOf('YOUR_') === 0;

    window.supabaseClient = null;
    window.supabaseStatus = {
        configured: !isPlaceholder,
        connected: false,
        message: ''
    };

    if (isPlaceholder) {
        window.supabaseStatus.message = '未配置：请在 supabase-config.js 填入 Project URL 与 anon key';
        console.warn('[Supabase] ' + window.supabaseStatus.message);
        return;
    }

    if (typeof window.supabase === 'undefined' || typeof window.supabase.createClient !== 'function') {
        window.supabaseStatus.message = 'SDK 未加载：请检查 Supabase JS SDK 的引入地址';
        console.warn('[Supabase] ' + window.supabaseStatus.message);
        return;
    }

    try {
        window.supabaseClient = window.supabase.createClient(url, anonKey, {
            auth: {
                persistSession: true,
                autoRefreshToken: true,
                detectSessionInUrl: true
            }
        });
        window.supabaseStatus.connected = true;
        window.supabaseStatus.message = '已连接 Supabase（Auth / Database）';
    } catch (err) {
        window.supabaseStatus.message = '初始化失败：' + (err && err.message ? err.message : String(err));
        console.error('[Supabase] 初始化失败', err);
    }
})();
