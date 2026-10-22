#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int INF=INT_MAX;
//int cnt=0;
inline int read();
inline void write(int x);
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int W,n;cin>>W>>n;
    vector<int> t(1<<n,0),w(1<<n,0),dp(1<<n,INF);
    for(int i=0;i<n;i++){
        int a,b;cin>>a>>b;
        for(int j=0;j<(1<<n);j++){
            if(j&(1<<i)){
                t[j]=max(t[j],a);
                w[j]+=b;
            }
        }
    }
    for(int i;i<(1<<n);i++){
        if(w[i]<=W) dp[i]=t[i];
        for(int j=i;j;j=i&(j-1)){
            if(w[i^j]<=W) dp[i]=min(dp[i],dp[j]+t[i^j]);
        }
    }
    cout<<dp[(1<<n)-1]<<'\n';
    return 0;
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
#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=1<<19,INF=INT_MAX;
//int cnt=0;
int a[N];
PII f[N];
inline int read();
inline void write(int x);
PII mxp(PII a,PII b){
    if(a.fi<b.fi) swap(a,b);
    if(a.se<b.fi) a.se=b.fi;
    return a;
}
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
    int n;cin>>n;
    for(int i=0;i<(1<<n);i++){
        cin>>a[i];
        f[i]={a[i],-INF};
    }
    for(int i=0;i<n;i++){
        for(int sta=(1<<n)-1;sta>=0;sta--){
            if(sta&(1<<i)) f[sta]=mxp(f[sta],f[sta^(1<<i)]);
        }
    }
    int ans=0;
    for(int i=1;i<(1<<n);i++){
        ans=max(f[i].fi+f[i].se,ans);
        cout<<ans<<'\n';
    }
    return 0;
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
