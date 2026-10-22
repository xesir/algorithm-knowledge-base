//#fjaknoipjdfjnfvwcjndnzredvkdvnjnjnjnstonedjnshyakioixklhywkskblkkskzdjdwqbzs
#include <bits/stdc++.h>
using namespace std;
#define int long long
const int mod = 1000000007;
const int N = 1000010;
int jcr[N], nyj[N];
int D[N];
// 快速幂：计算 x^y % p
int ksm(int x, int y, int p) {
    int res = 1 % p;
    x %= p;

    while (y > 0) {
        if (y & 1) {
            res = res * x % p;
        }
        x = x * x % p;
        y >>= 1;
    }
    return res;
}
// 阶乘与阶乘逆元预处理
// jcr[i] = i!
// nyj[i] = (i!)^(-1)
void jiecycl(int n) {
    n = min(n, N - 1);
    jcr[0] = 1;
    for (int i = 1; i <= n; i++) {
        jcr[i] = jcr[i - 1] * i % mod;
    }
    // 费马小定理：a^(mod-2) ≡ a^(-1) (mod mod)
    nyj[n] = ksm(jcr[n], mod - 2, mod);
    for (int i = n; i >= 1; i--) {
        nyj[i - 1] = nyj[i] * i % mod;
    }
}
// 组合数：C(n, k)
int cabz(int n, int k) {
    if (n < 0 || k < 0 || k > n || n >= N) {
        return 0;
    }

    return jcr[n] * nyj[k] % mod * nyj[n - k] % mod;
}
// 错排数
int dcp(int n) {
    if (n == 0) return 1;
    if (n == 1) return 0;
    if (n == 2) return 1;
    if (n >= N) return 0;
    if (D[n] != 0) {
        return D[n];
    }
    D[n] = (n - 1) * (dcp(n - 1) + dcp(n - 2)) % mod;
    return D[n];
}
int cp[N];
int xdm(int n) {
    if (n == 0) return 1;
    if (n == 1) return 0;
    if (n >= N) return 0;
    if (cp[n] != 0) return cp[n];
    cp[n] = (xdm(n - 1) + xdm(n - 2)) * (n - 1) % mod;
    return cp[n];
}
// 排列数：P(n, m)
int pls(int n, int m, int p) {
    if (m < 0 || m > n || p <= 0) {
        return 0;
    }
    int res = 1 % p;
    for (int i = n - m + 1; i <= n; i++) {
        res = res * (i % p) % p;
    }
    return res;
}
vector<int> dp(200000 + 1, 0);
// 卡特兰数
int catalan(int n) {
    if (n < 0 || n >= (int)dp.size()) {
        return 0;
    }
    // Cat(n) = sum(Cat(i) * Cat(n-1-i))
    dp[0] = 1;
    if (n == 0) {
        return dp[0];
    }
    dp[1] = 1;
    for (int i = 2; i <= n; i++) {
        for (int j = 0; j < i; j++) {
            dp[i] = (dp[i] + dp[j] * dp[i - 1 - j]) % mod;
        }
    }
    return dp[n];
}
signed main() {
    int n;cin >> n;
    if (n >= 0 && 2 * n < N) {
        jiecycl(min(2 * n, N - 1));
    }
    return 0;
}
