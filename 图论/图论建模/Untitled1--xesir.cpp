for(int i=1;i<=m;i++){
    int u,v,w;cin>>u>>v>>w;
    for(int j=0;j<=k;j++){
        G1[u+j*n].push_back({v+j*n,w});
        G1[v+j*n].push_back({u+j*n,w});
    }
    for(int j=0;j<k;j++){
        G1[u+j*n].push_back({v+(j+1)*n,0});
        G1[v+j*n].push_back({u+(j+1)*n,0});
    }
}
