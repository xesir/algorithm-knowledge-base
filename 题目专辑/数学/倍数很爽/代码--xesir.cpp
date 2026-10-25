#include <bits/stdc++.h>
using namespace std;
#define int __int128
typedef __int128 ll;
const int N=1e3+10,INF=1000000000000000000LL;
int n;int a[N],cys[]={0,0,-2,1},cyn[]={0,0,0,2};
int ksm(int a,int b,int p){
	int res=1;
	while(b){
		if(b&1) res=res*a%p;
		a=a*a%p;
		b>>=1;
	}
	return res;
}
ll gcdo(ll a, ll b) {
    while (b != 0) {
        ll temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}
ll exgcd(ll a, ll b, ll &x, ll &y) {
    if (b == 0) {
        x = 1;
        y = 0;
        return a;
    }
    ll d = exgcd(b, a % b, y, x);
    y -= (a / b) * x;
    return d;
}
ll inv(ll a, ll m) {
    ll x, y;
    ll d = exgcd(a, m, x, y);
    if (d != 1) return -1;
    return (x % m + m) % m;
}
ll crt(ll a[], ll m[], ll k) {
    ll M = 1, res = 0;
    for(int i=1;i<=k;i++) a[i]=(a[i]%m[i]+m[i])%m[i];
    for (ll i = 1; i <= k; i++) M *= m[i];
    for (ll i = 1; i <= k; i++) {
        ll mi = m[i], ai = a[i];
        ll Mi = M / mi;
        ll invMi = inv(Mi,mi);
        res = (res + ai * Mi % M * invMi % M) % M;
    }
    res=(res%M+M)%M;
    return res;
}
bool cmp(int a,int b){
	return a<b;
}
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
signed main(){
	freopen("multiple.in","r",stdin);
	freopen("multiple.out","w",stdout);
	//ios::sync_with_stdio(0);
	//cin.tie(0);cout.tie(0);
	n=read();int mi=LLONG_MAX,mic=0;
	if(n<3){
		cout<<"NO\n";return 0;
	}
	for(int i=1;i<=n;i++) a[i]=read();
	for(int i=1;i<=n;i++){
		if(a[i]==1){
			cout<<"YES\n";
			if(n==3) cout<<"1 2 3\n1";
			else if(i+2>n){
				write(i-2);putchar(' ');write(i-1);putchar(' ');write(i);putchar('\n');write(1);
			}
			else{
				//cout<<i<<" "<<i+1<<" "<<i+2<<"\n"<<1;
				write(i);putchar(' ');write(i+1);putchar(' ');write(i+2);putchar('\n');write(1);
			}
			return 0;
		}
		if(mi>a[i]) mi=a[i],mic=i;
	}
	if(mi>2){
		cout<<"NO\n";return 0;
	}
	for(int i=1;i<=n;i++){
		for(int j=1;j<=n;j++){
			if(a[i]%2==1&&a[j]%2==1&&gcdo(a[i],a[j])==1){
				cyn[1]=a[i],cyn[2]=a[j];cyn[3]=2;
				cys[1]=0;cys[2]=-2;cys[3]=1;
				int u=crt(cys,cyn,3);u--;
				if(u>INF) continue;
				cout<<"YES\n";
				if(j>i) swap(i,j);
				//write(i-2);putchar(' ');write(i-1);putchar(' ');write(i);putchar('\n');write(1);
				if(mic<j){
					//cout<<mic<<" "<<j<<" "<<i<<"\n"<<u;
					write(mic);putchar(' ');write(j);putchar(' ');write(i);putchar('\n');write(u);
				}
				else if(mic<i){
					//cout<<j<<" "<<mic<<" "<<i<<"\n"<<u;
					write(j);putchar(' ');write(mic);putchar(' ');write(i);putchar('\n');write(u);
				}
				else{
					//cout<<j<<" "<<i<<" "<<mic<<"\n"<<u;
					write(j);putchar(' ');write(i);putchar(' ');write(mic);putchar('\n');write(u);
				}
				return 0;
			}
		}
	}
	cout<<"NO\n";
	return 0;
}
