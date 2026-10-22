---
id: basic-base-conversion
title: '进制转换'
category: 基础算法
subcategory: 进制转换
subSubcategory: ''
tags: ["进制转换", "任意进制", "字符串", "枚举", "基础算法"]
timeComplexity: 'O(L)（L 为数字位数）'
spaceComplexity: 'O(L)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

> 自己看代码吧，我觉得没什么难理解的（疑似失去所有耐心和肝力）。

进制转换分两步走：先把 $n$ 进制的字符串转成十进制整数，再把十进制整数转成 $m$ 进制字符串。下面这份很短的实现里，`decin(n, sl)` 把 $n$ 进制串转十进制，`decout(m, sum)` 把十进制数转 $m$ 进制串。

- **转十进制**：从最低位（字符串末尾）开始，按位取值乘上 $n^i$ 累加。大于等于 `'A'` 的字母位用 `sl[i]-55` 换成数值（`'A'` 对应 10），数字位用 `sl[i]-48`。
- **转 $m$ 进制**：不断取余数 `n % m` 作为当前最低位，再 `n /= m`，最后把结果翻转。余数小于 10 直接转字符，否则 `+55` 转成字母。

## 逐行代码解析

### 模块一：n 进制串 → 十进制

```cpp
int decin(int n,string sl){
    int sum=0;vector<int> v;
    for(int i=sl.size()-1;i>=0;i--){
            if(sl[i]<65){
                v.push_back(sl[i]-48);
            }else{
                v.push_back(sl[i]-55);
            }
        }
        for(int i=0;i<v.size();i++){
            
            sum+=v[i]*pow(n,i);
        }
        return sum;
}
```

- 倒序遍历字符串，从末位（最低位）开始取数。
- `sl[i]-48` 处理数字字符 0~9，`sl[i]-55` 处理 `A` 及以上的大写字母（`'A'` = 65，减 55 得 10）。
- 第 $i$ 位的权重是 $n^i$，用 `pow(n,i)` 计算后乘上该位的值累加。

### 模块二：十进制 → m 进制串

```cpp
string decout(int m,int n){
    int u;string rl;
    while(n){
        u=n%m;
        if(u<10){
            rl+=u+48;
        }else{
            rl+=u+55;
        }
        n/=m;
    }
    reverse(rl.begin(),rl.end());
    return rl;
}
```

- 不断 `n % m` 取当前最低位，`n /= m` 往高位走，直到 `n` 变成 0。
- 余数 `u<10` 用 `u+48` 转成数字字符，否则 `u+55` 转成字母。
- 因为是从低位往高位生成的，最后要 `reverse` 回高位在前。

### 模块三：main 调用

```cpp
int main()
{
    long long n,m,sum=0;string sl;cin>>n>>sl>>m;
    sum=decin(n,sl);
    string re=decout(m,sum);
    cout<<re;
    return 0;
}
```

- 读入 $n$（原进制）、`sl`（$n$ 进制字符串）、$m$（目标进制）。
- 先用 `decin` 转成十进制中间值 `sum`，再用 `decout` 转成 $m$ 进制输出。

## 复杂度分析

- **时间复杂度**：$O(L)$，$L$ 为数字位数。`decin` 遍历一遍输入串，`decout` 的输出位数与 $L$ 同数量级。
- **空间复杂度**：$O(L)$，用于中间数组 `v` 和结果串 `rl`。

## 适用场景

- 给定进制互转的小规模题，比如把 $n$ 进制数转成 $m$ 进制输出。
- 进制只到 36（用 `A`~`Z` 表示 10~35）的场景，因为代码用 `+55` / `-55` 对应大写字母。

## 常见陷阱与注意事项

1. **权重用 `pow`**：`pow` 返回 `double`，位数一多会丢精度，大数场景建议改用高精度或整数快速幂。
2. **只认大写字母**：`sl[i]-55` 只覆盖 `A`~`Z`；若输入有小写字母要先转成大写。
3. **`decout` 没处理 0**：输入 0 时 `while(n)` 不进入循环，会返回空串；使用前最好特判 `n == 0`。
4. **翻转别忘**：`decout` 是从低位往高位生成的，不 `reverse` 得到的就是倒序结果。
5. **进制范围**：`n`、`m` 建议在 2~36 之间；小于 2 的进制没有意义。

## 对比与扩展

- **位数与类型**：想省事可以用 `std::stoi` / `sprintf` 之类，但它们只覆盖常见进制，且长度受 `int` / `long long` 限制。
- **高精度结合**：超大数的进制转换要先上高精度，否则中间十进制值会溢出。
- **扩展**：任意进制的小数转换、负数进制、以 $2^n$ 为基的进制可用位运算快速拆分与合并。
