#include <bits/stdc++.h>
using namespace std;
int f[1<<21][21];
int d[21][21];
int main(){
    int n,mi=1e9;cin>>n;
	memset(f,0x3f,sizeof f);
    for(int i=0;i<n;i++){
		for(int j=0;j<n;j++){
			cin>>d[i][j];
           // cout<<d[i][j]<<" ";
		}
       // cout<<endl;
	}
	//fghyhhtry6hfgbnncbnjkolojbxsdfgh寒食风。嗯。
/*	 /\
    //\\
   ///\\\
   sszzzss
	//996?wixin
    你活到头了
*/
    
    int M=(1<<n)-1;
    f[1][0]=0;
    for(int s=0;s<=M;s++){
		for(int i=0;i<n;i++){
			if(f[s][i]<0x3f3f3f3f){
				for(int j=0;j<n;j++){
					if(((s>>j)&1)==0){
                        //cout<<"f[M][i],mi);\n";
						int ns=s|(1<<j);
						f[ns][j]=min(f[ns][j],f[s][i]+d[i][j]);
					}//TDO
				}
			}//TODO
		}//TODO
	}
    //\\、、operator>>=(7)；
    for(int i=0;i<n;i++){
       // cout<<f[M][i]<<endl;
		mi=min(f[M][i]+d[i][0],mi);
	}
	cout<<mi;
}
