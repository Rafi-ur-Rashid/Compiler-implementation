#include "1505045_linkedListDoubly.cpp"
#include<stdio.h>
#include<stdlib.h>
#include<cmath>
#include<iostream>
#include<time.h>
#define NULL_VALUE -99999
#define SUCCESS_VALUE 99999
#define LIST_INIT_SIZE 2
#define Tlength 2
#define Wlength 5
#define C 26
using namespace std;
void gen_random(char *s)
{
    static const char alphanum[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i = 0; i < Wlength; ++i)
    {
        s[i] = alphanum[rand() % (sizeof(alphanum) - 1)];
    }
    s[Wlength] = 0;
}
int hash2(char* s)
{
    int h =0,j=0;
    while (*s)
    {
        h+=(*s)*pow(C,j);
        s++;
        j++;
    }
    return h%Tlength; // or return h % C;
}
int hash1(char* s)
{
    double A=(sqrt(5)-1)/2;
    int h =0,j=0;
    while (*s)
    {
        h+=(*s)*pow(C,j);
        s++;
        j++;
    }
    return (int)(Tlength*((h*A)-(int)(h*A))); // or return h % C;
}
int hash3(char* s)
{
   double A=(sqrt(11)-1)/2;
    int h =0,j=0;
    while (*s)
    {
        h+=(*s)*pow(C,j);
        s++;
        j++;
    }
    return (int)(Tlength*((h*A)-(int)(h*A)));  // or return h % C;
}
class ScopeTable
{
    linkList * T;
    int id;
    ScopeTable* parentScope;
    int*key;
    int length;
    int hCheck=2;
    float collision_Rate;
public:
    ScopeTable()
    {
        length=0;
        parentScope=0;
        id=NULL_VALUE;
        T = new linkList[Tlength];
        key=new int[Tlength];
        for(int i=0; i<Tlength; i++)
        {
            key[i]=NULL_VALUE;
        }
        collision_Rate=0;
    };
    ~ScopeTable()
    {
        free(T);
    };
    void initializeList();
    void clear();
    int getLength();
    listNode* searchItem(char* key);
    listNode* searchItem2(char* key,int& off,int& p);
    void setParent(ScopeTable* table){parentScope=table;};
    ScopeTable* getParent(){return parentScope;};
    void setId(int sid){id=sid;};
    int getId(){return id;};
    //int insertDummyItems();
    bool insertItem(SymbolInfo info);
    bool deleteItem(char* x);
    void printList();
    void printListInFile(FILE* output);
    void deleteAll();
    void generateReport();
    void setHcheck(int H){hCheck=H;};
};
void ScopeTable::initializeList()
{
}
void ScopeTable::clear()
{
    length=0;
    free(T);
    free(key);
}
listNode* ScopeTable::searchItem(char* key)
{
    int i=0,off;
    int pos;
    if(hCheck==1)
        pos=hash1(key);
    else if(hCheck==2)
        pos=hash2(key);
     else if(hCheck==3)
        pos=hash3(key);
 //cout<<pos<<endl;
    listNode* temp= T[pos].searchItem(key,off);
    if(temp){
        printf("Found in ScopeTable# %d at position %d, %d\n",id,pos,off);

    }
    return temp;
}
listNode* ScopeTable::searchItem2(char* key,int& x,int& p)
{
    int i=0,off;
    int pos;
    if(hCheck==1)
        pos=hash1(key);
    else if(hCheck==2)
        pos=hash2(key);
     else if(hCheck==3)
        pos=hash3(key);
 //cout<<pos<<endl;
    listNode* temp= T[pos].searchItem(key,off);
    if(temp){
        x=off;
        p=pos;
    }
    return temp;
}

bool ScopeTable::insertItem(SymbolInfo info)
{
    char* x=info.getType();
    char* k=info.getName();
    int dummy;
//    if(length>=Tlength)
//    {
//        cout<<"No more elements can be inserted\n"<<endl;
//        return false;
//    }
    int pos;
    if(hCheck==1)
        pos=hash1(k);
    else if(hCheck==2)
        pos=hash2(k);
    else if(hCheck==3)
        pos=hash3(k);
    if(!T[pos].checkEmpty())
        collision_Rate++;
    if(T[pos].searchItem(k,dummy)){
        cout<<"Already in the Scope Table\n"<<endl;
        return false;
    }
    else
    {
        int off=T[pos].insertLast(k,x);
        printf("Inserted in ScopeTable# %d at position %d, %d\n",id,pos,off);
        length++;
        return true;
    }
}
//int ScopeTable::insertDummyItems()
//{
//    for(int i=0; i<Tlength; i++)
//    {
//        char* c=new char[Wlength];
//        gen_random(c);
//        insertItem(i+1,c);
//    }
//};
bool ScopeTable::deleteItem(char* k)
{
    if(length<1)
        return NULL_VALUE;
    int pos;
    if(hCheck==1)
        pos=hash1(k);
    else if(hCheck==2)
        pos=hash2(k);
    else if(hCheck==3)
        pos=hash3(k);
    length--;
    int t= T[pos].deleteItem(k);
    if(t==-1)
        return false;
    else
    {
        printf("Deleted entry from current ScopeTable\n");
        return true;
    }

}
void ScopeTable::deleteAll()
{
    T=0;
    key=0;
    length=0;
    collision_Rate=0;
}
void ScopeTable::printList()
{
    int i;
    //printf("number of item inserted: %d\n",length);
    if(length==0 )
    {
        printf("The Table is empty\n");
        return;
    }
    for(i=0; i<Tlength; i++){
        if(!T[i].checkEmpty()){
                printf("%d-> ",i);
            T[i].printListForward();
            cout<<endl;
        }
    }

}
void ScopeTable::printListInFile(FILE* output)
{
    int i;
    //printf("number of item inserted: %d\n",length);
    if(length==0 )
    {
        printf("The Table is empty\n");
        return;
    }
    for(i=0; i<Tlength; i++){
        if(!T[i].checkEmpty()){
                fprintf(output,"%d-> ",i);
            T[i].printListInFile(output);
        }
    }

}
/*void ScopeTable::generateReport()
{
    printf("collision Rate: %f%  &   ",collision_Rate*100.0/Tlength);
    char** dummyItems=new char*[Tlength];
    for(int i=0; i<Tlength; i++)
    {
        dummyItems[i]=new char[5];
        char* c=new char[5];
        gen_random(c);
        for(int j=0; j<i; j++)
        {
            if(!strcmp(dummyItems[j],c))
            {
                gen_random(c);
                j=0;
            }
        }
        dummyItems[i]=c;
    }
    clock_t t1, t2;
    t1 = clock();
    for(int i=0; i<Tlength; i++)
        searchItem(dummyItems[i]);
    t2 = clock();
    float diff = ((float)(t2 - t1) / 1000000.0F ) * 1000;
    printf("time elapsed  %f ms\n",diff);

}
*/
int ScopeTable::getLength()
{
    return length;
}
/*
int main()
{
    ScopeTable h;
    //h.initializeList();
    while(1)
    {
        printf("1. Insert item. 2. Look up item. 3. delete item.\n");
        printf("4. Print Table. 5.exit\n");
        int ch;
        scanf("%d",&ch);
        if(ch==1)
        {
            SymbolInfo info;
            char* value=new char[25];
            char* s=new char[25];
            printf("enter a name: ");
            scanf("\n%s", value);
            printf("enter a type: ");
            scanf("\n%s",s);
            info.setName(value);
            info.setType(s);
            h.insertItem(info);
        }
        else if(ch==2)
        {
            char* s=new char[25];
            printf("enter a key: ");
            scanf("\n%s",s);
            char* result=h.searchItem(s);
            if(result==0 )
                printf("The key %s does not belong to the table.\n",s);
            else
                printf("The key %s hashes the satellite value %s\n",s,result);
        }
        else if(ch==3)
        {
            char* k;
            printf("enter a name: ");
            scanf("%s", k);
            int result=h.deleteItem(k);
            if(result==NULL_VALUE)
                printf("The table is empty\n");
            else if(result==-1)
                printf("The name %s is not present in the table.\n",k);
            else
                printf("Deleted successfully!\n");

        }
        else if(ch==4)
        {
            h.printList();
        }
        else if(ch==5)
        {
            h.clear();
            break;
        }

    }
}

*/

