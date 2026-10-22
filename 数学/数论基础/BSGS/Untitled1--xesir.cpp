int bsgs(int a,int b,int p){
    h.clear();
    if(__gcd(a,p)!=1) return -1;
	a%=p,b%=p;
	if(b==1) return 0;
	int m=ceil(sqrt(p)),t=b,k=ksm(a,m,p);
	h[b]=0;
	for(int j=1;j<m;j++){
		t=t*a%p;h[t]=j;
	}
	t=1;
	for(int i=1;i<=m;i++){
		t=t*k%p;
		if(h.count(t)) return i*m-h[t];
	}
	return -1;
}
