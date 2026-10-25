#include<bits/stdc++.h>
using namespace std;
#define int long long
const int N=1e6+10;
int a[N],c[N],b[N];int ans=-1,n,jsq=0;
inline int read(){
    int x=0,f=1;
    char ch=getchar();
    while(ch< '0'||ch>'9'){
        if(ch=='-') f=-1;
        ch=getchar();
    }
    while(ch>='0'&&ch<='9'){
        x=(x<<1)+(x<<3)+(ch^48);
        ch=getchar();
    }
    return x*f;
}
inline void write(int x){
    if(x<0){
        putchar('-');
        x=-x;
    }
    if(x>9) write(x/10);
    putchar(x%10+'0');
}
bool check(int k){
	for(int i=1;i<=n;i++) b[i]=c[i];
	for(int i=1;i<=n;i++){
		if(b[i]+a[i]<k) return false;
		if(b[i]<k){
		//	if(b[i+1]-k+b[i]>=k&&b[]) 
			if((i==1||b[i-1]-k+b[i]>=k)&&(i==n||b[i+1]-k+b[i]>=k)){
				b[i+1]-=k-b[i];b[i-1]-=k-b[i];b[i]+=k-b[i];
			}
			else return false;
		}
	}
	for(int i=1;i<=n;i++) if(b[i]<k) return false;
	return true;
}
signed main(){
	freopen("pea.in","r",stdin);
	freopen("pea.out","w",stdout);
	n=read();
	int l=0,r=0;
	for(int i=1;i<=n;i++){
		a[i]=read();
		r+=a[i]*3;
		c[i-1]+=a[i];c[i]+=a[i];c[i+1]+=a[i];
	}
	while(l<=r){
		int mid=(l+r)/2;
		if(check(mid)) ans=mid,l=mid+1;
		else r=mid-1;
		//jsq++;
		//if(jsq>N){
		//	cout<<"kkkk"<<l<<" "<<r<<" "<<ans;
		//}
		//cout<<l<<" "<<r<<"\n";
	}
	write(ans);
	return 0;
}
