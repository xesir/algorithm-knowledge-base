#include <bits/stdc++.h>
using namespace std;
const int N = 100010;
int a[N], d[N];

int main() {
    int n; cin >> n;
    for (int i = 1; i <= n; i++) cin >> a[i];
    
    int len = 0;
    d[0] = -1e9; // 哨兵，防止边界
    for (int i = 1; i <= n; i++) {
        int pos = lower_bound(d + 1, d + len + 1, a[i]) - d; // 第一个 >= a[i] 的位置
        if (pos > len) { // 没找到，追加
            d[++len] = a[i];
        } else { // 替换
            d[pos] = a[i];
        }
    }
    cout << len << endl;
    return 0;
}
