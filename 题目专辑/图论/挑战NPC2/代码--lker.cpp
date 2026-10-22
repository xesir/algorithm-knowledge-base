bool dfs(int u,int v,int k)
{
    ull key=get_key(u,v,k);
    auto it=memo.find(key);
    if(it!=memo.end())
        return it->second;
    if(sz_f[u]<sz_g[v]) 
        return false;
    if(sz_f[u]-sz_g[v]>k)
        return false;
    int posl=0,posr=0;
    vector<int> fail_u;
    vector<int> fail_v;  
    while(posl<f[u].size()&&posr<g[v].size())
    {
        if(f[u][posl].val==g[v][posr].val)       
        {
            posl++;
            posr++;
        }else if(f[u][posl].val<g[v][posr].val){
            fail_u.push_back(f[u][posl].id);
            posl++;
        }else {
            fail_v.push_back(g[v][posr].id);
            posr++;            
        }
    }
    while(posl<f[u].size())
    {
        fail_u.push_back(f[u][posl].id);
        posl++;        
    }
    while(posr<g[v].size())
    {
        fail_v.push_back(g[v][posr].id);
        posr++;        
    }
    if(fail_u.size()<fail_v.size())
        return false;
    if(fail_u.size()>k) return false;
    sort(fail_u.begin(),fail_u.end());
    do{
        int used=0;
        bool ok=true;
        for(int i=fail_v.size();i<fail_u.size();i++)
            used+=sz_f[fail_u[i]];
        if(k<used) continue;
        for(int i=0;i<fail_v.size();i++)
        {
            int gu=fail_u[i];
            int gv=fail_v[i];
            int need=1;
            while(need<=k-used&&!dfs(gu,gv,need))
                need++;
            if(need>k-used){
                ok=false;
                break;
            }
            used+=need;
        }
        if(ok&&used<=k)
        {
            memo[key]=true;
            return true;
        } 
    }while(next_permutation(fail_u.begin(),fail_u.end()));
    memo[key]=false;
    return false;
}
