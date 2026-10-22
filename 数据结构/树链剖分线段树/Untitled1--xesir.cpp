#include<bits/stdc++.h>
#define endl '\n'
#define fi first
#define se second
#define lowbit(x) (x&(-x))
#define int long long
#define ls u<<1
#define rs (u<<1)|1 
#define mid ((l+r)>>1)
using namespace std;
typedef pair<int,int> PII;
typedef long long ll;
const int N=1e5+10;
int n,m,r,p;
//int a[N];
inline int read();
inline void write(int x);
struct divtree{
	vector<int> G8[N];
	int fah[N],dep[N],siz[N],son[N];
	int top[N],seg[N],rev[N];
	int a[N];
	void dfs1(int x,int f){
		dep[x]=dep[f]+1;
		fah[x]=f;
		siz[x]=1;
		for(int i:G8[x]){
			if(i==f) continue;
			dfs1(i,x);
			siz[x]+=siz[i];
			if(siz[son[x]]<siz[i]) son[x]=i;
		}
	}
	void dfs2(int x,int f) {
	    top[x]=f;
	    seg[x]=++seg[0];
	    rev[seg[0]]=x;
	    if(son[x]) dfs2(son[x],f);
	    for(int i:G8[x]){
	        if(i!=fah[x]&&i!=son[x]) dfs2(i, i);
	    }
	}
	void init(){
		dfs1(r,0);
		seg[0]=0;
		dfs2(r,r);
	}
	struct note{
		int l=-1,r=-1;
		int wh=0,ma=LLONG_MIN;
		int laz=0;
	} xdt[N<<2];
	void buildtree(int u,int l,int r){
		xdt[u].l=l;xdt[u].r=r;xdt[u].laz=0;
		if(l==r){
			xdt[u].ma=xdt[u].wh=a[rev[l]];
			return ;
		}
		buildtree(ls,l,mid);
		buildtree(rs,mid+1,r);
		xdt[u].ma=max(xdt[ls].ma,xdt[rs].ma);
		xdt[u].wh=xdt[ls].wh+xdt[rs].wh;
	}
	void fixup(int u){
		xdt[u].ma=max(xdt[ls].ma,xdt[rs].ma);
		xdt[u].wh=xdt[ls].wh+xdt[rs].wh;
	}
	void pushdown(int u,int l,int r){
		xdt[ls].laz+=xdt[u].laz;xdt[rs].laz+=xdt[u].laz;
		xdt[ls].ma+=xdt[u].laz;xdt[rs].ma+=xdt[u].laz;
		xdt[ls].wh+=xdt[u].laz*(mid-l+1);xdt[rs].wh+=xdt[u].laz*(r-mid);
		xdt[u].laz=0;
	}
	void promaxultra(int u,int l,int r,int obl,int obr,int v){
		if(l>obr||r<obl) return ;
		if(l>=obl&&r<=obr){
			xdt[u].wh+=(r-l+1)*v;
			xdt[u].ma+=v;xdt[u].laz+=v;
			return ;
		}
		pushdown(u,l,r);
		promaxultra(ls,l,mid,obl,obr,v);
		promaxultra(rs,mid+1,r,obl,obr,v);
		fixup(u);
	}
	int findinfo(int u,int l,int r,int obl,int obr,bool v){//v=true:查最值
		if(l>obr||r<obl){
			if(v) return LLONG_MIN;
			else return 0;
		}
		if(l>=obl&&r<=obr){
			if(v) return xdt[u].ma;
			else return xdt[u].wh;
		}
		pushdown(u,l,r);
		int res=0;
		if(v) return res=max(findinfo(ls,l,mid,obl,obr,v),findinfo(rs,mid+1,r,obl,obr,v));
		else return res=findinfo(ls,l,mid,obl,obr,v)+findinfo(rs,mid+1,r,obl,obr,v);
		fixup(u);
	}
	void plustree(int x,int y,int v){
		int fx=top[x],fy=top[y];
		while (fx!=fy) {
		    if (dep[fx]<dep[fy]) swap(x,y),swap(fx,fy);
		    promaxultra(1,1,seg[0],seg[fx],seg[x],v);
		    x=fah[fx];fx=top[x];
		}
		if(dep[x]<dep[y]) swap(x,y);
		promaxultra(1,1,seg[0],seg[y],seg[x],v);
	}
	void plusroot(int x,int v){
		promaxultra(1,1,seg[0],seg[x],seg[x]+siz[x]-1,v);
	}
	int queryroot(int x,bool v){
		return findinfo(1,1,seg[0],seg[x],seg[x]+siz[x]-1,v);
	}
	int querytree(int x,int y,bool v){
		int ans;
		if(v) ans=LLONG_MIN;
		else ans=0;
		int fx=top[x],fy=top[y];
		while(fx!=fy){
			if (dep[fx]<dep[fy]) swap(x,y),swap(fx,fy);
			if(v) ans=max(ans,findinfo(1,1,seg[0],seg[fx],seg[x],v));
			else ans+=findinfo(1,1,seg[0],seg[fx],seg[x],v);
			x=fah[fx];fx=top[x];
		}
		if(dep[x]<dep[y]) swap(x,y);
		if(v) ans=max(ans,findinfo(1,1,seg[0],seg[y],seg[x],v));
		else ans+=findinfo(1,1,seg[0],seg[y],seg[x],v);
		return ans;
	}
} lse;
signed main(){
//    freopen(".in","r",stdin);
//    freopen(".out","w",stdout);
    ios::sync_with_stdio(false);
    cin.tie(nullptr);cout.tie(nullptr);
	cin>>n>>m>>r>>p;
	for(int i=1;i<=n;i++){
		cin>>lse.a[i];
	}
    for(int i=1;i<n;i++){
        int u,v;cin>>u>>v;
        lse.G8[u].push_back(v);
        lse.G8[v].push_back(u);
    }
	lse.init();
	lse.buildtree(1,1,n);
	while(m--){
		int c;cin>>c;
		if(c==1){
			int x,y,z;cin>>x>>y>>z;
			lse.plustree(x,y,z);
		}else if(c==2){
			int x,y;cin>>x>>y;
			int cnt=lse.querytree(x,y,false)%p;
			cout<<cnt<<'\n';
		}else if(c==3){
			int x,z;cin>>x>>z;
			lse.plusroot(x,z);
		}else if(c==4){
			int x;cin>>x;
			int cnt=lse.queryroot(x,false)%p;
			cout<<cnt<<"\n";
		}
	}
    return 0;
}
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
