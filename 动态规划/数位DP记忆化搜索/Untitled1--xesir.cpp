int digits; // 存储 N 的各位数字
long long dp[...]; // 记忆化数组，维度根据状态而定
// dfs 函数
long long dfs(int pos, ..., bool is_limited, bool is_leading_zero) {
	// 1. 递归基：所有位都填完了
	if (pos == 0) return 1; // 或其他基本情况
	// 2. 记忆化：在特定条件下查表
	if (!is_limited && !is_leading_zero && dp[pos][...] != -1) {
		return dp[pos][...];
	}
	long long ans = 0;
	int upper_bound = is_limited ? digits[pos] : 9; // 确定当前位的上限
	// 3. 循环遍历当前位可以填的数字
	for (int i = 0; i <= upper_bound; ++i) {
		// ... 检查 i 是否合法 ...
		ans += dfs(pos - 1, ..., new_is_limited, 		new_is_leading_zero);
	}
	// 4. 记录状态
	if (!is_limited && !is_leading_zero) {
		dp[pos][...] = ans;
	}
	return ans;
}
long long solve(long long n) {
	if (n < 0) return 0;
	if (n == 0) return 1; // 0 是一个满足条件的数（如果题目允许）
	// 1. 将 n 转换为数位数组
	int len = 0;
	while (n > 0) {
		digits[++len] = n % 10;
		n /= 10;
	}
	// 2. 初始化 DP 数组
	memset(dp, -1, sizeof(dp));
	// 3. 从最高位开始 DFS
	// 注意：digits 数组是反的，所以从 len 开始
	return dfs(len, ..., true, true);
}
// 主程序入口
long long result = solve(R) - solve(L - 1);
#include <bits/stdc++.h>
using namespace std;
#define int long long
string l,r;
int dp[30][2][30][2],N[30];
int dqw;
int dfs(int w,int is_limited,int qianyiwei,int qdz){
    if(dp[w][is_limited][qianyiwei][qdz]!=-1) return dp[w][is_limited][qianyiwei][qdz];
    if(w==dqw+1) return 1;
    dp[w][is_limited][qianyiwei][qdz]=0;
    for(int i=0;i<10;i++){
        if(abs(qianyiwei-i)<2&&qdz!=1) continue;
        if(is_limited&&i>N[w]) continue;
        dp[w][is_limited][qianyiwei][qdz]+=dfs(w+1,is_limited&&(i==N[w]),i,qdz&&(i==0));
    }
    return dp[w][is_limited][qianyiwei][qdz];
}
int solve(string x){
	memset(dp,-1,sizeof dp);
	 for(int i=0;i<x.size();i++){
	           N[i+1]=x[i]-48;
	       }
	 dqw=x.size();
	 return dfs(1,1,0,1);
}
signed main(){
	int a,b;cin>>a>>b;a--;
	l=to_string(a),r=to_string(b);
	cout<<solve(r)-solve(l);
}
#include <bits/stdc++.h>
using namespace std;
#define int long long
string l,r;
int dp[20][2][20][2][4][4],N[20];
int dqw;
int dfs(int w,int tit,int hyw,int qdz,int mp3,int k84){
    if(dp[w][tit][hyw][qdz][mp3][k84]!=-1) return dp[w][tit][hyw][qdz][mp3][k84];
    if(w==dqw+1){
		if(mp3>=3) return 1;
		else return 0;
	}
    dp[w][tit][hyw][qdz][mp3][k84]=0;
    for(int i=0;i<10;i++){
        if(tit&&i>N[w]) continue;
        int nk84=k84,nmp3=mp3;
        if(i==8) nk84=k84|2;
        if(i==4) nk84=k84|1;
        if(mp3<3){
			if(i==hyw&&!qdz) nmp3=mp3+1;
			else nmp3=1;
		}
        if(nk84==3) continue;
        dp[w][tit][hyw][qdz][mp3][k84]+=dfs(w+1,tit&&(i==N[w]),i,qdz&&(i==0),nmp3,nk84);
    }
    return dp[w][tit][hyw][qdz][mp3][k84];
}
int solve(string x){
	memset(dp,-1,sizeof dp);
	for(int i=0;i<(int)x.size();i++){
	    N[i+1]=x[i]-'0';
	}
	dqw=x.size();
	return dfs(1,1,0,1,1,0);
}
signed main(){
	int a,b;cin>>a>>b;a--;
	l=to_string(a),r=to_string(b);
    int cnt=solve(r)-solve(l);
	cout<<cnt;
}
