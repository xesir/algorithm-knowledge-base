#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e5+10;
int f[N],c[4],d[4];
signed main(){
    ios::sync_with_stdio(0);
    cin.tie(0);cout.tie(0);
    for(int i=0;i<4;i++) cin>>c[i];
    int n;cin>>n;
    f[0]=1;
    for(int i=0;i<4;i++){
        for(int j=0;j<N;j++){
            if(j-c[i]>=0) f[j]+=f[j-c[i]];
        }
    }
    while(n--){
        for(int i=0;i<4;i++) cin>>d[i];
        int s;cin>>s;
        int ans=0;
        for(int i=0;i<16;i++){
            int cnt=s,res=0;
            for(int j=0;j<4;j++){
                if(i&(1<<j)) cnt-=(d[j]+1)*c[j];
            }
            if(cnt>=0) res=f[cnt];
            if(__builtin_popcountll(i)&1) ans-=res;
            else ans+=res;
        }
        cout<<ans<<'\n';
    }
    return 0;
}
