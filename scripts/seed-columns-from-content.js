#!/usr/bin/env node
/**
 * 把 content/ 与 problems/ 中已在库的 Markdown 批量生成 Supabase columns 种子 SQL。
 *
 * 用法：
 *   node scripts/seed-columns-from-content.js
 *   node scripts/seed-columns-from-content.js --dry-run
 *   node scripts/seed-columns-from-content.js --only=knowledge
 *   node scripts/seed-columns-from-content.js --only=problems
 *
 * 产出：supabase/seed-columns/NN-<分类>.sql（UTF-8，可在 Supabase SQL Editor 逐个执行）
 *
 * 规则：
 *   - 文件名 xxx.md        → 作者按 frontmatter.source 识别，识别不到归 world-needs-sunday
 *   - 文件名 xxx--key.md   → 作者按 build.js 的 AUTHOR_KEYS 映射（base 仍为 xxx）
 *   - column_key = col-<baseId>（主文件） / col-<baseId>--<key>（作者版本）
 *   - column_name = 标题；作者版本追加「 · 作者」
 *   - content = frontmatter 之后的正文（与 build.js 一致）
 *   - 按 column_key upsert，可重复执行
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const CONTENT_DIR = path.join(ROOT, 'content');
const PROBLEMS_DIR = path.join(ROOT, 'problems');
const GRAPH_FILE = path.join(ROOT, 'knowledge_graph.json');
const OUT_DIR = path.join(ROOT, 'supabase', 'seed-columns');

// 与 build.js 保持一致；新增作者时两处一起改
const AUTHOR_KEYS = {
    fenfeng: 'Fohen',
    xesir: 'Xesir',
    lker: 'lker',
    'stripe-python': 'stripe-python',
    renzhaoyang: 'renzhaoyang',
    dbywsc: 'dbywsc'
};
const KNOWN_AUTHORS = [
    'world-needs-sunday', 'stripe-python', 'renzhaoyang', 'dbywsc', 'Xesir', 'Fohen', 'lker'
];
const CATEGORY_ORDER = ['基础算法', '动态规划', '数据结构', '图论', '数学', '字符串', '实用工具', '初赛笔记', '未分类'];
const CATEGORY_SLUG = {
    '基础算法': 'basic',
    '动态规划': 'dp',
    '数据结构': 'ds',
    '图论': 'graph',
    '数学': 'math',
    '字符串': 'str',
    '实用工具': 'utility',
    '初赛笔记': 'exam',
    '未分类': 'misc'
};
const MAX_FILE_CHARS = 600000;

function parseFrontmatter(text) {
    const fmMatch = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/);
    if (!fmMatch) return { meta: {}, body: text };

    const yamlText = fmMatch[1];
    const body = fmMatch[2];
    const meta = {};

    yamlText.split(/\r?\n/).forEach(line => {
        const m = line.match(/^(\w+):\s*(.*)$/);
        if (!m) return;
        const key = m[1];
        let val = m[2].trim();
        if (val.startsWith('[') && val.endsWith(']')) {
            val = val.slice(1, -1).split(',').map(s => s.trim().replace(/^["']|["']$/g, ''));
        } else {
            val = val.replace(/^["']|["']$/g, '');
        }
        meta[key] = val;
    });

    return { meta, body };
}

function clean(value) {
    return value == null ? '' : String(value).replace(/^["']|["']$/g, '').trim();
}

function authorFromSource(source) {
    const text = clean(source);
    if (!text) return null;
    const lower = text.toLowerCase();
    for (const name of KNOWN_AUTHORS) {
        if (lower.includes(name.toLowerCase())) return name;
    }
    return null;
}

function sqlText(value) {
    return "'" + String(value == null ? '' : value).replace(/'/g, "''") + "'";
}

function sqlDollar(text, index) {
    let tag = 'AKB' + index;
    while (String(text).includes('$' + tag + '$')) tag += '_';
    return '$' + tag + '$' + text + '$' + tag + '$';
}

function tagsSql(tags) {
    if (!Array.isArray(tags) || !tags.length) return 'null';
    return 'array[' + tags.map(sqlText).join(', ') + ']';
}

function loadGraph() {
    if (!fs.existsSync(GRAPH_FILE)) return { knowledgePoints: {} };
    return JSON.parse(fs.readFileSync(GRAPH_FILE, 'utf8'));
}

function collectRecords() {
    const graph = loadGraph();
    const records = [];

    function addFile(kind, dir, filename) {
        const filepath = path.join(dir, filename);
        const raw = fs.readFileSync(filepath, 'utf8');
        const { meta, body } = parseFrontmatter(raw);
        const baseName = path.basename(filename, '.md');
        const dashIdx = baseName.indexOf('--');
        const isVersion = dashIdx >= 0;
        let baseId = baseName;
        let versionKey = '';
        let author;

        if (isVersion) {
            versionKey = baseName.slice(dashIdx + 2);
            baseId = baseName.slice(0, dashIdx);
            author = AUTHOR_KEYS[versionKey] || versionKey;
        } else {
            author = authorFromSource(meta.source) || 'world-needs-sunday';
        }

        const title = clean(meta.title) || baseId;
        const category = clean(meta.category) || '未分类';
        const tags = Array.isArray(meta.tags) ? meta.tags : (meta.tags ? [clean(meta.tags)] : []);
        const columnName = isVersion ? title + ' · ' + author : title;
        let parentKey = null;
        if (kind === 'knowledge') {
            const entry = (graph.knowledgePoints || {})[baseId];
            if (entry && entry.parent) parentKey = 'col-' + entry.parent;
        }
        const difficulty = kind === 'problem' ? (clean(meta.difficulty) || null) : null;

        records.push({
            kind,
            author,
            columnKey: 'col-' + baseId + (isVersion ? '--' + versionKey : ''),
            columnName,
            content: body.trim(),
            category,
            tags,
            parentKey,
            difficulty,
            sourceFile: filename
        });
    }

    fs.readdirSync(CONTENT_DIR).filter(f => f.endsWith('.md')).sort()
        .forEach(f => addFile('knowledge', CONTENT_DIR, f));
    fs.readdirSync(PROBLEMS_DIR).filter(f => f.endsWith('.md')).sort()
        .forEach(f => addFile('problem', PROBLEMS_DIR, f));
    return records;
}

function categoryIndex(category) {
    const idx = CATEGORY_ORDER.indexOf(category);
    return idx === -1 ? CATEGORY_ORDER.length : idx;
}

function groupRecords(records) {
    const groups = new Map();
    records.forEach(record => {
        const key = record.kind + '|' + record.category;
        if (!groups.has(key)) {
            groups.set(key, {
                kind: record.kind,
                category: record.category,
                records: []
            });
        }
        groups.get(key).records.push(record);
    });
    return Array.from(groups.values()).sort((a, b) => {
        if (a.kind !== b.kind) return a.kind === 'knowledge' ? -1 : 1;
        return categoryIndex(a.category) - categoryIndex(b.category);
    });
}

function chunkRecords(records) {
    const chunks = [];
    let current = [];
    let size = 0;
    records.forEach(record => {
        const estimate = record.content.length + 700;
        if (current.length && size + estimate > MAX_FILE_CHARS) {
            chunks.push(current);
            current = [];
            size = 0;
        }
        current.push(record);
        size += estimate;
    });
    if (current.length) chunks.push(current);
    return chunks;
}

let globalRowIndex = 0;
function rowSql(record) {
    globalRowIndex += 1;
    return '(' + [
        sqlText(record.author),
        sqlText(record.columnKey),
        sqlText(record.columnName),
        sqlDollar(record.content, globalRowIndex),
        sqlText(record.category),
        tagsSql(record.tags),
        record.parentKey ? sqlText(record.parentKey) : 'null',
        record.difficulty ? sqlText(record.difficulty) : 'null',
        sqlText(record.kind)
    ].join(', ') + ')';
}

function sqlFileContent(group, rows) {
    const kindLabel = group.kind === 'knowledge' ? '知识点' : '题目';
    return `-- ============================================================
-- AKB 专栏种子：${kindLabel} / ${group.category}
-- 生成脚本：scripts/seed-columns-from-content.js
-- 前置：phase2 → phase7 已执行；profiles 中已有对应作者账号
-- 用法：在 Supabase SQL Editor 整段执行；可重复执行（按 column_key upsert）
-- 本文件：${rows.length} 行
-- ============================================================
begin;

drop table if exists _akb_seed_columns;
create temp table _akb_seed_columns (
    author_name text not null,
    column_key text not null,
    column_name text not null,
    content text not null,
    category text,
    tags text[],
    parent_key text,
    difficulty text,
    kind text not null
) on commit drop;

insert into _akb_seed_columns (
    author_name, column_key, column_name, content, category, tags, parent_key, difficulty, kind
) values
${rows.map(rowSql).join(',\n')};

do $$
declare
    v_missing text;
begin
    select string_agg(distinct s.author_name, '、') into v_missing
    from _akb_seed_columns s
    left join public.profiles p on p.nickname = s.author_name
    where p.id is null;

    if v_missing is not null then
        raise exception '缺少作者 profile：%', v_missing;
    end if;
end $$;

insert into public.columns (
    owner_id, column_key, column_name, content, tags, category, parent_key,
    relations, difficulty, kind, status
)
select
    p.id, s.column_key, s.column_name, s.content, s.tags, s.category,
    s.parent_key, '[]'::jsonb, s.difficulty, s.kind, 'published'
from _akb_seed_columns s
join public.profiles p on p.nickname = s.author_name
on conflict (column_key) do update
set owner_id = excluded.owner_id,
    column_name = excluded.column_name,
    content = excluded.content,
    tags = excluded.tags,
    category = excluded.category,
    parent_key = excluded.parent_key,
    difficulty = excluded.difficulty,
    kind = excluded.kind,
    status = 'published',
    updated_at = now();

drop table if exists _akb_seed_columns;

commit;
`;
}

function main() {
    const dryRun = process.argv.includes('--dry-run');
    const onlyArg = process.argv.find(arg => arg.startsWith('--only='));
    const only = onlyArg ? onlyArg.split('=')[1] : null;

    let records = collectRecords();
    if (only === 'knowledge' || only === 'problems') {
        records = records.filter(record => record.kind === (only === 'knowledge' ? 'knowledge' : 'problem'));
    }

    const groups = groupRecords(records);
    if (!dryRun) {
        fs.mkdirSync(OUT_DIR, { recursive: true });
        fs.readdirSync(OUT_DIR)
            .filter(name => /^\d{2,}-.*\.sql$/.test(name))
            .forEach(name => fs.unlinkSync(path.join(OUT_DIR, name)));
    }

    let fileIndex = 0;
    const summary = [];
    groups.forEach(group => {
        const chunks = chunkRecords(group.records);
        chunks.forEach((rows, chunkIndex) => {
            fileIndex += 1;
            const kindSlug = group.kind === 'knowledge' ? 'knowledge' : 'prob';
            const categorySlug = CATEGORY_SLUG[group.category] || 'misc';
            const part = chunks.length > 1 ? '-p' + (chunkIndex + 1) : '';
            const filename = String(fileIndex).padStart(2, '0') + '-' + kindSlug + '-' + categorySlug + part + '.sql';
            const content = sqlFileContent(group, rows);
            if (!dryRun) {
                fs.writeFileSync(path.join(OUT_DIR, filename), content, 'utf8');
            }
            summary.push({
                file: filename,
                kind: group.kind,
                category: group.category,
                rows: rows.length,
                chars: content.length
            });
        });
    });

    const knowledgeRows = records.filter(record => record.kind === 'knowledge').length;
    const problemRows = records.filter(record => record.kind === 'problem').length;
    const authorCounts = {};
    records.forEach(record => {
        authorCounts[record.author] = (authorCounts[record.author] || 0) + 1;
    });

    console.log('知识点行：' + knowledgeRows);
    console.log('题目行：' + problemRows);
    console.log('作者分布：', authorCounts);
    console.log('\n生成文件：');
    summary.forEach(item => {
        console.log('  ' + item.file + '  ' + item.kind + '/' + item.category +
            '  ' + item.rows + ' 行  ' + (item.chars / 1024).toFixed(1) + ' KB');
    });
    console.log('\n输出目录：' + path.relative(ROOT, OUT_DIR));
    if (dryRun) console.log('（--dry-run：未写入文件）');
}

main();
