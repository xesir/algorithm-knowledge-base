#include<bits/stdc++.h>
using namespace std;

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

#define int long long
using namespace std;

int q;

struct aqtw{ 
	struct redstone{
		int l=-1,r=-1;
		int wh;
		int addz=0,mulz=1;
	} wcj[800100];
	int a[200100];

	void fixtree(int u){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
        int lc=u<<1,rc=u<<1|1;
        wcj[u].wh=(wcj[lc].wh+wcj[rc].wh)%q;
    }

	void banzai(int p){
		if(wcj[p].l==-1||wcj[p].r==-1) return;
		int lc=p<<1, rc=p<<1|1;
		int lenL = wcj[lc].r - wcj[lc].l + 1;
		int lenR = wcj[rc].r - wcj[rc].l + 1;
		// 下推乘法
		if(wcj[p].mulz != 1){
			wcj[lc].wh = wcj[lc].wh * wcj[p].mulz % q;
			wcj[rc].wh = wcj[rc].wh * wcj[p].mulz % q;
			wcj[lc].mulz = wcj[lc].mulz * wcj[p].mulz % q;
			wcj[rc].mulz = wcj[rc].mulz * wcj[p].mulz % q;
			wcj[lc].addz = wcj[lc].addz * wcj[p].mulz % q;
			wcj[rc].addz = wcj[rc].addz * wcj[p].mulz % q;
		}
		// 下推加法
		if(wcj[p].addz != 0){
			wcj[lc].wh = (wcj[lc].wh + wcj[p].addz * lenL) % q;
			wcj[rc].wh = (wcj[rc].wh + wcj[p].addz * lenR) % q;
			wcj[lc].addz = (wcj[lc].addz + wcj[p].addz) % q;
			wcj[rc].addz = (wcj[rc].addz + wcj[p].addz) % q;
		}
		wcj[p].mulz = 1;
		wcj[p].addz = 0;
	}

	void build(int u,int l,int r){
		wcj[u].l=l,wcj[u].r=r;
		wcj[u].addz=0,wcj[u].mulz=1;
		if(l==r) {wcj[u].wh=a[l]; return;}
		int mid=(l+r)>>1;
		build(u<<1,l,mid);
		build(u<<1|1,mid+1,r);
		wcj[u].wh=(wcj[u<<1].wh+wcj[u<<1|1].wh)%q;
	}

	void plustree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l&&r<=obr){
            wcj[u].wh = (wcj[u].wh + k * (r-l+1)) % q;
            wcj[u].addz = (wcj[u].addz + k) % q;
            return;
        }
        banzai(u);
        int mid=(l+r)>>1;
        if(obl<=mid) plustree(u<<1,l,mid,obl,obr,k);
        if(obr>mid) plustree(u<<1|1,mid+1,r,obl,obr,k);
        fixtree(u);	
	}

	void promaxultree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l&&r<=obr){
            wcj[u].wh = wcj[u].wh * k % q;
            wcj[u].mulz = wcj[u].mulz * k % q;
            wcj[u].addz = wcj[u].addz * k % q;
            return;
        }
        banzai(u);
        int mid=(l+r)>>1;
        if(obl<=mid) promaxultree(u<<1,l,mid,obl,obr,k);
        if(obr>mid) promaxultree(u<<1|1,mid+1,r,obl,obr,k);
        fixtree(u);	
	}

	int findxigema(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return 0;
		banzai(u);
		if(obl<=l&&r<=obr) return wcj[u].wh % q;
		int res=0;
		int mid=(l+r)>>1;
		if(obl<=mid) res=(res+findxigema(u<<1,l,mid,obl,obr))%q;
		if(obr>mid) res=(res+findxigema(u<<1|1,mid+1,r,obl,obr))%q;
		return res%q;
	}
}lzx;

signed main(){
	int n,m;
	n=read(); m=read(); q=read();
	for(int i=1;i<=n;i++){
		lzx.a[i]=read();
		lzx.a[i]%=q;
	}
	lzx.build(1,1,n);
	while(m--){
		int c,x,y;
		int k;
		c=read();
		if(c==1){
			x=read(); y=read(); k=read();
			lzx.promaxultree(1,1,n,x,y,k%q);
		}else if(c==2){
			x=read(); y=read(); k=read();
			lzx.plustree(1,1,n,x,y,k%q);
		}else{
			x=read(); y=read();
			int ans = lzx.findxigema(1,1,n,x,y);
			write(ans);
			putchar('\n');
		}
	}
    return 0; 
}
