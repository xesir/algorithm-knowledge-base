#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N = 5e3+10;
vector<pair<int,int>> e[N];
int dis[N], cnt[N], vis[N];
queue<int> q;
bool spfa(int n) {
    for(int i=1;i<=n;i++){
        dis[i] = 0, vis[i] = 1;
  		q.push(i);
    }
    while (!q.empty()) {
    	int u = q.front();
        //cout<<u<<" "<<dis[u]<<" "<<cnt[u]<<'\n';
    	q.pop(), vis[u] = 0;
    	for (auto ed : e[u]) {
      		int v = ed.first, w = ed.second;
      		if (dis[v] > dis[u] + w) {
        		dis[v] = dis[u] + w;
        		cnt[v] = cnt[u] + 1;  
        		if (cnt[v]>=n) return false;
        		if (!vis[v]) q.push(v), vis[v] = 1;
        	}
        }
    }
    return true;
}
signed main(){
    int n,m;cin >> n >> m;
    memset(dis,0x3f,sizeof dis);
    for(int i=1;i<=m;i++){
		int u,v,w;cin>>u>>v>>w;
		e[v].push_back({u,w});
    }
    if(!spfa(n)) cout<<"NO";
    else{
		for(int i=1;i<=n;i++) cout<<dis[i]<<" ";
	}  
    return 0;
}
