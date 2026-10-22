#include <bits/stdc++.h>
using namespace std;
const int N=1e9;
bool v[N];
vector<vector<int>> s(N);
int h[N];
vector<int> pai;
queue<int> q;
int n,m;
int main() {
    cin>>n>>m;
    for (int i=1;i<=m;i++) {
        int x,y;
        cin>>x>>y;
        s[x].push_back(y); 
        h[y]++;
    }
    for(int i=1;i<=n;i++){
        if(h[i]==0){
            q.push(i);
            pai.push_back(i);             
        }
    }
    while (q.size()) {
        int t=q.front();
        q.pop();                 
        for(int j:s[t]){            
            h[j]--;
            if(h[j]==0){q.push(j);pai.push_back(j);}            
        } 
    }
    if(pai.size()==n){
        for(auto i:pai){
            cout<<i<<" ";
        }
    }else{
        cout<<-1;
    }
    return 0;
}
