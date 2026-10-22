常规的
int ksm(int x,int y,int p){
    int res=1;
    if(y==0) return 1;
    if(y&1) res=x*ksm(x,y-1,p)%p;
    else res=ksm(x,y/2,p),res=res*res%p;
    return res;
}

位运算的
int ksm(int x,int y,int p){
    int res=1;
    while(y){
        if(y&1)res=res*x%p;
        x=x*x%p;
        y>>=1;
    }
    return res;
}
