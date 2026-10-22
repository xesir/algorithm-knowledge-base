#include <bits/stdc++.h>
using namespace std;
int f[1010];
const int mod=1e9+7;
int main(){
    f[0]=1;
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        for(int j=i;j<=n;j++){
            f[j]+=f[j-i];f[j]%=mod;
        }
    }
    cout<<f[n]%mod;
}
