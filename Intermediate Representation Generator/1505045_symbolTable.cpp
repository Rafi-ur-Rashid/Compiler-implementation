#include "1505045_scopeTable.cpp"
#include <iostream>
#include <cstring>
#include <vector>
using namespace std;
class SymbolTable
{
    ScopeTable* currentScope;
    vector<ScopeTable*> table;
    int id=-1;
public:
    SymbolTable(){currentScope=0;}
    ScopeTable* getCurrentScope(){return currentScope;};
    void EnterScope();
    void ExitScope();
    int getID(){return id;};
    bool Insert(SymbolInfo info);
    bool Remove(char* name);
    listNode* Lookup(char* name,char* type);
    void printCurrentScope();
    void printCurrentScopeInFile(FILE* output);
    void printAllScope();
    void printAllScopeInFile(FILE* output);
    void printLast(FILE* output);
    void clear(){free(currentScope);};
};

void SymbolTable::EnterScope(){
    ScopeTable* scope=new ScopeTable();
    scope->setId(++id);
    scope->setParent(currentScope);
	//printf("Entered into ScopeTable with id %d\n",scope->getId());
    currentScope=scope;
}
void SymbolTable::ExitScope(){
    ScopeTable* temp=currentScope;
    table.push_back(currentScope);
    int tID=currentScope->getId();
    if(!currentScope->getParent()){
        printf("The primary scope can't be removed\n");
        return ;
    }
    currentScope=currentScope->getParent();
    id=tID;
    //printf(" ScopeTable with id %d removed\n",tID);
    free(temp);
}
bool SymbolTable::Insert(SymbolInfo info){
  
    return currentScope->insertItem(info);
}
bool SymbolTable::Remove(char* name){
    int off=0,pos=0;
    if(!currentScope->searchItem(name,off,pos)){
            printf("Not Found!\n");
            return false;
    }
    else{
        listNode* l=currentScope->searchItem(name,off,pos);
        printf("Found in ScopeTable# %d at position %d, %d\n",currentScope->getId(),pos,off);
        return currentScope->deleteItem(name);
    }
}
listNode* SymbolTable::Lookup(char* name,char* type)
{
    ScopeTable* temp=currentScope;
    int off=0,pos=0;
    while(temp)
    {
        if(!temp->searchItem2(name,off,pos,type) && temp->getParent()){
            //printf("I m here %p   %d ",temp->getParent(),temp->getId());
            temp=temp->getParent();
        }
        else{
            listNode* l=temp->searchItem2(name,off,pos,type);
            //printf("Found in ScopeTable# %d at position %d, %d\n",temp->getId(),pos,off);
            return l;
        }
    }
    //printf("Not Found!\n");
    return 0;
}
void SymbolTable::printCurrentScope()
{
    currentScope->printList();
}
void SymbolTable::printCurrentScopeInFile(FILE* output)
{
	//fprintf(output,"vavavva TOKEN <%s> Lexeme %s found\n",info.getType(),info.getName());
    fprintf(output,"\nScopeTable# id %d\n",currentScope->getId());
    currentScope->printListInFile(output);
    //fprintf(output,"\n*******************************\n");
}

void SymbolTable::printAllScope()
{
    ScopeTable* temp=currentScope;
    while(temp)
    {
        printf(" ScopeTable# id %d\n",temp->getId());
        temp->printList();
        temp=temp->getParent();
    }
}
void SymbolTable::printAllScopeInFile(FILE* output)
{
    ScopeTable* temp=currentScope;
    while(temp)
    {
        fprintf(output,"\nScopeTable# id %d\n",temp->getId());
        temp->printListInFile(output);
        temp=temp->getParent();
    }
	fprintf(output,"\n*******************************\n"); 
}
void SymbolTable::printLast(FILE* output)
{
	table[0]->printList();
;
}
/*
int main()
{
    SymbolTable h;
    h.EnterScope();
    while(1)
    {
        printf("*******************************************************************\n");
        printf(" 'S'-> Create new Scope.\n 'I'-> Insert item.\n 'L'-> Look up item.\n");
        printf(" 'D'->Delete item\n 'E'->Exit current scope\n 'PC'->Print current Scope\n");
        printf(" 'PA'->Print All Scope\n");
        printf("*******************************************************************\n");
        char* ch=new char[25];
        scanf("%s",ch);
        if(!strcmp(ch,"S"))
        {

            h.EnterScope();
            ScopeTable* curr=h.getCurrentScope();
            printf("New ScopeTable with id %d created\n",curr->getId());
        }
        else if(!strcmp(ch,"I"))
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
            h.Insert(info);
        }

        else if(!strcmp(ch,"L"))
        {
            char* s=new char[25];
            printf("enter a name: ");
            scanf("\n%s",s);
            h.Lookup(s);
        }
        else if(!strcmp(ch,"D")){
            char* k=new char[25];
            printf("enter a name: ");
            scanf("%s", k);
            h.Remove(k);
        }
        else if(!strcmp(ch,"E"))
        {
            h.ExitScope();
        }
         else if(!strcmp(ch,"PC"))
        {

            ScopeTable* curr=h.getCurrentScope();
            printf(" ScopeTable# id %d\n",curr->getId());
            h.printCurrentScope();
        }
         else if(!strcmp(ch,"PA"))
        {
            h.printAllScope();
        }
        else
        {
            h.clear();
            break;
        }

    }
}

*/

