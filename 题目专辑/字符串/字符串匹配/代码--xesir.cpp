#include <bits/stdc++.h>
using namespace std;
#define int long long
#define ull unsigned long long
#define PUU pair<ull,ull> 
#define fi first
#define se second
const int N=2e6+10,mod1=998244353,mod2=1e9+7;
int thp[27];
PUU hs[N],pb[N];
int pre[N],suf[N];
inline PUU gths(int l,int r){
    PUU res;
    res.fi=(hs[r].fi%mod1+mod1-hs[l-1].fi*pb[r-l+1].fi%mod1)%mod1;
    res.se=(hs[r].se-hs[l-1].se*pb[r-l+1].se);
    return res;
}
signed main(){
    ios::sync_with_stdio(0);
    cin.tie(0);cout.tie(0);
    int t;cin>>t;
    pb[0].fi=1,pb[0].se=1;
    for(int i=1;i<1.5e6;i++) 
        pb[i].fi=pb[i-1].fi*26%mod1,pb[i].se=pb[i-1].se*26;
    while(t--){
        string s;cin>>s;s='0'+s;
        int n=s.size()-1;ull ans=0;
        for(int i=0;i<=26;i++) thp[i]=0;
        for(int i=1;i<=n;i++) 
            hs[i].fi=(hs[i-1].fi*26%mod1+(s[i]-'a')%mod1)%mod1,            hs[i].se=(hs[i-1].se*26+(s[i]-'a'));
        for(int i=1,j=0;i<=n;i++){
            j^=(1<<(s[i]-'a'));
            pre[i]=__builtin_popcountll(j);
        }
        for(int i=n,j=0;i>0;i--){
            j^=(1<<(s[i]-'a'));
            suf[i]=__builtin_popcountll(j);
        }
        for(int i=2;i<n;i++){
            //bool kk=true;
            for(int k=pre[i-1];k<=26;k++) thp[k]++;
            for(int j=0;(j+1)*i<n;j++){
                if(hs[i]==gths(1+i*j,i*(j+1))){
                    ans+=thp[suf[i*(j+1)+1]];
                }else break;
            }
        }
        cout<<ans<<'\n';
    }
    return 0;
}
