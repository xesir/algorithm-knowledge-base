#include <bits/stdc++.h>
using namespace std;
const int INF=1e9;
vector<vector<int>> f(310,vector<int>(310,INF));
vector<int> a(310),p(310);
int main(){
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>a[i];f[i][i]=0;
        p[i]=p[i-1]+a[i];
    }
    for(int d=2;d<=n;d++){
        for(int l=1;l<=n;l++){
            int r=l+d-1;
            if(r>n) continue;
            for(int k=l;k<r;k++){
                f[l][r]=min(f[l][r],f[l][k]+f[k+1][r]+p[r]-p[l-1]);
            }
        }
    }
    cout<<f[1][n];
}
for(int i=1;i<=2*n;i++){
    if(i<=n) cin>>a[i];
    else a[i]=a[i-n];
    f1[i][i]=0;f2[i][i]=0;
    p[i]=p[i-1]+a[i];
}
for(int d=2;d<=2*n;d++){
    for(int l=1;l<=2*n;l++){
        int r=l+d-1;
        if(r>2*n) continue;
        for(int k=l;k<r;k++){
            f1[l][r]=max(f1[l][r],f1[l][k]+f1[k+1][r]+p[r]-p[l-1]);
            f2[l][r]=min(f2[l][r],f2[l][k]+f2[k+1][r]+p[r]-p[l-1]);
        }
    }
}
int ans1=0,ans2=INF;
for(int i=1;i<=n;i++){
    ans1=max(f1[i][i+n-1],ans1);
    ans2=min(f2[i][i+n-1],ans2);
}
