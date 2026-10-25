#include <bits/stdc++.h>
using namespace std;
#define int long long
#define mid ((l+r)/2)
#define ls (u<<1)
#define rs ((u<<1)|1)
const int N=3e5+10;
int n;
int a[N];
struct redstone{
	int u,l,r;
	int wh;
	bool lag,q1;
} wcj[4*N];
void build(int u,int l,int r){
	wcj[u].u=u;wcj[u].l=l;wcj[u].r=r;
	wcj[u].lag=false;
	if(l==r){
		wcj[u].wh=a[l];wcj[u].q1=(bool)(a[l]<=1);
		//cout<<wcj[u].u<<" "<<wcj[u].l<<" "<<wcj[u].r<<" "<<wcj[u].wh<<" "<<wcj[u].lag<<" "<<wcj[u].q1<<'\n';
		return ;
	}
	build(ls,l,mid);build(rs,mid+1,r);
	wcj[u].wh=wcj[ls].wh+wcj[rs].wh;
	wcj[u].q1=wcj[ls].q1&&wcj[rs].q1;
	//cout<<wcj[u].u<<" "<<wcj[u].l<<" "<<wcj[u].r<<" "<<wcj[u].wh<<" "<<wcj[u].lag<<" "<<wcj[u].q1<<'\n';
}
void pushup(int u){
	if(wcj[u].l==wcj[u].r){
		wcj[u].q1=(bool)(wcj[u].wh<=1);
		//cout<<wcj[u].u<<" "<<wcj[u].l<<" "<<wcj[u].r<<" "<<wcj[u].wh<<" "<<wcj[u].lag<<" "<<wcj[u].q1<<'\n';
		return ;
	}
	wcj[u].wh=wcj[ls].wh+wcj[rs].wh;
	wcj[u].q1=wcj[ls].q1&&wcj[rs].q1;
}
void pushdown(int u){
	if(!wcj[u].lag) return ;
	if(wcj[u].q1){
	    wcj[u].lag=false;
	    return;
	}
	if(wcj[u].l==wcj[u].r){
		wcj[u].wh=sqrtl(wcj[u].wh);
		//cout<<u<<" "<<wcj[u].wh<<'\n';
		wcj[u].q1=(bool)(wcj[u].wh<=1);
		wcj[u].lag=false;
		return ;
	}
	if(wcj[ls].lag) pushdown(ls);
	if(wcj[rs].lag) pushdown(rs);
	if(wcj[u].lag){
		wcj[ls].lag=true;wcj[rs].lag=true;wcj[u].lag=false;
		pushdown(ls);pushdown(rs);
		pushup(u);
	}
}
void forget(int u,int obl,int obr){
	//cout<<u<<endl;
	if(wcj[u].r<obl||wcj[u].l>obr) return ;
	//cout<<u<<endl;
	if(wcj[u].l>=obl&&wcj[u].r<=obr){
		wcj[u].lag=true;pushdown(u);pushup(u);
		//cout<<u<<endl;
		return ;
	}
	//cout<<u<<endl;
	pushdown(u);pushup(u);
	//cout<<u<<endl;
	int l=wcj[u].l,r=wcj[u].r;
	if(obl<=mid) forget(ls,obl,obr);
	if(obr>mid) forget(rs,obl,obr);
	pushdown(u);pushup(u);
	return ;
}
int zhuiyi(int u,int obl,int obr){
	if(wcj[u].r<obl||wcj[u].l>obr) return 0;
	if(wcj[u].l>=obl&&wcj[u].r<=obr){
		pushdown(u);pushup(u);
		//cout<<u<<"%"<<wcj[u].wh<<'\n';
		return wcj[u].wh;
	}
	pushdown(u);pushup(u);
	int res=0;
	int l=wcj[u].l,r=wcj[u].r;
	if(obl<=mid) res+=zhuiyi(ls,obl,obr);
	if(obr>mid) res+=zhuiyi(rs,obl,obr);
	pushdown(u);pushup(u);
	return res;
}
signed main(){
	ios::sync_with_stdio(0);
	cin.tie(0);cout.tie(0);
	cin>>n;
	for(int i=1;i<=n;i++) cin>>a[i];
	build(1,1,n);
	for(int i=1;i<=n;i++){
		int op,l,r;cin>>op>>l>>r;
		if(op) cout<<zhuiyi(1,l,r)<<'\n';
		else forget(1,l,r);
	}
	return 0;
}
