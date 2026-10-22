#include <bits/stdc++.h>
using namespace std;
const int INF=1e9;
vector<vector<int>> f(310,vector<int>(310,0)),dp(310,vector<int>(310,0));
vector<int> a(310),p(310);
int main(){
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>a[i];f[i][i]=a[i];dp[i][i]=a[i];}
    for(int d=2;d<=n;d++){
        for(int l=1;l<=n;l++){
            int r=l+d-1;
            if(r>n) continue;
            for(int k=l;k<r;k++){
                f[l][r]=max({f[l][k],f[k+1][r],f[l][r]});
                if(dp[l][k]!=0&&dp[l][k]==dp[k+1][r]){
                    if(dp[l][k]+1>dp[l][r]) dp[l][r]=dp[l][k]+1;
                }
            }
            if (dp[l][r]!=0) {
                f[l][r]=max(f[l][r],dp[l][r]);
            }
        }
    }
    cout<<f[1][n];
}
