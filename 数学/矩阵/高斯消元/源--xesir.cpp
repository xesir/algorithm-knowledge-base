#include<bits/stdc++.h>
#define endl '\n'
#define lowbit(x) x&(-x)
//#define int long long
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const double EPS=1e-8;
int n;
vector<vector<double>> fc(110,vector<double>(110));
void xyk(vector<double> &a,vector<double> &b,int k){
	double xi=b[k]/a[k];
	for(int i=k-1;i<=n+1;i++){
		b[i]-=xi*a[i];
	}
}
vector<double> gsolve(){
	vector<double> ys;
	for(int i=1;i<=n;i++){
		int u=i,v=fabsl(fc[u][i]);
		while(v<EPS){
			u++;
			if(u>n){
				cout<<"No Solution";return ys;
			}
			v=fabsl(fc[u][i]);
		}
		cout<<endl;
		if(u!=i) swap(fc[u],fc[i]);
		for(int j=1;j<=n;j++){
			if(j==i) continue;
			xyk(fc[i],fc[j],i);
		}
	}
	vector<double> ans;
	for(int i=1;i<=n;i++){
		int u=i,v=fabsl(fc[u][i]);
		while(v<EPS){
			u++;
			if(u>n){
				cout<<"No Solution";return ys;
			}
			v=fabsl(fc[u][i]);
		}
		swap(fc[u],fc[i]);
		fc[i][n+1]/=fc[i][i];
		if(fabsl(fc[u][i])<EPS) fc[i][n+1]=0;
		ans.push_back(fc[i][n+1]);
	}
	return ans;
}
int main(){
//  freopen(".in","r",stdin);
//  freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
	cin>>n;
	for(int i=1;i<=n;i++){
		for(int j=1;j<=n+1;j++){
			cin>>fc[i][j];
		}
	}
	vector<double> ans=gsolve();
	for(int i=0;i<(int)ans.size();i++) printf("%.2lf\n",ans[i]);
    return 0;
}
