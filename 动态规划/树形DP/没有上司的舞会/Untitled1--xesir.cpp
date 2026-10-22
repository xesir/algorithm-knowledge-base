#include <bits/stdc++.h>
using namespace std;
vector<int> bo[6010];
int h[6010],f[6010][2],v[6010];
void dp(int x){
    f[x][0]=0;f[x][1]=h[x];
    for(int i=0;i<bo[x].size();i++){
        int y=bo[x][i];
        //cout<<y<<" "<<x<<endl;
        dp(y);//TODO
        f[x][0]+=max(f[y][0],f[y][1]);
        f[x][1]+=f[y][0];
    }
}
int main(){
    int n;cin>>n;
    for(int i=1;i<=n;i++){
        cin>>h[i];
    }
    for(int i=1;i<n;i++){
        int l,k;cin>>l>>k;
        bo[k].push_back(l);
        v[l]=1;
    }
    int st;
    for(int i=1;i<=n;i++){
            if(!v[i]) {st=i;break;}
        }
    dp(st);
    cout<<max(f[st][0],f[st][1]);
}
