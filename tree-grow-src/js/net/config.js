/**
 * 生长树联机配置。
 *
 * 复用 algorithm-knowledge-base 的 Supabase 项目，只使用 publishable key，
 * 绝不能把 service_role / secret key 放进前端。
 */
export const SUPABASE_URL = 'https://ajgixlgytxhrsmhnzsmg.supabase.co';
export const SUPABASE_PUBLISHABLE_KEY = 'sb_publishable_UODhtjUPWCUS6gR-ZCH2AA_KbqeguhB';

/** 神秘入口的普通用户通行密码（前端校验，只能防误触）。 */
export const MYSTERY_PASSWORD = 'gcx34580';

export const PORTAL_ACCESS_KEY = 'treeGrow:portalAccess:v1';
export const PLAYER_NAME_KEY = 'treeGrow:playerName:v1';
