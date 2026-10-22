vector<char> is_prime(n + 1, true);
is_prime[0] = is_prime[1] = false;
for (int i = 2; i * i <= n; i++) {
    if (is_prime[i]) {
        for (int j = i * i; j <= n; j += i) 
            is_prime[j] = false;
    }
}
for (int i = 2; i <= n; i++) {
    if (!vis[i]) pri[cnt++] = i;
    for (int j = 0; j < cnt; j++) {
        if (i * pri[j] > n) break;
        vis[i * pri[j]] = 1;
        if (i % pri[j] == 0) break;  // 关键！保证每个合数只被筛一次
    }
}
#include <bits/stdc++.h>
using namespace std;
#define endl '\n'//交互题去掉
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
#define pb push_back
#define vi vector<int>
inline int read(){
    int f=1,x=0;
    char c=getchar();
    while(!isdigit(c)) f=(c=='-'?-1:1),c=getchar();
    while(isdigit(c)) x=(x<<1)+(x<<3)+(c^48),c=getchar();
    return x*f;
}
inline void write(int x){
    if(x<0) putchar('-'),x=-x;
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
constexpr int mod=998244353,N=1e7+5;
constexpr int M=1e4+5;
int n,mxn;              
bitset<N> isp;
vector<int> p;//存放质数
vector<int> oph,eph,d,mo;//oph: 欧拉函数, eph: 因数和, d: 因数个数, mo: 莫比乌斯函数
vector<int> cnt;//辅助数组：最小质因子的指数
vector<int> low;// 辅助数组：最小质因子等比数列和 (1 + p + ... + p^k)
int a[M];
int ksm(int x,int y,int p){
	int res=1;
	while(y){
		if(y&1)res=res*x%p;
		x=x*x%p;
		y>>=1;
	}
	return res;
}
void init(int n){
    oph.resize(n+1);
    eph.resize(n+1);
    d.resize(n+1);
    mo.resize(n+1);
    cnt.resize(n+1);
    low.resize(n+1);
}
void zhi(int n){                             
    init(n);
    oph[1]=1;
    eph[1]=1;
    d[1]=1;
    mo[1]=1;
    for(int i=2;i<=n;i++){
        if(!isp[i]){
            p.push_back(i);
            oph[i]=i-1;
            eph[i]=i+1;
            low[i]=i+1;
            d[i]=2;
            cnt[i]=1;
            mo[i]=-1;
        }
        for(size_t j=0;j<p.size()&&1ll*i*p[j]<=n;j++){
            isp[i*p[j]]=true;
            if(i%p[j]==0){
                oph[i*p[j]]=oph[i]*p[j];
                mo[i*p[j]]=0;
                cnt[i*p[j]]=cnt[i]+1;
                d[i*p[j]]=d[i]/(cnt[i]+1)*(cnt[i]+2);
                low[i*p[j]]=low[i]*p[j]+1;
                eph[i*p[j]]=eph[i]/low[i]*low[i*p[j]];
                break;
            }else{
                oph[i*p[j]]=oph[i]*(p[j]-1);
                mo[i*p[j]]=-mo[i];
                cnt[i*p[j]]=1;
                d[i*p[j]]=d[i]*2;
                low[i*p[j]]=p[j]+1;
                eph[i*p[j]]=eph[i]*(p[j]+1);
            }
        }
    }    
}
signed main(){
    return 0;
}
