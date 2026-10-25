#include <bits/stdc++.h>
using namespace std;
//#define int long long
#define PII pair<int,int>
#define fi first
#define se second
//#define pb push_back
const int N=1e5+10;
int n,m,q;
vector<PII> G1[N];
int h[N],vis[N];
void dfs(int x){
	vis[x]=1;
	//cout<<x<<" "<<h[x]<<endl;
	for(auto i:G1[x]){
		if(!vis[i.fi]){
			h[i.fi]=h[x]^i.se;
			dfs(i.fi);
		}
	}
	return ;
}
signed main(){
	ios::sync_with_stdio(0);
	cin.tie(0);cout.tie(0);
	cin>>n>>m>>q;
	for(int i=1;i<=m;i++){
		int x,y,v;cin>>x>>y>>v;
		G1[x].push_back({y,v});G1[y].push_back({x,v});
	}
	//for(auto i:G1[25061]) cout<<i.fi<<" "<<i.se<<endl;
	dfs(1);
	//cout<<"%%%"<<endl;
	//for(int i=1;i<=n;i++) cout<<h[i]<<'\n';
	while(q--){
		int x,y;cin>>x>>y;
		int cnt=(h[x]^h[y]);
		cout<<cnt<<'\n';
	}
	return 0;
}
