#include <bits/stdc++.h>
using namespace std;
int dp[1010][1010],a[1010][1010];
int main() {
   //int t;cin>>t;
   //while(t--){
           int n;cin>>n;
           int x,y,c;
           while(cin>>x>>y>>c&&x&&y&&c){
               a[x][y]=c;
           }
        for(int i=1;i<=n;i++){
            for(int j=1;j<=n;j++){
                 dp[i][j][k][u]=max(dp[i-1][j]，dp[i][j-1]);
                 dp[i][j]+=a[i][j];              
            }
        }
        cout<<dp[n][n];
   //}
    return 0;
}
