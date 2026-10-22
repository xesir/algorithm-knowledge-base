#include<bits/stdc++.h>
#pragma GCC target("avx")
#pragma GCC optimize(3)
#pragma GCC optimize("Ofast")
#pragma GCC optimize("inline")
#pragma GCC optimize("inline-functions")
#pragma GCC optimize("inline-small-functions")
#pragma GCC optimize("inline-functions-called-once")
namespace IO
{
    template <class T> inline void read (T &x) { x = 0; bool f = 0; char ch = getchar (); while (ch < '0' || ch > '9') f |= ch == '-', ch = getchar (); while (ch >= '0' && ch <= '9') x = (x << 3) + (x << 1) + (ch ^ 48), ch = getchar (); x = f ? ~x + 1 : x; }
	inline void read (char &ch) { ch = getchar (); }
	inline void read (char s[]) { char ch = getchar (); while (ch != ' ' && ch != '\n') *s++ = ch, ch = getchar (); }
	template <class T> inline void write (T x) { static char c[20]; unsigned p = 0; if (x < 0) putchar ('-'), x = ~x + 1; if (!x) { putchar ('0'); return ; } while (x) c[++p] = x % 10 ^ 48, x /= 10; while (p) putchar (c[p]), --p; }
	inline void write (char ch) { putchar (ch); }
	inline void write (char s[]) { while (*s) putchar (*s++); }
	template <class T, class... U> inline void read (T &x, U &...t) { read (x), read (t...); }
    template <class T, class... U> inline void write (T x, U ...t) { write (x), write (t...); }
};
#define int long long
using namespace std;
using namespace IO;
int q;
struct aqtw{ 
	struct redstone{
		int l=-1,r=-1;int wh,mi,ma;
		int addz=0,mulz=1;
		int gstz=-1;
	} wcj[4000100];
	int a[1000100];
	void fixtree(int u){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
        int lc=u<<1,rc=u<<1|1;
        wcj[u].wh=(wcj[lc].wh+wcj[rc].wh)%q;
        wcj[u].ma=max(wcj[lc].ma,wcj[rc].ma)%q;
        wcj[u].mi=min(wcj[lc].mi,wcj[rc].mi)%q;
    }
	void banzai(int p){
		if(wcj[p].gstz!=-1){
			int mid=(wcj[p].l+wcj[p].r)/2;
		wcj[p<<1].wh = wcj[p].gstz*(mid-wcj[p].l+1)%q;
		wcj[p<<1|1].wh = wcj[p].gstz*(wcj[p].r-mid)%q;
		wcj[p<<1].addz=0;wcj[p<<1].mulz=1;wcj[p<<1].ma=wcj[p].gstz;wcj[p<<1].mi=wcj[p].gstz;
		wcj[p<<1|1].addz=0;wcj[p<<1|1].mulz=1;wcj[p<<1|1].ma=wcj[p].gstz;wcj[p<<1|1].mi=wcj[p].gstz;
		}
		wcj[p<<1].wh = ((wcj[p].mulz*wcj[p<<1].wh)%q+(wcj[p].addz*(wcj[p<<1].r-wcj[p<<1].l+1))%q)%q;
		wcj[p<<1|1].wh = ((wcj[p].mulz*wcj[p<<1|1].wh)%q+(wcj[p].addz*(wcj[p<<1|1].r-wcj[p<<1|1].l+1))%q)%q;
		(wcj[p<<1].mulz *= wcj[p].mulz) %= q;
		(wcj[p<<1|1].mulz *= wcj[p].mulz) %= q;
		wcj[p<<1].addz = ((wcj[p<<1].addz*wcj[p].mulz)%q+wcj[p].addz)%q;
		wcj[p<<1|1].addz = ((wcj[p<<1|1].addz*wcj[p].mulz)%q+wcj[p].addz)%q;
		wcj[p].addz = 0, wcj[p].mulz = 1;wcj[p].gstz=-1;
	}
	void build(int u,int l,int r){
		wcj[u].l=l,wcj[u].r=r;
		wcj[u].addz=0,wcj[u].mulz=1;
		if(l==r) {wcj[u].wh=wcj[u].ma=wcj[u].mi=a[l];return;}
		int mid=(l+r)>>1;
		build(u<<1,l,mid);build(u<<1|1,mid+1,r);
		wcj[u].wh=wcj[u<<1].wh+wcj[u<<1|1].wh;
		wcj[u].mi=min(wcj[u<<1].mi,wcj[u<<1|1].mi);
		wcj[u].ma=max(wcj[u<<1].ma,wcj[u<<1|1].ma);
		return;
	}
	void setnewv(int u,int l,int r,int obl,int obr,int k){
			if(wcj[u].l==-1||wcj[u].r==-1) return;
			if(obl<=l&&r<=obr){
	            wcj[u].wh=k*(r-l+1);wcj[u].wh%=q;
	            wcj[u].ma=k;wcj[u].ma%=q;
	            wcj[u].mi=k;wcj[u].mi%=q;
	            wcj[u].addz=0;wcj[u].addz%=q;
	            wcj[u].mulz=1;
	            wcj[u].gstz=k;
	            return;
	        }
	        banzai(u);
	        int mid=(l+r)>>1;
	        if(obl<=mid) setnewv(u<<1,l,mid,obl,obr,k);
	        if(obr>mid) setnewv(u<<1|1,mid+1,r,obl,obr,k);
	        fixtree(u);	
		}
	void plustree(int u,int l,int r,int obl,int obr,int k){
		if(wcj[u].l==-1||wcj[u].r==-1) return;
		if(obl<=l&&r<=obr){
            wcj[u].wh+=k*(r-l+1);wcj[u].wh%=q;
            wcj[u].ma+=k;wcj[u].ma%=q;
            wcj[u].mi+=k;wcj[u].mi%=q;
            wcj[u].addz+=k;wcj[u].addz%=q;
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
            wcj[u].wh*=k;wcj[u].wh%=q;
            wcj[u].ma*=k;wcj[u].ma%=q;
            wcj[u].mi*=k;wcj[u].mi%=q;
            wcj[u].mulz*=k;wcj[u].mulz%=q;
            wcj[u].addz*=k;wcj[u].addz%=q;
            return;
        }
        banzai(u);
        int mid=(l+r)>>1;
        if(obl<=mid) promaxultree(u<<1,l,mid,obl,obr,k);
        if(obr>mid) promaxultree(u<<1|1,mid+1,r,obl,obr,k);
        fixtree(u);	
	}
	int findmax(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return LLONG_MIN;
		banzai(u);
		if(obl<=l&&r<=obr) return wcj[u].ma;
		int res=LLONG_MIN;
		int mad=(l+r)>>1;
		if(obl<=mad) res=max(res,findmax(u<<1,l,mad,obl,obr));
		if(obr>mad) res=max(res,findmax(u<<1|1,mad+1,r,obl,obr));
		return res;
	}
	int findxigema(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return 0;
		banzai(u);
		if(obl<=l&&r<=obr) return wcj[u].wh%q;
		int res=0;
		int mid=(l+r)>>1;
		if(obl<=mid) res+=findxigema(u<<1,l,mid,obl,obr),res%=q;
		if(obr>mid) res+=findxigema(u<<1|1,mid+1,r,obl,obr),res%=q;
		return res%q;
	}
	int findmin(int u,int l,int r,int obl,int obr){
		if(wcj[u].l==-1||wcj[u].r==-1) return LLONG_MAX;
		banzai(u);
		if(obl<=l&&r<=obr) return wcj[u].mi;
		int res=LLONG_MAX;
		int mid=(l+r)>>1;
		if(obl<=mid) res=min(res,findmin(u<<1,l,mid,obl,obr));
		if(obr>mid) res=min(res,findmin(u<<1|1,mid+1,r,obl,obr));
		return res;
	}
}lzx;
signed main(){
	int n,m;
	read(n), read(m), read(q);
	for(int i=1;i<=n;i++){
		read(lzx.a[i]);
		lzx.a[i]%=q;
	}
	lzx.build(1,1,n);
	while(m--){
		int c,x,y;
		int k;
		read(c);
		if(c==1){
			read(x), read(y), read(k);
			lzx.promaxultree(1,1,n,x,y,k%q);
		}else if(c==2){
			read(x), read(y), read(k);
			lzx.plustree(1,1,n,x,y,k%q);
		}else{
			read(x), read(y);
			write(lzx.findxigema(1,1,n,x,y)), write('\n');
		}
	}
    return 0; 
}
