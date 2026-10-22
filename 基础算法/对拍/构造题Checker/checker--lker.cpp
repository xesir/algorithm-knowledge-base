#include<bits/stdc++.h>
using namespace std;
#define int long long
bool dfs(int s,int d,int n,int sm,int xr)
{
    if(d==n)return sm==s&&xr==0;
    for(int x=1;x<=s;x++)
        if(dfs(s,d+1,n,sm+x,xr^x))
            return true;
    return false;
}
bool ex(int s,int m)
{
    for(int n=1;n<=m;n++)
        if(dfs(s,0,n,0,0))
            return true;
    return false;
}
bool ck(int s,int m,int n,vector<int>&a)
{
    if(n<1||n>m)return false;
    int sm=0,xr=0;
    for(int x:a){
        if(x<1||x>s)return false;
        sm+=x;
        xr^=x;
    }
    return sm==s&&xr==0;
}
signed main()
{
    int ti=0;
    while(1){
        system("./data");
        system("./mine");
        freopen("data.out","r",stdin);
        int T;cin>>T;
        vector<pair<int,int>> qs(T);
        for(int i=0;i<T;i++)cin>>qs[i].first>>qs[i].second;
        cin.clear();
        freopen("mine.out","r",stdin);
        bool ok=true;
        for(int i=0;i<T;i++){
            int s=qs[i].first,m=qs[i].second;
            int n;cin>>n;cin.clear();
            if(n==-1){
                if(ex(s,m)){ok=false;break;}
            }else{
                vector<int>a(n);
                for(int j=0;j<n;j++)cin>>a[j],cin.clear();
                if(!ck(s,m,n,a)){ok=false;break;}
            }
        }
        if(!ok){cout<<"WA/RE/MLE on test "<<++ti<<"\n";break;}
        cout<<"AC on test "<<++ti<<"\n";
        if(ti==10)break;
    }
    return 0;
}
