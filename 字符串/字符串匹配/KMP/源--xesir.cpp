for (int i = 2, j = 0; i <= m; i++) {
    while (j && t[j + 1] != t[i]) j = nxt[j];
    if (t[j + 1] == t[i]) j++;
    nxt[i] = j;
}
for (int i = 1, j = 0; i <= n; i++) {
    while (j && t[j + 1] != s[i]) j = nxt[j];
    if (t[j + 1] == s[i]) j++;
    if (j == m) {
        cout << i - m + 1 << '\n';
        j = nxt[j];
    }
}
