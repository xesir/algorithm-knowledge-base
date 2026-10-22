vector<int> breakdown(int n) {
    vector<int> res;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) {
            while (n % i == 0) n /= i;
            res.push_back(i);
        }
    }
    if (n > 1) res.push_back(n);
    return res;
}
