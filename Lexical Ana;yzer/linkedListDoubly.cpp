#include<stdio.h>
#include<stdlib.h>
#include<cstring>
#define NULL_VALUE -99999
#define SUCCESS_VALUE 99999
class SymbolInfo
{
   private:
       char* Name;
       char* Type;
    public:
        void setName(char* name){Name=name;};
        void setType(char* type){Type=type;};
        char* getName(){return Name;};
        char* getType(){ return Type;};
};
struct listNode
{
    SymbolInfo item;
    struct listNode * next;
    struct listNode * prev;
};

class linkList{
struct listNode * list;
int length;
public:
    linkList(){list=0;length=0;};
    int insertLast(char* key,char* val) ;
    int deleteItem(char* value);
    listNode* searchItem(char* key,int& off);
    void printListForward();
    void printListInFile(FILE* output);
    int getLength(){return length;};
    bool checkEmpty(){return (list==0);};
};

int linkList::insertLast(char* key,char* val) //insert at the beginning
{
    struct listNode * newNode ;
    int off=0;
    newNode = (struct listNode*) malloc (sizeof(struct listNode)) ;
    newNode->item.setType(val);
    newNode->item.setName(key);
    if(list==0) //inserting the first item
    {
        newNode->next = 0;
        newNode->prev = 0;
        list = newNode;
        return off;
    }
    else
    {
        newNode->next = 0;
        //printf("%p %p %d",tail,tail->prev);
    }
    //printf("%d\n",tail->item.value);
    struct listNode * temp=list;
    while(1)
    {
        off++;
        if(temp->next==0)
        {
            newNode->prev=temp;
            temp->next=newNode;
            break;
        }
        else
            temp=temp->next;
    }
    length++;
    return off;
}


int linkList::deleteItem(char* key)
{
    struct listNode *foo,* temp=list;
    if(list==0)
        return -1;
    else if(!strcmp(list->item.getName(),key))
    {
        if(list->next==0)
        {
            list=0;
            length=0;
            return SUCCESS_VALUE;
        }
        foo=list;
        list=list->next;
        list->prev=0;
        length--;
        free(foo);
        return SUCCESS_VALUE;
    }
    while(strcmp(temp->item.getName(),key))
    {
        temp=temp->next;
        if(temp==0)
            return -1;
    }
    foo=temp;
    temp->prev->next=temp->next;
    if(temp->next!=0)
        temp->next->prev=temp->prev;
    free(foo);
    length--;
    return SUCCESS_VALUE ;

}

listNode* linkList::searchItem(char* key,int& off)
{
    struct listNode * temp ;
    off=0;
    temp = list ; //start at the beginning
    while (temp != 0)
    {
        if (!strcmp(temp->item.getName(),key))
            return temp ;
        temp = temp->next ; //move to next node
        off++;
    }
    return  0; //0 means invalid pointer in C, also called NULL value in C
}

void linkList::printListForward()
{
    struct listNode * temp;
    temp = list;
    while(temp!=0)
    {

        printf("<%s,%s>  ", temp->item.getName(),temp->item.getType());
        temp = temp->next;
    }
    printf("\n");
}
void linkList::printListInFile(FILE* output)
{
    struct listNode * temp;
    temp = list;
    while(temp!=0)
    {
        fprintf(output,"<%s,%s>  ", temp->item.getName(),temp->item.getType());
        temp = temp->next;
    }
    fprintf(output,"\n");
}
/*
int main(void)
{
    linkList l;
    while(1)
    {
        printf("1. Insert new item. 2. Delete item. 3. Search item. \n");
        printf("4. Print forward. 5. exit.\n");

        int ch;
        scanf("%d",&ch);
        if(ch==1)
        {
            char* value=new char[25];
            char* s=new char[25];
            printf("enter a value: ");
            scanf("\n%s", value);
            printf("enter a key: ");
            scanf("\n%s",s);
            l.insertFirst(s,value);
        }
        else if(ch==2)
        {
            char* value=new char[25];
            printf("enter a value: ");
            scanf("%s", value);
            int result = l.deleteItem(value);
            if(result==-1) printf("Not found.\n");
            else if(result==NULL_VALUE)
                printf("List is empty\n");
            else
                printf("Deleted: %s\n", value);
        }
        else if(ch==3)
        {
            char* s=new char[25];
            printf("enter a key: ");
            scanf("\n%s",s);
            char* res= l.searchItem(s);
            if(res!=0) printf("The value is : %s\n",res);
            else printf("Not found.\n");
        }
        else if(ch==4)
        {
            l.printListForward();
        }
        else if(ch==5)
        {
            break;
        }
    }

}
*/

