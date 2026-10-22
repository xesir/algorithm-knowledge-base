ll gcd(ll a, ll b) {
    while (b != 0) {
        ll temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}
int gcd(int a, int b) {
    if (!a || !b) return a | b;
    int aa = __builtin_ctz(a), bb = __builtin_ctz(b), k = min(aa, bb);
    b >>= bb;
    while (a) {
        a >>= aa;
        int tmp = b - a;
        aa = __builtin_ctz(tmp);
        b = min(a, b);
        a = abs(tmp);
    }
    return b << k;
}
ll lcm(ll a, ll b) {
    return a / gcd(a, b) * b;
}
