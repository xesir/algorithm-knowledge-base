for (int mask = 0; mask < (1 << n); mask++)
    for (int sub = mask; ; sub = (sub - 1) & mask) {
        F[mask] += f[sub];
        if (sub == 0) break;
    }

for (int i = 0; i < n; i++)          // 枚举每一位
    for (int mask = 0; mask < (1 << n); mask++)
        if (mask & (1 << i))         // 如果这一位是 1
            f[mask] += f[mask ^ (1 << i)];

for (int i = 0; i < n; i++)
    for (int mask = 0; mask < (1 << n); mask++)
        if (mask & (1 << i))
            f[mask] += f[mask ^ (1 << i)];

for (int i = 0; i < n; i++)
    for (int mask = 0; mask < (1 << n); mask++)
        if (!(mask & (1 << i)))
            f[mask] += f[mask | (1 << i)];
