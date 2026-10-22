// 返回gcd(a,b)，并输出x,y
ll exgcd(ll a, ll b, ll &x, ll &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
    ll d = exgcd(b, a % b, y, x); // 注意x和y的位置交换
    y -= (a / b) * x;             // 递推更新y
    return d;
}
// 解线性同余方程 ax ≡ b (mod m)，返回特解（无解返回-1）
ll sl(ll a, ll b, ll m) {
    ll x, y;
    ll d = exgcd(a, m, x, y);
    if (b % d != 0) return -1;
    ll m1 = m / d;
    x = (x * (b / d)) % m1;
    return (x + m1) % m1; // 确保解非负
}
