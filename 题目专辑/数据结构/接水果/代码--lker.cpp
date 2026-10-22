void dfs(int u,int f)
{
    for(int id:vl[u]) cur_l[id]=cur_l[id]^1;
    for(int id:vr[u]) cur_r[id]=cur_r[id]^1;
    if(is_query_node[u])
    {
        fl[u]=cur_l;
        fr[u]=cur_r;
    }
    for(int i=h[u];~i;i=ne[i])
    {
        int j=to[i];
        if(j==f) continue;
        dfs(j,u);
    }
    for(int id:vl[u]) cur_l[id]=cur_l[id]^1;
    for(int id:vr[u]) cur_r[id]=cur_r[id]^1;
}

    for(int i=1;i<=p;i++)
    {
        int u=path[i].a,v=path[i].b;
        int lca=get_lca(u,v);
        if(dep[u]>dep[v]) swap(u,v);
        if(u==lca)
        {
            int t=get_son(u,v);
            vl[1].push_back(i);
            vl[t].push_back(i);
            vr[v].push_back(i);
        }else{
            vl[u].push_back(i);
            vr[v].push_back(i);
        }
    }
    for(int i=1;i<=q;i++)
    {
        cin>>qes[i].a>>qes[i].b>>qes[i].k;
        is_query_node[qes[i].a]=1;
        is_query_node[qes[i].b]=1;
    }  

    for(int i=1;i<=q;i++)
    {
        int u=qes[i].a,v=qes[i].b;
        bitset<N> val=(fl[u]&fr[v])|(fr[u]&fl[v]);
        int pos=val._Find_first();
        for(int j=1;j<qes[i].k;j++)
            pos=val._Find_next(pos);
        cout<<path[pos].c<<"\n";
    }
