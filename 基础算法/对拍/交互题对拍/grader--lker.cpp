#include <bits/stdc++.h>
#include "perm.h"
using namespace std;

namespace grader {
    int n;
    vector<int> p;

    int ask(const vector<int> &a) {
        vector<int> vis(n);
        for (int x : a) {
            if (x < 0 || x >= n) return -1;
            vis[x] = 1;
        }
        for (int i = 0; i < n; i++)
            if (!vis[i]) return i;
        return n;
    }

    int query(int l, int r) {
        if (l < 0 || l > r || r >= n) return -1;
        return ask(vector<int>(p.begin() + l, p.begin() + r + 1));
    }
}

int query(int l, int r) {
    return grader::query(l, r);
}

bool check(const vector<int> &p) {
    int n = p.size();
    grader::n = n, grader::p = p;
    vector<int> q = perm(n), vis(n);
    if ((int)q.size() != n) return false;

    for (int x : q) {
        if (x < 0 || x >= n || vis[x]) return false;
        vis[x] = 1;
    }
    for (int l = 0; l < n; l++)
        for (int r = l + 1; r < n; r++) {
            vector<int> a(p.begin() + l, p.begin() + r + 1);
            vector<int> b(q.begin() + l, q.begin() + r + 1);
            if (grader::ask(a) != grader::ask(b)) return false;
        }
    return true;
}

int main(int argc, char **argv) {
    int rounds = argc > 1 ? atoi(argv[1]) : 10000;
    bool ok = rounds > 0;

    for (int T = 1; T <= rounds && ok; T++) {
        if (system("./data > data.out")) {
            ok = false;
            break;
        }

        ifstream fin("data.out");
        int c, t;
        if (!(fin >> c >> t)) {
            ok = false;
            break;
        }
        init(c, t);

        while (t-- && ok) {
            int n;
            if (!(fin >> n) || n < 2) {
                ok = false;
                break;
            }

            vector<int> p(n), vis(n);
            for (int &x : p) fin >> x;
            if (!fin) {
                ok = false;
                break;
            }

            for (int x : p) {
                if (x < 0 || x >= n || vis[x]) {
                    ok = false;
                    break;
                }
                vis[x] = 1;
            }
            if (ok) ok = check(p);
        }
    }

    cout << (ok ? "Passed\n" : "Failed\n");
    return !ok;
}
