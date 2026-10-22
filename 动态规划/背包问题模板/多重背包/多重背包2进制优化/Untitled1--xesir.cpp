#include <bits/stdc++.h>
using namespace std;

struct Good
{
    int v,w;
};
const int N = 2010;
int n, m, dp[N];
vector<Good> a;

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; ++i)
    {
        int v, w, s; cin >> v >> w >> s;
        for (int k = 1; k <= s; k *= 2)
        {
            s -= k;
            a.push_back({v * k, w * k});
        }
        if (s > 0)
            a.push_back({v * s, w * s});
    }
    for (auto i : a)
        for (int j = m; j >= i.v; --j)
            dp[j] = max(dp[j], dp[j - i.v] + i.w);
    cout << dp[m] << endl;
    return 0;
}
