#include <bits/stdc++.h>
using namespace std;
#define fi first
#define se second
const int N=5e5+10;
vector<int> G8[N];
int d[N],z[N][30];
void dfs(int x,int fa){
	//预处理
	d[x]=d[fa]+1;
	z[x][0]=fa;
	for(int i=1;i<=20;i++){
		//TODO
		z[x][i]=z[z[x][i-1]][i-1];
	}
	for(int i:G8[x]){
		if(i!=fa) dfs(i,x);
	}
}
int lca(int u,int v){
	if(d[u]<d[v]) swap(u,v);
	for(int i=20;i>=0;i--){
		if(d[z[u][i]]>=d[v]) u=z[u][i];
	}
	if(u==v) return v;
	for(int i=20;i>=0;i--){
		if(z[u][i]!=z[v][i]) u=z[u][i],v=z[v][i];
	}
	return z[u][0];
}
signed main(){
	int n,m,s;cin>>n>>m>>s;
    for(int i=1;i<n;i++){
        int u,v;cin>>u>>v;
        G8[u].push_back(v);
        G8[v].push_back(u);
    }
    dfs(s,0);
    for(int i=1;i<=m;i++){
        int u,v;cin>>u>>v;
        cout<<lca(u,v)<<'\n';
    }
	return 0;
}
