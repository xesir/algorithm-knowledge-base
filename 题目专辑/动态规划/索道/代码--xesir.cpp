#include <bits/stdc++.h>
using namespace std;
#define int long long
#define PII pair<int,int>
#define fi first
#define se second
const int N=5e5+10,INF=1e18;
int a[N],dp[N],g[N],pre[N],nxt[N];
signed main(){
	ios::sync_with_stdio(0);
	cin.tie(0);cout.tie(0);
	int t;cin>>t;
	while(t--){
		int n,k,q;cin>>n>>k;
		a[0]=0;a[n+1]=0;
		for(int i=1;i<=n;i++){
			cin>>a[i];
		}
		string s;cin>>s;s='1'+s+'1';
		deque<PII> h;h.push_back({0,0});
		for(int i=1;i<=n+1;i++){
			while(h.size()&&h.front().fi<i-k) h.pop_front();
			dp[i]=h.front().se+a[i];
			if(s[i]=='1') while(h.size()) h.pop_back();
			else while(h.size()&&h.back().se>dp[i]) h.pop_back();
			h.push_back({i,dp[i]});
		}
		while(h.size()) h.pop_back();
		g[n+1]=0;
		h.push_back({n+1,0});
		for(int i=n;i>=0;i--){
			while(h.size()&&h.front().fi>i+k) h.pop_front();
			g[i]=h.front().se+a[i];
			if(s[i]=='1') while(h.size()) h.pop_back();
			else while(h.size()&&h.back().se>g[i]) h.pop_back();
			h.push_back({i,g[i]});
		}
		pre[0]=0;
		for(int i=1;i<=n+1;i++){
			if(s[i]=='1') pre[i]=i;
			else pre[i]=pre[i-1];
		}
		nxt[n+1]=n+1;
		for(int i=n;i>=0;i--){
			if(s[i]=='1') nxt[i]=i;
			else nxt[i]=nxt[i+1];
		}
		cin>>q;
		while(q--){
			int x,y;cin>>x>>y;
			if(s[x]=='1'){
				cout<<dp[n+1]-a[x]+y<<'\n';
				continue;
			}
			int ans=INF;
			int l=pre[x],r=nxt[x];
			int lmi=INF,rmi=INF;
			for(int i=max(l,x-k);i<=x-1;i++) lmi=min(lmi,dp[i]);
			for(int j=x+1;j<=min(r,x+k);j++) rmi=min(rmi,g[j]);
			if(lmi<INF&&rmi<INF) ans=min(ans,y+lmi+rmi);
			int mg=INF,je=x;
			for(int i=max(l,x-k);i<=x-1;i++){
				if(i+k<x+1) continue;
				int lim=min(r,i+k);
				while(je<lim){
					je++;
					mg=min(mg,g[je]);
				}
				if(mg<INF) ans=min(ans,dp[i]+mg);
			}
			cout<<ans<<'\n';
		}
	}
	return 0;
}
