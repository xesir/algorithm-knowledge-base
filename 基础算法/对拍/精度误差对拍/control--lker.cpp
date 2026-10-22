#include<bits/stdc++.h>
using namespace std;
#define eps 1e-3
int main()
{
    int ti=0;
    while(1){
        system("./data");
        system("./bf");
        system("./mine");
        double bf,mn;
        freopen("bf.out","r",stdin);
        cin>>bf;
        cin.clear();
        freopen("mine.out","r",stdin);
        cin>>mn;
        cin.clear();
        if(fabs(mn-bf)>eps)
        {
            cout<<"WA/RE/MLE on test "<<++ti<<"\n";
            break;
        }
        else cout<<"AC on test"<<++ti<<"\n";
        if(ti==10)
            break;
    }
    return 0;
}
