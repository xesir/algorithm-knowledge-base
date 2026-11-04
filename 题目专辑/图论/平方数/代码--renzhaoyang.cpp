#include<bits/stdc++.h>
#define PII pair<int,int>
#define int long long
#define pb push_back
#define cc c.begin(),c.end()
#define ef(x) lower_bound(cc,x)-c.begin()
#define endl '\n'
using namespace std;
int fun(int x){
	int res=1;
	for(int i=2;i*i<=x;i++){
		if(x%i==0){
			int ct=0;
			while(x%i==0){
				ct++;
				x/=i;
			}
			if(ct&1)res*=i;
		}
	}
	if(x>1)res*=x;
	return res;
}
signed main(){
	int T;cin>>T;
	while(T--){
		int n;cin>>n;
		vector<int>aa(n),bb(n),c;
		for(int i=0;i<n;i++){
			int a,b;cin>>a>>b;
			aa[i]=fun(a);
			bb[i]=fun(b);
			c.pb(aa[i]);
			c.pb(bb[i]);
		}
		sort(cc);
		c.erase(unique(cc),c.end());
		int ct=c.size();
		int s=ef(1);
		if(s>=ct||c[s]!=1){
			cout<<-1<<endl;
			continue;
		}
		vector<vector<PII>>a(ct);
		vector<PII>b;
		for(int i=0;i<n;i++){
			int u=ef(aa[i]);
			int v=ef(bb[i]);
			a[u].pb({v,i});
			if(u==s)b.pb({v,i});
		}
		int mi=INT_MAX;
		for(auto[v,d]:b){
			vector<int>dist(ct,-1);
			queue<int>q;
			for(auto[f,e]:a[v]){
				if(e==d)continue;
				if(dist[f]==-1){
					dist[f]=1;
					q.push(f);
				}
			}
			while(!q.empty()){
				int u=q.front();q.pop();
				for(auto[f,e]:a[u]){
					if(e==d)continue;
					if(dist[f]==-1){
						dist[f]=dist[u]+1;
						q.push(f);
					}
				}
			}
			if(dist[s]!=-1)mi=min(mi,1+dist[s]);
		}
		if(mi==INT_MAX)cout<<-1<<endl;
		else cout<<mi<<endl;
	}
	return 0;
}
