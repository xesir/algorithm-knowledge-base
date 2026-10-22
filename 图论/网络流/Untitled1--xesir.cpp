#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N=210;
const int INF=LLONG_MAX;
int n,m,s,t,mxf=0;
#define fi first
#define se second
typedef pair<int,int> PII;
struct ege{
	int to,w;
	int rev;
};
vector<ege> wYG[N],wRG[N];//原图和残量网络
int wLG[N],cur[N];//记录层数
bool bfs(){
	for(int i=1;i<=n;i++) wLG[i]=-1;
	queue<int> q;
	q.push(s);
	wLG[s]=0;
	while(q.size()){
		int tmp=q.front();q.pop();
		for(auto i:wRG[tmp]){
			if(wLG[i.to]!=-1) continue;
			if(i.w==0) continue;
			q.push(i.to);
			wLG[i.to]=wLG[tmp]+1;
		}
	}
	if(wLG[t]==-1) return false;
	else return true;
}
int dfs(int u,int f){
	if(u==t) return f;
	for(int &i=cur[u];i<(int)wRG[u].size();i++){
		ege &e=wRG[u][i];
		if(e.w>0&&wLG[e.to]==wLG[u]+1){
			int ret=dfs(e.to,min(f,e.w));
			if(ret>0){
				e.w-=ret;
				wRG[e.to][e.rev].w+=ret;
				return ret;
			}
		}
	}
	return 0;
}
signed main(){
	cin>>n>>m>>s>>t;
	for(int i=1;i<=m;i++){
		int u,v,w;cin>>u>>v>>w;
		wYG[u].push_back({v,w,0});
		wRG[u].push_back({v,w,(int)wRG[v].size()});
		wRG[v].push_back({u,0,(int)wRG[u].size()-1});
	}
	while(bfs()){
		for(int i=1;i<=n;i++) cur[i]=0;
		while(true){
			int pus=dfs(s,INF);
			if(pus==0) break;
			mxf+=pus;
		}
	}
	cout<<mxf<<'\n';
	return 0;
}
#include <bits/stdc++.h>
using namespace std;
#define int long long
const int N=5e3+10;
const int INF=LLONG_MAX;
int n,m,s,t,mxf=0,mic=0;
#define fi first
#define se second
typedef pair<int,int> PII;
struct ege{
	int to,w;
	int rev;
	int cost;
};
vector<ege> wYG[N],wRG[N];//原图和残量网络
int wLG[N],cur[N];//记录层数
bool inq[N],vis[N];
bool spfa(){
	for(int i=1;i<=n;i++) wLG[i]=INF;
	for(int i=1;i<=n;i++) inq[i]=false;
	queue<int> q;
	q.push(s);
	wLG[s]=0;
	inq[s]=true;
	while(q.size()){
		int tmp=q.front();q.pop();
		for(auto i:wRG[tmp]){
			if(i.w==0) continue;
			if(wLG[i.to]<=wLG[tmp]+i.cost) continue;			
			wLG[i.to]=wLG[tmp]+i.cost;
			if(inq[i.to]==false){
				q.push(i.to);
				inq[i.to]=true;
			}
		}
	}
	return inq[t];
}
int dfs(int u,int f){
	if(u==t) return f;
	vis[u]=true;
	int nf=0;
	for(int &i=cur[u];i<(int)wRG[u].size();i++){
		ege &e=wRG[u][i];
		if(e.w>0&&wLG[e.to]==wLG[u]+e.cost&&!vis[e.to]){
			int ret=dfs(e.to,min(f-nf,e.w));
			if(ret>0){
				e.w-=ret;
				wRG[e.to][e.rev].w+=ret;
				mic+=e.cost*ret;
				nf+=ret;
				if(nf==f) break;
			}
		}
	}
	vis[u]=false;
	return nf;
}
signed main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);cout.tie(nullptr);
	cin>>n>>m>>s>>t;
	for(int i=1;i<=m;i++){
		int u,v,w,c;cin>>u>>v>>w>>c;
		wYG[u].push_back({v,w,0,c});
		wRG[u].push_back({v,w,(int)wRG[v].size(),c});
		wRG[v].push_back({u,0,(int)wRG[u].size()-1,-c});
	}
	while(spfa()){
		for(int i=1;i<=n;i++) cur[i]=0;
		while(true){
			int pus=dfs(s,INF);
			if(pus==0) break;
			mxf+=pus;
		}
	}
	cout<<mxf<<" "<<mic<<'\n';
	return 0;
}
