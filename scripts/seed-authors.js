#!/usr/bin/env node
/**
 * 批量创建作者账号并初始化 column_locks。
 *
 * 前置：
 *   1. 在 Supabase SQL Editor 执行 supabase/phase2.sql
 *   2. 设置环境变量（service_role key 只在本机使用，绝不写入前端）
 *        PowerShell:
 *          $env:SUPABASE_URL="https://xxxx.supabase.co"
 *          $env:SUPABASE_SERVICE_ROLE_KEY="eyJ..."
 *          node scripts/seed-authors.js
 *
 * 密码文件默认读取：../../临时文件/数据/初始密码.txt（每行：用户名 密码）
 * 可用 PASSWORD_FILE 环境变量覆盖路径。
 */
const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');

const SUPABASE_URL = (process.env.SUPABASE_URL || '').replace(/\/+$/, '');
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || '';
const PASSWORD_FILE = process.env.PASSWORD_FILE
    ? path.resolve(process.env.PASSWORD_FILE)
    : path.resolve(__dirname, '../../临时文件/数据/初始密码.txt');
const EMAIL_DOMAIN = 'authors.akb.example.com';
const ADMIN_NAME = 'world-needs-sunday';

function fail(message) {
    console.error('✗ ' + message);
    process.exit(1);
}

if (!SUPABASE_URL || !SERVICE_KEY) {
    fail('请先设置 SUPABASE_URL 与 SUPABASE_SERVICE_ROLE_KEY（service_role，仅本机使用）');
}
if (!fs.existsSync(PASSWORD_FILE)) {
    fail('找不到密码表：' + PASSWORD_FILE);
}

function readAuthors(file) {
    return fs.readFileSync(file, 'utf8')
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter((line) => line && !line.startsWith('#'))
        .map((line) => {
            const parts = line.split(/\s+/);
            return parts.length >= 2 ? { name: parts[0], password: parts.slice(1).join(' ') } : null;
        })
        .filter(Boolean);
}

function request(method, pathname, body, extraHeaders) {
    return new Promise((resolve, reject) => {
        const url = new URL(SUPABASE_URL + pathname);
        const payload = body == null ? null : JSON.stringify(body);
        const headers = Object.assign({
            apikey: SERVICE_KEY,
            Authorization: 'Bearer ' + SERVICE_KEY,
            'Content-Type': 'application/json'
        }, extraHeaders || {});
        if (payload) headers['Content-Length'] = Buffer.byteLength(payload);

        const req = (url.protocol === 'http:' ? http : https).request({
            hostname: url.hostname,
            port: url.port || (url.protocol === 'http:' ? 80 : 443),
            path: url.pathname + url.search,
            method,
            headers
        }, (res) => {
            let raw = '';
            res.on('data', (chunk) => { raw += chunk; });
            res.on('end', () => {
                let data = null;
                try { data = raw ? JSON.parse(raw) : null; } catch (error) { data = raw; }
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(data);
                    return;
                }
                const err = new Error(
                    method + ' ' + pathname + ' → ' + res.statusCode + ' ' +
                    (typeof data === 'string' ? data : JSON.stringify(data))
                );
                err.status = res.statusCode;
                err.data = data;
                reject(err);
            });
        });
        req.on('error', reject);
        if (payload) req.write(payload);
        req.end();
    });
}

async function findUserByEmail(email) {
    const data = await request('GET', '/auth/v1/admin/users?page=1&per_page=1000');
    const users = Array.isArray(data) ? data : (data && data.users) || [];
    return users.find((user) => (user.email || '').toLowerCase() === email.toLowerCase()) || null;
}

async function ensureUser(author) {
    const email = author.name.toLowerCase() + '@' + EMAIL_DOMAIN;
    try {
        const created = await request('POST', '/auth/v1/admin/users', {
            email: email,
            password: author.password,
            email_confirm: true,
            user_metadata: {
                nickname: author.name
            }
        });
        const user = created && created.user ? created.user : created;
        return { user: user, email: email, created: true };
    } catch (error) {
        if (error.status !== 422 && error.status !== 400) throw error;
        const existing = await findUserByEmail(email);
        if (!existing) throw new Error('用户已存在但找不到：' + email + '（' + error.message + '）');
        await request('PUT', '/auth/v1/admin/users/' + existing.id, {
            password: author.password,
            email_confirm: true,
            user_metadata: {
                nickname: author.name
            }
        });
        return { user: existing, email: email, created: false };
    }
}

async function upsertProfile(user, author) {
    await request('POST', '/rest/v1/profiles', {
        id: user.id,
        nickname: author.name,
        contact: null,
        qq: null,
        luogu: null,
        cf: null,
        role: author.name === ADMIN_NAME ? 'admin' : 'user',
        status: 'active'
    }, { Prefer: 'resolution=merge-duplicates,return=minimal' });
}

async function upsertColumn(user, author) {
    try {
        await request('POST', '/rest/v1/columns?on_conflict=column_key', {
            owner_id: user.id,
            column_key: author.name,
            column_name: author.name
        }, { Prefer: 'resolution=merge-duplicates,return=minimal' });
    } catch (error) {
        // phase3-columns.sql 还没执行时允许跳过，后续可用 bind-author-columns.sql 补绑
        console.warn('⚠ 专栏表未初始化，跳过 ' + author.name + ' 的 columns 记录');
    }
}

async function setLock(user, key, password, columnName) {
    await request('POST', '/rest/v1/rpc/admin_set_column_password', {
        p_user_id: user.id,
        p_key: key,
        p_password: password,
        p_column_name: columnName
    });
}

async function verifyLock(key, password) {
    try {
        return await request('POST', '/rest/v1/rpc/verify_column_password', {
            p_key: key,
            p_password: password
        });
    } catch (error) {
        return null;
    }
}

async function main() {
    const authors = readAuthors(PASSWORD_FILE);
    if (!authors.length) fail('密码表为空：' + PASSWORD_FILE);

    console.log('读取到 ' + authors.length + ' 位作者：' + authors.map((a) => a.name).join('、'));
    console.log('Supabase：' + SUPABASE_URL);
    console.log('');

    for (const author of authors) {
        const ensured = await ensureUser(author);
        await upsertProfile(ensured.user, author);
        await upsertColumn(ensured.user, author);
        await setLock(ensured.user, author.name, author.password, author.name);
        await setLock(ensured.user, '__default__', author.password, '默认专栏访问密码');
        const ok = await verifyLock(author.name, author.password);
        console.log(
            (ensured.created ? '✓ 新建 ' : '✓ 复用 ') + author.name +
            ' <' + ensured.email + '> · profile=active/role=' +
            (author.name === ADMIN_NAME ? 'admin' : 'user') +
            ' · column_locks=2' +
            (ok === true ? ' · 密码校验通过' : ok === false ? ' · ⚠ 密码校验失败' : ' · 校验跳过')
        );
    }

    console.log('');
    console.log('完成。作者可用「用户名 + 初始密码」在 login.html 登录。');
}

main().catch((error) => fail(error && error.message ? error.message : String(error)));
