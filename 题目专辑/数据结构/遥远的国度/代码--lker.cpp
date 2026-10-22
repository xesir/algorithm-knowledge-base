int fnd(int u,int v)
{
    while(top[u]!=top[v])
    {
        if(fa[top[v]]==u) return top[v];
        v=fa[top[v]];
    }
    return pos[dfn[u]+1];
}
