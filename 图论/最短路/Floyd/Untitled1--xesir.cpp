#include <bits/stdc++.h>
using namespace std;
int f[210][210];
const int INF=1e9;
int main(){
   
    int n,m,k;cin >> n >> m>>k;
    for(int i=1;i<=n;i++){
        for(int j=1;j<=n;j++){
            if(i!=j) f[i][j]=INF;
            else f[i][j]=0;
        }
    }
    for(int i = 1; i <= m; i ++) {
        int a, b; cin >> a >> b;
        int c; cin >> c;
        f[a][b]=min(f[a][b],c);
    }
           
          
    for (int u = 1; u <= n; u++) {
        for (int x = 1; x <= n; x++) {
            for (int y = 1; y <= n; y++) {
                f[x][y] = min(f[x][y], f[x][u] + f[u][y]);
            }
        }
    }
    for(int i=1;i<=k;i++){
        int x,y;cin>>x>>y;
        if(f[x][y] == INF) cout << "impossible" << endl;
        else cout << f[x][y] << endl;
    }
}
