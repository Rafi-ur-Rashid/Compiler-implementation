#include <vector>
#include<cstring>
using namespace std;
class SymbolInfo
{
   private:

        char* Name;
        char* Type;
	char* IDType="dummy";
	char* VarType;
	int AraSize;
	char* FuncRet;
	int araIndex;
	bool FuncDefined = false;
    public:
	string code=" ";
	vector<char*> ParamList;
	int intValue;
	float floatValue;
	SymbolInfo(){};
	SymbolInfo(char* type){
		VarType = type;
   	 }
	SymbolInfo(const SymbolInfo *s){
		Name = s->Name;
		Type = s->Type;
		code = s->code;
	}

	SymbolInfo(char* n,char* t){Name=n;Type=t;};
        void setName(char* name){Name=name;};
        void setType(char* type){Type=type;};
	void setIDType(char* type){IDType = type;};
	void setVarType(char* type){VarType = type;};
	void setAraSize(int size){ AraSize = size;};
	void setFuncRet(char* type){FuncRet = type;};
	void setFuncDefined(){ FuncDefined = true;};
	void setAraIndex(int index){araIndex = index;}

	char* getName(){return Name;};
        char* getType(){ return Type;};
	char* getIDType(){return IDType;};
	char* getVarType(){return VarType;};
	int getAraSize(){return AraSize;};
	char* getFuncRet(){return FuncRet;};
	bool isFuncDefined(){return FuncDefined;};
	int getAraIndex(){return araIndex;};

};

