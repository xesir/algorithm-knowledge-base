import { SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY } from './config.js';

let client = null;
let initialized = false;
let sdkPromise = null;

function sdkSources() {
    return [
        new URL('assets/supabase.min.js', document.baseURI).href,
        'https://fastly.jsdelivr.net/npm/@supabase/supabase-js@2'
    ];
}

/** 是否具备联网条件（SDK 已加载）。离线发行包会返回 false。 */
export function isOnlineSupported() {
    return typeof window.supabase !== 'undefined' && typeof window.supabase.createClient === 'function';
}

function loadScript(url, timeout) {
    return new Promise(resolve => {
        const script = document.createElement('script');
        let settled = false;
        const finish = ok => {
            if (settled) return;
            settled = true;
            window.clearTimeout(timer);
            resolve(ok);
        };
        const timer = window.setTimeout(() => finish(false), timeout);
        script.src = url;
        script.async = true;
        script.onload = () => finish(isOnlineSupported());
        script.onerror = () => finish(false);
        document.head.appendChild(script);
    });
}

/**
 * 按需加载 Supabase JS SDK：优先本地 assets/supabase.min.js，
 * 失败后退到 fastly 镜像。全部失败时返回 false，
 * 页面其余单机功能不受影响。
 */
export function loadSdk() {
    if (isOnlineSupported()) return Promise.resolve(true);
    if (sdkPromise) return sdkPromise;
    sdkPromise = (async () => {
        const sources = sdkSources();
        for (let index = 0; index < sources.length; index++) {
            const isLocal = index === 0;
            const ok = await loadScript(sources[index], isLocal ? 4000 : 8000);
            if (ok) {
                initialized = false;
                return true;
            }
        }
        return false;
    })();
    return sdkPromise;
}

/**
 * 获取 Supabase 客户端单例。SDK 未加载时返回 null，调用方需要给用户提示。
 */
export function getClient() {
    if (client) return client;
    if (initialized) return null;
    initialized = true;
    if (!isOnlineSupported()) {
        console.warn('[TreeGrow] Supabase SDK 未加载，联机功能不可用。');
        return null;
    }
    try {
        client = window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
            auth: {
                persistSession: true,
                autoRefreshToken: true,
                detectSessionInUrl: true
            }
        });
    } catch (error) {
        console.error('[TreeGrow] Supabase 初始化失败', error);
        client = null;
    }
    return client;
}

export function requireClient() {
    const instance = getClient();
    if (!instance) throw new Error('联机服务不可用：请联网后刷新页面');
    return instance;
}
