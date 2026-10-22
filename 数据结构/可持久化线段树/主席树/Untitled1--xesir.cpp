#include <bits/stdc++.h>
using namespace std;

const int N = 200010;

int n, m, cnt;
int a[N], b[N];      // a原数组，b离散化数组
int rt[N];           // rt[i]表示第i个版本的根节点编号

struct node {
    int l, r;        // 左右儿子编号（注意不是区间端点！）
    int sum;         // 该节点值域区间内数字个数
} tr[N << 5];        // 一般开 N*20 到 N*40

int build(int l, int r) {
    int p = ++cnt;
    if (l == r) {
        tr[p].sum = 0;
        return p;
    }
    int mid = (l + r) >> 1;
    tr[p].l = build(l, mid);
    tr[p].r = build(mid + 1, r);
    tr[p].sum = tr[tr[p].l].sum + tr[tr[p].r].sum;
    return p;
}

int update(int pre, int l, int r, int x) {
    int p = ++cnt;
    tr[p] = tr[pre];   // 复制旧节点
    tr[p].sum++;       // 插入新数，频次+1
    if (l == r) return p;
    int mid = (l + r) >> 1;
    if (x <= mid) {
        tr[p].l = update(tr[pre].l, l, mid, x);
    } else {
        tr[p].r = update(tr[pre].r, mid + 1, r, x);
    }
    return p;
}

int query(int u, int v, int l, int r, int k) {
    if (l == r) return l;
    int mid = (l + r) >> 1;
    int left_cnt = tr[tr[u].l].sum - tr[tr[v].l].sum;
    if (k <= left_cnt) {
        return query(tr[u].l, tr[v].l, l, mid, k);
    } else {
        return query(tr[u].r, tr[v].r, mid + 1, r, k - left_cnt);
    }
}

int main() {
    scanf("%d%d", &n, &m);
    for (int i = 1; i <= n; i++) {
        scanf("%d", &a[i]);
        b[i] = a[i];
    }
    sort(b + 1, b + n + 1);
    int len = unique(b + 1, b + n + 1) - b - 1;

    rt[0] = build(1, len);
    for (int i = 1; i <= n; i++) {
        int x = lower_bound(b + 1, b + len + 1, a[i]) - b;
        rt[i] = update(rt[i - 1], 1, len, x);
    }

    while (m--) {
        int l, r, k;
        scanf("%d%d%d", &l, &r, &k);
        int pos = query(rt[r], rt[l - 1], 1, len, k);
        printf("%d\n", b[pos]);
    }
    return 0;
}
