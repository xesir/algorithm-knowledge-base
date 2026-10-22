#include <bits/stdc++.h>
using namespace std;
#define int long long
vector<pair<int,int>> a[1010];
vector<int> f(1010);
signed main()
{
    ios::sync_with_stdio(0);
    cin.tie(0);
    cout.tie(0);
    int n,v;cin>>n>>v;
    for(int i=1;i<=n;i++){
        int s;cin>>s;
        for(int j=1;j<=s;j++){
            int c,d;cin>>c>>d;
            a[i].push_back({c,d});
        }
    }
    for(int i=1;i<=n;i++){
        for(int j=v;j>=1;j--){
            for(int k=0;k<a[i].size();k++){
                if(j-a[i][k].first>=0)f[j]=max(f[j],f[j-a[i][k].first]+a[i][k].second);
            }
        }
    }
    cout<<f[v];
    return 0;
}
