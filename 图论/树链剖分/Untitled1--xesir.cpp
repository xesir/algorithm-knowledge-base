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
//该代码中 seg[0] 表示当前节点数，需初始化为 0
void dfs2(int x,int f) {
	top[x]=f;
	seg[x]=++seg[0];
	rev[seg[0]]=x;
	if(son[x]) dfs2(son[x],f);
	for(int i:G8[x]){
	    if(i!=fah[x]&&i!=son[x]) dfs2(i, i);
	}
}
