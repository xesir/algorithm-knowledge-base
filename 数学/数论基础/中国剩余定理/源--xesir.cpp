// 基础CRT：求解同余方程组，a数组为余数，m数组为模数（两两互质），k为方程个数

ll crt(ll a[], ll m[], ll k) {
    ll M = 1, res = 0;
    for (ll i = 1; i <= k; i++) M *= m[i]; // 模数乘积M
    for (ll i = 1; i <= k; i++) {
        ll mi = m[i], ai = a[i];
        ll Mi = M / mi; // Mi = M / mi（与mi互质）
        ll inv_Mi = inv(Mi, mi); // Mi在模mi下的逆元
        res = (res + ai * Mi % M * inv_Mi % M) % M; // 累加解
    }
    return res;
}
ll excrt(ll c[],ll m[],ll k){
	ll a=1,b=0,x=0,y=0;
	for(int i=1;i<=k;i++){
		ll g=exgcd(a,c[i],x,y);
		x*=(b-m[i])/g;
		b-=a*x;
		a*=c[i]/g;
		b=(b%a+a)%a;
	}
	return b=(b%a+a)%a;
}
