#include <bits/stdc++.h>
using namespace std;
int h[100010];
int gen(int x){
    if(h[x]!=x){
        h[x]=gen(h[x]);
    }
    return h[x];
}
struct side{
    int s,e,l;
    bool operator<(const side &aa)const{
        return l>aa.l;
        }
};
priority_queue<side> f;
int main()
{
    int n,m,cnt=0,ans=0;cin>>n>>m;
    for(int i=1;i<=m;i++){
        side s;cin>>s.s>>s.e>>s.l;f.push(s);
    }
    for(int i=1;i<=n;i++){
        h[i]=i;
    }
    while(f.size()){
        auto t=f.top();f.pop();
        if(h[gen(t.s)]==h[gen(t.e)]) continue;
        else {h[gen(t.s)]=gen(t.e);cnt+=t.l;ans++;}
    }
    if(ans==n-1)cout<<cnt;
    else cout<<"impossible";
return 0;
}
