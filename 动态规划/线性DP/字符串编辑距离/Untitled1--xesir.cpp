#include <bits/stdc++.h>
using namespace std;
vector<vector<int>> f(1010,vector<int>(1010,1e9));
signed main()
{
    int n,m;string a,b;
    cin>>n>>a>>m>>b;
    a=" "+a;b=" "+b;
    for(int i=0;i<=n;i++){
        f[i][0]=i;
    }
    for(int i=0;i<=m;i++){
        f[0][i]=i;
    }
    for(int i=1;i<=n;i++){
        for(int j=1;j<=m;j++){
            if(a[i]==b[j]) f[i][j]=min(f[i][j],f[i-1][j-1]);
            else f[i][j]=min(f[i][j],f[i-1][j-1]+1);
            f[i][j]=min(f[i][j],f[i-1][j]+1);
            f[i][j]=min(f[i][j],f[i][j-1]+1);
        }
    }
    cout<<f[n][m];
    return 0;
}
