#include<bits/stdc++.h>
using namespace std;
int main()
{
    int ti=0;
    while(1){
        system("./data");
        system("./bf");
        system("./mine");
        if(system("cmp -s bf.out mine.out"))
        {
            cout<<"WA/RE/MLE on test "<<++ti<<"\n";
            break;
        }
        else cout<<"AC on test"<<++ti<<"\n";
        if(ti==10)//这里的ti是数据组数,你希望拍多少组由你决定
            break;
    }
    return 0;
}
