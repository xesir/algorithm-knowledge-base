---
id: basic-high-precision
title: '高精度算法（大整数加减乘除模板）'
category: 基础算法
subcategory: 高精度
subSubcategory: ''
tags: ["高精度", "大整数", "字符串模拟", "竖式运算", "进位借位"]
timeComplexity: '加减 O(n)，高精乘 O(n·m)，除低精 O(n)'
spaceComplexity: 'O(n+m)'
level: A
noCode: true
verified: 2026-10-20
source: 'Xesir'
---

## 算法原理

高精度计算（Arbitrary-Precision Arithmetic），也被称作**大整数（bignum）计算**：利用字符串来实现大整数加减乘除。

C++ 里 `int` 最大约 $2^{31}-1$，`long long` 也就 $9\times10^{18}$，题目里的数字一大就没法存，只能自己用字符串/数组模拟竖式。一般处理的数据在 $10^{500}$ 以下（准确地说，在 $10^{200}\sim10^{500}$ 之间），超过 $10^{1000}$ 会有压位提示。

> 高精度部分由蒟蒻 **RedStone** 友情提供qwq（所以下文都是以 RedStone 的码风及思路来写辣awa）。~~我是个蒟蒻 代码又臭又长~~，所以高精度除高精度就交给拖更王 GOC 辣。下文「存储」等板块主要介绍思想，代码较少；如果只是需要模板，翻到本板块最下方拿。

### 存储：为什么要倒序

正常来说，数字存储「应该」从数组的低位开始对吧~~（笑）~~。所以我们输入输出时要**倒序处理**，让下标 0 对应个位，方便从低位往高位处理进位。倒序有多种方法：倒序数组存储、指针倒序遍历或者 `reverse()`；下面先给数组倒序处理，模板里用的是指针倒序遍历。

> 插一句，string 可以当做一个 char 数组使用，只不过 char 数组定长、string 不定长，所以使用 char 数组也是可以的。

### 运算：加、减、乘、除

加法与减法最简单，可以借鉴竖式的思想，从最低位一位一位处理。**需要注意：负数、进位、借位。**

- **负数处理**：分类讨论正负号（正正、正负、负正、负负），把异号情形变号后转换成同号运算，最后再补上结果的正负。比如 $a+(-b)=a-b$、$a-(-b)=a+b$ 的道理能明白吧。
- **进位处理**：逢 10 进 1；加法取较短长度，最后若还有进位要 `c[i+1]++`。
- **借位处理**：和进位差不多，但取较长的那个，绝对值相减，不够就向前借 1 当 10，最后判断正负。

乘法还是列竖式，实质上就是 $a\times b_i\times 10^i$ 之和。因为我们用的是整数数组，所以可以**乘完之后再统一相加处理进位**，怎么开心怎么来。

除法也是列竖式长除法，本质是逐次减法的过程。为了减少冗余运算，先算出被除数长度 $l_a$ 与除数长度 $l_b$，从下标 $l_a-l_b$ 开始、**从高位到低位**计算商（这与手工计算时把第一次乘法的最高位与被除数最高位对齐的做法是一样的）。

## 核心操作详解

- 加法逐位：`sum = carry + a[i] + b[i]`，`c[i] = sum % 10`，`carry = sum / 10`。
- 减法逐位：不够减则 `a[i] += 10; a[i+1] -= 1;`，再 `c[i] = a[i] - b[i]`。
- 乘法：第 $i$ 位乘第 $j$ 位，结果累加到结果的第 $i+j$ 位。
- 除法试商：`r = r*10 + (c-'0')`，`d = r / b`，`r %= b`，最后去掉前导 0。

## 逐行代码解析

### 存储与倒序

```cpp
const int MaxN=500;	//最多500位

int a[MaxN],b[MaxN];	//处理后的倒序数组
int c[MaxN];		//答案数组
string s1,s2;		//原字符串

cin>>s1>>s2;
int len1=s1.size(),len2=s2.size();
for(int i=0;i<len1;i++) a[i]=s1[len1-1-i]-'0';
for(int i=0;i<len2;i++) b[i]=s2[len2-1-i]-'0';
//倒序存储
```

- 下标 0 存个位、下标 1 存十位……，这样进位方向与数组下标增长方向一致。
- `s[len-1-i]` 把字符串的高位放到数组的高位，`- '0'` 把字符转成数值。

### 进位处理

```cpp
int len=min(len1,len2);//取较短长度
//sum为当前位的和，carry为上一位进上来的数字
//对于每一位i：
	int sum=carry;
	sum+=a[i]+b[i];
	sum%=10;
	carry=sum/10;
	c[i]=sum;
```

```cpp
if(carry) c[i+1]++;//最高位如果还有进位，要单独补一位
```

- 加法只需循环到较短长度，剩下的高位要么是原数的高位、要么被最后的进位补上。
- 口诀：先算 `sum`，再取模留本位的值、取整除留给下一位。

### 借位处理

```cpp
int len=max(len1,len2);//取较长长度
//对于每一位i：
if(a[i]<b[i]){
	a[i]+=10;
	a[i+1]--;
}
c[i]=a[i]-b[i];
```

```cpp
while(c[maxl]==0&&maxl>0) maxl--;//去除前导0
```

- 减法取较长长度，逐位相减，不够就借位。
- 注意**前导 0**：如果两数正好相等（差为 0），要留一个 0，所以 `maxl>0` 是必须的。

### 模板其一：BigInt namespace（RedStone 版）

完整模板，整段拿走即可：

```cpp
namespace BigInt{
	string readString(){
	    string s;
	    char ch=getchar();
	    while(ch==' '||ch=='\n'||ch=='\r') ch=getchar();
	    while(ch!=' '&&ch!='\n'&&ch!='\r'){
	        s+=ch;
	        ch=getchar();
	    }
	    return s;
	}
	
    string trim(string s){
        if(s.empty()||s=="0") return "0";
        int pos=0;
        while(pos<(int)s.size()&&s[pos]=='0') pos++;
        if(pos==(int)s.size()) return "0";
        return s.substr(pos);
    }
    int compare(string a,string b){
        a=trim(a),b=trim(b);
        if(a.size()!=b.size()) return a.size()<b.size()?-1:1;
        if(a<b) return -1;
        if(a>b) return 1;
        return 0;
    }
    
    string add(string a,string b){
        string res;
        int i=a.size()-1,j=b.size()-1,carry=0;
        while(i>=0||j>=0||carry){
            int sum=carry;
            if(i>=0) sum+=a[i--]-'0';
            if(j>=0) sum+=b[j--]-'0';
            res+=sum%10+'0';
            carry=sum/10;
        }
        reverse(res.begin(),res.end());
        return trim(res);
    }
    string sub(string a,string b){
        string res;
        int i=a.size()-1,j=b.size()-1,borrow=0;
        while(i>=0){
            int da=a[i--]-'0';
            int db=(j>=0?b[j--]-'0':0);
            int diff=da-db-borrow;
            if(diff<0) diff+=10,borrow=1;
            else borrow=0;
            res+=diff+'0';
        }
        reverse(res.begin(),res.end());
        return trim(res);
    }
    string mul(string a,string b){
        if(a=="0"||b=="0") return "0";
        int la=a.size(),lb=b.size();
        vector<int> res(la+lb,0);
        for(int i=la-1;i>=0;i--){
            for(int j=lb-1;j>=0;j--){
                int m=(a[i]-'0')*(b[j]-'0');
                int sum=m+res[i+j+1];
                res[i+j+1]=sum%10;
                res[i+j]+=sum/10;
            }
        }
        string ans;
        for(int x:res) if(!(ans.empty()&&x==0)) ans+=x+'0';
        return ans.empty()?"0":ans;
    }
    pair<string,int> divmod(string a,int b){
        string q;
        long long r=0;
        bool lead=true;
        for(char c:a){
            r=r*10+(c-'0');
            int d=r/b;
            r%=b;
            if(!lead||d!=0){
                q+=d+'0';
                lead=false;
            }
        }
        if(q.empty()) q="0";
        return {q,(int)r};
    }
    
    struct Int{
        string s;
        bool neg;
        Int(string num="0"){
            neg=false;
            if(num.empty()){s="0"; return;}
            int st=0;
            if(num[0]=='-'){
                neg=true;
                st=1;
            }
            if(num[0]=='+') st=1;
            s=trim(num.substr(st));
            if(s=="0") neg=false;
        }
        Int(long long num){
            neg=false;
            string tmp=to_string(num);
            if(tmp[0]=='-'){
                neg=true;
                s=trim(tmp.substr(1));
            }else{
                s=trim(tmp);
            }
        }
        string str(){
            if(neg&&s!="0") return "-"+s;
            return s;
        }
    };
    
    Int add(Int a,Int b){
        if(a.neg==b.neg){
            string res=::BigInt::add(a.s,b.s);
            if(a.neg) return Int("-"+res);
            return Int(res);
        }
        int c=compare(a.s,b.s);
        if(c==0) return Int("0");
        if(c>0){
            string res=::BigInt::sub(a.s,b.s);
            if(a.neg) return Int("-"+res);
            return Int(res);
        }else{
            string res=::BigInt::sub(b.s,a.s);
            if(b.neg) return Int("-"+res);
            return Int(res);
        }
    }
    Int sub(Int a,Int b){
        if(a.neg!=b.neg){
            Int t=b;
            t.neg=!t.neg;
            return add(a,t);
        }
        int c=compare(a.s,b.s);
        if(c==0) return Int("0");
        if(c>0){
            string res=::BigInt::sub(a.s,b.s);
            if(a.neg) return Int("-"+res);
            return Int(res);
        }else{
            string res=::BigInt::sub(b.s,a.s);
            if(!a.neg) return Int("-"+res);
            return Int(res);
        }
    }
    Int mul(Int a,Int b){
        if(a.s=="0"||b.s=="0") return Int("0");
        string res=::BigInt::mul(a.s,b.s);
        if((a.neg&&!b.neg)||(!a.neg&&b.neg)) return Int("-"+res);
        return Int(res);
    }
    Int div(Int a,int b){
        if(b==0) return Int("0");
        int ab;
        if(b>0) ab=b;
        else ab=-b;
        pair<string,int> p=divmod(a.s,ab);
        string q=p.first;
        if((a.neg&&b>0)||(!a.neg&&b<0)) return Int("-"+q);
        return Int(q);
    }
    int mod(Int a,int b){
	    if(b==0) return 0;
	    int ab=b>0?b:-b;
	    auto [q,r]=divmod(a.s,ab);
	    return a.neg?-r:r;
	}
}
```

- `readString()`：专为高精度写的字符串快读，返回一个字符串。
- `trim(str)`：去除前导 $0$，返回处理后的字符串。
- `compare(str_a,str_b)`：比较两个字符串的绝对值，返回 $-1$ 表示 `str_b` 大，`1` 表示 `str_a` 大，`0` 表示一样大。
- `add` / `sub` / `mul`：分别是加、减、乘的底层实现，本质是绝对值运算，返回字符串结果。
- `divmod(str_a,str_b)`：除法底层实现（除以低精度 int），返回一个 `pair<string,int>`，`first` 是商、`second` 是余数。
- `Int` 结构体：`s` 存绝对值，`neg` 是负号标签；`str()` 把它转成可输出的字符串。
- `Int` 版的 `add/sub/mul/div/mod`：可以看作对外接口，主要处理负号，内部调用上面的底层实现。

`mod` 里用到了 **C++17** 的结构化绑定：

```cpp
auto [q,r]=divmod(a.s,ab);
//  ├─┘  ├─┘  ├────────────┘
//  │    │    └── 函数返回 pair<string,int>
//  │    └─────── 把 pair.first 赋值给 q
//  └──────────── 把 pair.second 赋值给 r
```

由于目前竞赛多用 **C++14**，等价写法是：

```cpp
pair<string,int> p=divmod(a.s,ab);	//这里pair<string,int>可替换为auto
string q=p.first;
int r=p.second;
```

### 食用方法

```cpp
using namespace BigInt;

Int a("12345678901234567890");	// 从字符串创建
Int b(12345);			// 从整数创建
Int c("-987654321");		// 负数也可以
Int d;				// 默认是0
//读入可采用Int str(readString());很简便吧？就和正常快读一样用就行。

Int x,y;
int z;
add(x,y);	//加法
sub(x,y);	//减法
mul(x,y);	//乘法
div(x,z);	//除法
mod(x,z);	//余数
//以上这些都是有返回值的哦
//可以使用形如Int result=add(x,y);来获取其值

cout<<result.str();	//输出
```

- 因为用 `namespace` 打包，如果担心函数名冲突而不写 `using namespace BigInt;`，那在调用 `add/sub/mul/div/mod` 之前都要加上 `BigInt::`，例：`BigInt::Int a(114514);`。
- 所有这些运算都有返回值，可以用 `Int result = add(x,y);` 接住，再用 `result.str()` 输出。

### 模板其二：高精度除高精度（GOC 版）

GOC 的代码比较抽象，看不懂优先用上面的 BigInt 模板。高除高的原理：每次在被除数中截取与除数等长的部分，将除转化为多次减法，直到截取的部分小于除数为止，减的次数就是这一位的商；剩下的继续参与运算，最后剩下的 `a` 就是余数。

```cpp
#include <bits/stdc++.h>
using namespace std;
#define int long long
#define fi first
#define se second
#define endl '\n'
const int N=1145;//依据数据范围调整
const int J=4;
bool strbdx(string a,string b){//比较高精度数(字符串形式)的大小，a>=b返回true
	int n=(int)a.size(),m=(int)b.size();
	if(n!=m) return n>m;
	for(int i=0;i<n;i++){
		if(a[i]!=b[i]) return a[i]>b[i];
	}
	return true;
}
string gjdplus(string a,string b){//高精度加法
	vector<int> c;
	int u,t=0;
	while((int)a.size()<(int)b.size()) a='0'+a;
		//TODO
	while((int)a.size()>(int)b.size()) b='0'+b;
	for(int i=(int)a.size()-1,j=(int)b.size()-1;i>=0&&j>=0;i--,j--){
		//int aa=a[i],bb=b[j];
		//if(i<0) i=0;
		//if(j<0) j=0;
		u=a[i]-48+b[j]-48;
		u+=t;t=0;
		t=u/10,u%=10;
		c.push_back(u);
	}
	if(t>0) c.push_back(t);
	string d;
	for(int i=0;i<(int)c.size();i++){
		char u=c[i]+48;
		d=u+d;
	}
	return d;
}
string gjdsub(string a,string b){//高精度减法
	int n=(int)a.size(),m=(int)b.size();
	bool f=false;
	if(!strbdx(a,b)) swap(a,b),f=true;
	vector<int> c;
	while(m<n) m++,b='0'+b;
	int u,t=0;
	for(int i=(int)a.size()-1,j=(int)b.size()-1;i>=0&&j>=0;i--,j--){
		u=a[i]-48-(b[j]-48);
		u-=t;t=0;
		while(u<0){
			u+=10;t++;
		}
		c.push_back(u);
	}
	int qd=true;
	string d;
	for(int i=0;i<(int)c.size();i++){
		if(c[i]==0){
			if(qd) continue;
		}else dq=false;
		char u=c[i]+48;
		d=u+d;
	}
	if(f) d='-'+d;
	return d; 
}
string gjdmion(string a,int b){//高精度乘单精度
	int sum[N]={0};
	int n=(int)a.size();
	for(int i=0;i<n;i++){
		sum[i+1]=a[n-i-1]-'0';
	}
	for(int i=1;i<=n;i++){
		sum[i]*=b;
	}
	for(int i=1;i<=n+J;i++){//J是单精度数的最高位数，如1145有4位，则积不超过n+4位
		if(sum[i]>=10){
			sum[i+1]+=sum[i]/10;
			sum[i]%=10;
		}
	}
	int idx=0;
	for(int i=n+J;i>=1;i--){
		if(sum[i]!=0){
			idx=i;break;
		}
	}
	string res="";
	for(int i=idx;i>=1;i++){
		res+=(char)(sum[i]+48);
	}
	return res;
}
string gjdmulti(string a,string b){//高精度乘高精度
	string res="0";
	reverse(b.begin(),b.end());
	for(int i=0;i<(int)b.size();i++){
		string xdm=gjdmion(a,b[i]-'0');
		for(int j=1;j<=i;j++) xdm+='0';
		res=gjdplus(res,xdm);
	}
	return res;
}
string gjdfloat(int a,int b,int n){//单精度除单精度，保留n位高精度商
	string res="";
	res+=(a/b)+'0';int t=a%b;res+='.';
	while(n--){
		t*=10;
		res+=(t/b)+'0';
		t%=b;
	}
	return res;
}
pair<string,int> gjdsionblt(string s,int b){//高精度数除以单精度数，返回商与余数
	pair<string,int> ans;
	ans.fi="";ans.se=0;
	int a[N]={0};int c[N]={0};
	for(int i=0;i<(int)s.size();i++) a[i]=s[i]-'0';
	int t=0;
	for(int i=0;i<(int)s.size();i++){
		t=t*10+a[i];
		if(t>=b){
			c[i]=t/b;
			t=t%b;
		}else c[i]=0;
	}
	int idx=0;
	for(int i=0;i<(int)s.size();i++){
		if(c[i]!=0){
			idx=i;break;
		}
	}
	for(int i=idx;i<(int)s.size();i++){
		ans.fi+=(char)(c[i]+'0');
	}
	ans.se=t;
	return ans;
}
void cpy(int x[],int y[],int hyw){//将x数组内容复制到y数组中,右偏移hyw位,该函数服务于高除高
	for(int i=1;i<=x[0];i++){
		y[i+hyw]=x[i];
	}
	y[0]=x[0]+hyw;
}
bool cmp(int x[],int y[]){//比较高精度数(字数组形式)的大小，x>=y返回true
	if(x[0]>y[0]) return true;
	else if(x[0]<y[0]) return false;
	else{
		for(int i=1;i<=x[0];i++){
			if(x[i]!=y[i]) return x[i]>y[i];
		}
	}
	return true;
}
pair<string,string> gjdivisi(string s1,string s2){//高精度除高精度，返回商与余数
	pair<string,string> ans={"",""};
	int a[N]={0},b[N]={0},c[N]={0};
	a[0]=s1.size(),b[0]=s2.size();//x[0]表示x数组有效长度
	if(a[0]<b[0]||(a[0]==b[0]&&s1<s2)){
		ans={"0",s1};return ans;
	}
	c[0]=a[0]-b[0]+1;
	for(int i=1;i<=a[0];i++) a[i]=s1[i-1]-'0';
	for(int i=1;i<=b[0];i++) b[i]=s2[i-1]-'0';
	int t[2*N]={0};//b的临时移位
	for(int i=1;i<=c[0];i++){
		memset(t,0,sizeof(t));
		cpy(b,t,i-1);
		a[0]=t[0];
		while(cmp(a,t)){
			for(int j=a[0];j>=1;j++){
				if(a[j]<t[j]&&j!=1){
					a[j]+=10;a[j-1]--;
				}
				a[j]-=t[j];
			}
			c[i]++;
		}
	}
	int idx=0;//处理前导0
	for(int i=1;i<=c[0];i++){
		if(c[i]!=0){
			idx=i;break;
		}
	}
	for(int i=idx;i<=c[0];i++){
		ans.fi+=(char)(c[i]+'0');
	}
	idx=0;
	for(int i=1;i<=a[0];i++){
		if(a[i]!=0){
			idx=i;break;
		}
	}
	for(int i=idx;i<=a[0];i++){
		ans.se+=(char)(a[i]+'0');
	}
	return ans;
}
signed main() {
    //按题意调用
    return 0;
}
```

- `gjdplus` / `gjdsub`：字符串形式的高精加 / 减，`strbdx` 负责比大小。
- `gjdmion` / `gjdmulti`：高精乘单精 / 高精乘高精，`J` 是单精度数的最高位数。
- `gjdivisi`：高精除高精，用 `cmp` + `cpy`（把除数右移 `i-1` 位）逐位试商。
- 这段是原笔记的原始代码，里面留了未删掉的临时注释标记以及个别变量名笔误，只做搬运、不改实现，使用前请自行核对。

## 复杂度分析

| 运算 | 复杂度 | 说明 |
|---|---|---|
| 加法 / 减法 | $O(n)$ | 每位数处理一次，$n$ 为较长数位 |
| 高精 × 高精 | $O(n \cdot m)$ | 双重循环，$n$、$m$ 为两个数的位数 |
| 高精 ÷ 低精 | $O(n)$ | 从高位到低位逐位试商 |
| 高精 ÷ 高精（朴素） | 最坏 $O(n \cdot m)$ 以上 | 「试商 + 反复减法」，位数大时代价高 |

空间复杂度 $O(n+m)$，用于存储处理数组与结果。固定数组版本（如 `MaxN=500`、`N=1145`）只支持相应位数以内的大整数。

## 适用场景

1. **大整数运算**：数字超过 `long long` 范围的加减乘。
2. **阶乘、幂运算**：结果很大的数学题。
3. **斐波那契数列**：第几十项就会超过 `long long`。
4. **组合数计算**：大数阶乘与组合数。
5. **高精度求余、高精度除法**：在本实现基础上扩展。

## 常见陷阱与注意事项

1. **前导 0 处理**：结果高位可能有多余的 0，要 `while(idx>0 && !tmp[idx]) idx--;`，`idx>0` 保证结果就是 0 时至少留一位。
2. **字符串与数组方向相反**：字符串高位在前，运算数组低位在前，输入要反转、输出还要反转回来。搞反方向是高精度最常见的 bug。
3. **乘法的位数位置**：第 $i$ 位 × 第 $j$ 位 → 结果加到第 $i+j$ 位，不是 $i+j+1$。
4. **memset 清零**：全局数组会保留上一次运算的结果，每次运算前要 `memset` 清零，忘了必错。
5. **乘法溢出**：200 位 × 200 位时某一位最多累加 $200 \times 9 \times 9 = 16200$，`int` 够用；几万位的乘法就可能溢出，需要 `long long` 或边乘边进。
6. **减法的负数问题**：本实现只处理 $a \ge b$；$a < b$ 时要交换两数、算 $b-a$、再加负号。
7. **0 的特判**：加法加 0 等于本身可直接返回；乘法乘 0 等于 0，必须特判。
8. **数组大小要足够**：加法结果最多 $\max(n,m)+1$ 位，乘法最多 $n+m$ 位，开小会越界。
9. **输入前导 0**：若输入形如 `"00123"`，位数判断会出错，比较和运算前最好先 `trim`。
10. **浮点 `pow` 不可靠**：旁边进制转换那类用 `pow` 算权重的思路，位数一多会丢精度，大数场景要用高精或整数快速幂。

## 对比与扩展

- **模板选择**：日常用 BigInt namespace 版就够了（接口清晰、自带负号处理）；需要高精除高精时再上 GOC 版。
- **压位高精度**：每个数组元素存多位（如 9 位），减少运算次数、提高常数。
- **FFT 优化乘法**：用快速傅里叶变换把乘法优化到 $O(n \log n)$。
- **高精度取模**：从高位到低位逐位取模。
- **负数 / 小数高精度**：统一处理正负号；小数本质和整数一样，只是记住小数点位置。
- 延伸阅读：[OI Wiki · 高精度](https://oi.wiki/math/bignum/)。
