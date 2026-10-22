#include <bits/stdc++.h>
using namespace std;
const int INF=1e9;
vector<vector<int>> f(310,vector<int>(310,INF));
vector<char> a(310);
int main(){
    string a;cin>>a;//cout<<a;
    a=" "+a;
    int n=a.size()-1;
    //cout<<n;
    for(int i=1;i<=n;i++){
		f[i][i]=1;
	}
    for(int d=2;d<=n;d++){
        for(int l=1;l<=n;l++){
            int r=l+d-1;
            if(r>n) continue;
            if(a[l]==a[r]) f[l][r]=min(f[l][r-1],f[l+1][r]);
            
            for(int k=l;k<r;k++){
				f[l][r]=min(f[l][r],f[l][k]+f[k+1][r]);
            }
			
        }
    }
    cout<<f[1][n];
}
