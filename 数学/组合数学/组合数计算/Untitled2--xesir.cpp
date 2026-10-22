#include<bits/stdc++.h>
using namespace std;
#define int long long
int dp[2010][2010];
int cabz(int n,int k){
    if(k<0||k>n) return 0;
    if(k==n||k==0) return 1;
    if(dp[n][k]!=-1) return dp[n][k];
    dp[n][k]=cabz(n-1,k-1)+cabz(n-1,k);
    dp[n][k]%=1000000007;
    return dp[n][k];
}
signed main(){
    int n,a,b;cin>>n;
    memset(dp,-1,sizeof dp);
    while(n--){
        cin>>a>>b;//TODO
        cout<<cabz(a,b)<<'\n';
    }
    return 0; 
}
