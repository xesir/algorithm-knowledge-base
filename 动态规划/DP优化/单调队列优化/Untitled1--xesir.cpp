int q[N], head = 1, tail = 0;
for (int i = 1; i <= n; i++) {
    int add = i - L;
    if (add >= 0 && f[add] > NEG) {
    while (head <= tail && f[q[tail]] <= f[add]) tail--;
        q[++tail] = add;
    }
    while (head <= tail && q[head] < i - R) head++;
    if (head <= tail) f[i] = a[i] + f[q[head]];
    else f[i] = NEG;
}
