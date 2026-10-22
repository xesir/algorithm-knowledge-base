int euler_phi(int n) {
    int ans = n;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) {
            ans = ans / i * (i - 1);  // 公式：n × (1 - 1/i)
            while (n % i == 0) n /= i;
        }
    }
    if (n > 1) ans = ans / n * (n - 1);
    return ans;
}
#include <bits/stdc++.h>
using namespace std;     
const int mod=998244353,N=1e8;  
int tot=-1,n;              
vector<bool> p;
vector<int> oph,c;
void zhi(int n){                             
    for(int i=2;i<=n;i++){
        if(!p[i]){
            c.push_back(i);tot++;oph[i]=i-1;
        }
        for(int j=0;j<=tot&&i*c[j]<=n;j++){
            p[i*c[j]]=true;
            if(i%c[j]==0){
                oph[i*c[j]]=oph[i]*c[j];
                break;
            }else oph[i*c[j]]=oph[i]*(c[j]-1);
        }
    }    
}
signed main(){
    long long cnt=0;cin>>n;
    p.assign(n+10,false);
    oph.assign(n+10,false);
    zhi(n);
    oph[1]=1;
    for(int i=1;i<=n;i++){
        cnt+=oph[i];    
    } 
    cout<<cnt;
    return 0;
}
