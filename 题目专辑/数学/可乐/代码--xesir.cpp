#include <bits/stdc++.h>
using namespace std;
const int mod=2017,N=50;
#define pb push_back
#define vi vector<int>
#define v2 vector<vector<int>>
v2 mtxi(int n){
    v2 c(n,vi(n,0));
    for(int i=0;i<n;i++) c[i][i]=1;
    return c;
}
v2 muljz(v2 a,v2 b){
    int m=a.size(),p=a[0].size(),n=b[0].size();
    v2 c(m,vi(n,0));
    for(int i=0;i<m;i++){
        for(int k=0;k<p;k++){
            if(a[i][k]==0) continue;
            for(int j=0;j<n;j++) c[i][j]=(c[i][j]%mod+a[i][k]*b[k][j]%mod)%mod;
        }
    }
    return c;
}
v2 ksmjz(v2 a,int k){
    int n=a.size();
    v2 res=mtxi(n);
    while(k){
        if(k&1) res=muljz(res,a);
        a=muljz(a,a);
        k>>=1;
    }
    return res;
}
signed main(){
    ios::sync_with_stdio(0);
    cin.tie(0);cout.tie(0);
    int n,m,t,ans=0;cin>>n>>m;
    v2 x(n+1,vi(n+1,0)),y(n+1,vi(n+1,0));
    x[1][1]=1;
    for(int i=0;i<=n;i++) y[i][i]=1,y[i][0]=1;
    while(m--){
        int u,v;cin>>u>>v;
        //u--;v--;
        y[u][v]=y[v][u]=1;
    }
    cin>>t;
    v2 res=muljz(x,ksmjz(y,t));
    for(int i=0;i<=n;i++) ans=(ans%mod+res[1][i]%mod);
    cout<<ans%mod;
    return 0;
}
