%{
#include<iostream>
#include<cstdlib>
#include<cmath>
#include <vector>
#include <sstream>
#include "1505045_symbolTable.cpp"
using namespace std;
char* variable_type;
char* return_label;
int yyparse(void);
int yylex(void);
extern FILE* yyin;
extern FILE* logs;
extern FILE* outputs;
FILE* codeOuts;
SymbolTable h;
int IDargs = 0;
extern int errCount;
vector<char*> args; 
vector<string> variables;
vector<string> arrays;
vector<int> arraySizes;
bool funcDef = false;
extern int line_count;
int semErrors=0;
int labelCount=0;
int tempCount=0;
int pTempCount = 0;
int maxTemp = 0;
vector<SymbolInfo> paramList; 
char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%d", tempCount);
	tempCount++;
	strcat(t,b);
	return t;
}
char *newTemp2()
{
	char *pt= new char[4];
	strcpy(pt,"p");
	char b[3];
	sprintf(b,"%d", pTempCount);
	pTempCount++;
	strcat(pt,b);
	return pt;
}

void yyerror(const char *s)
{
	fprintf(logs,"line# %d: %s\n",line_count,s);
	return;
}

%}
%define api.value.type {SymbolInfo*}
%error-verbose
%token COMMENT IF ELSE FOR WHILE DO BREAK CONTINUE INT FLOAT CHAR DOUBLE VOID RETURN SWITCH CASE DEFAULT INCOP DECOP ADDOP MULOP RELOP ASSIGNOP LOGICOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD SEMICOLON COMMA STRING NOT PRINTLN MAIN ID CONST_INT CONST_FLOAT CONST_CHAR BITOP
%nonassoc dummy_prec
%nonassoc ELSE
%%

start : program
		{
			
			fprintf(outputs,"line: %d  start -> program\n",line_count);
			if(!errCount && !semErrors){
			//$1->code+="\n\nDECIMAL_OUT PROC NEAR\n\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tor ax,ax\n \tjge enddif\n\tpush ax\n\tmov dl,'-'\n\tmov ah,2\n\tint 21h\n\tpop ax\n\tneg ax\nenddif:\n\txor cx,cx\n\tmov bx,10d\nrepeat:\n\txor dx,dx\n\tdiv bx\n\t push dx\n\tinc cx\n\tor ax,ax\n\tjne repeat\n\tmov ah,2\nprint_loop:\n\tpop dx\n\tor dl,30h\n\tint 21h\n\tloop print_loop\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\nDECIMAL_OUT ENDP\n";
			codeOuts= fopen("code.txt","w");
			fprintf(codeOuts,".model small\n.stack 100h\n\n.data\n") ;
			for(int i = 0; i<variables.size() ; i++){
				fprintf(codeOuts,"%s dw\n", variables[i]);	
			}

			for(int i = 0 ; i< arrays.size() ; i++){
				fprintf(codeOuts,"%s dw %d dup(?)\n",arrays[i],arraySizes[i]);
			}

			fprintf(codeOuts,"\n.code \n"); 
			fprintf(codeOuts,"%s",$1->code.c_str());
		}

			
			
		}
	;

program : program unit
		{
			fprintf(outputs,"line: %d program -> program unit\n",line_count);
cout<<"hi Pro unit\n";
			$$ = $1;
			$$->code += $2->code;
		} 
	| unit
		{
			
			fprintf(outputs,"line: %d program -> unit\n",line_count);
			$$ = $1;
		} 
	;
	
unit : var_declaration
		{
			fprintf(outputs,"line: %d unit -> var_declaration\n",line_count);
			$$ = $1;
		}
     | func_declaration
	{
		fprintf(outputs,"line: %d unit -> func_declaration\n",line_count);
		$$ = $1;
	}
     | func_definition
	{	cout<<"hi funcDef\n";
		fprintf(outputs,"line: %d unit -> func_definition\n",line_count);
		$$ = $1;	
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
		{
						
			fprintf(outputs,"line: %d func_declaration -> type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n",line_count);
			listNode *temp = h.Lookup($2->getName(), "FUNC");
			if(temp){
				fprintf(logs,"Error:Line %d Function %s already declared",line_count,$2->getName());
				semErrors++;
			}else {
				SymbolInfo* temp2 = new SymbolInfo($2->getName(), "ID");
				temp2->setIDType("FUNC");
				temp2->setFuncRet($1->getVarType());
				for(int i = 0; i<args.size(); i++){
					temp2->ParamList.push_back(args[i]);					
				}
				args.clear();
				h.Insert(*temp2);
			}
			
		}
		
		| type_specifier ID LPAREN RPAREN SEMICOLON 
			{
				
			fprintf(outputs,"line: %d func_declaration->type_specifier ID LPAREN RPAREN SEMICOLON \n",line_count);
			listNode *temp = h.Lookup($2->getName(), "FUNC");
			
			if(temp){
				fprintf(logs,"Error:Line %d: Function %s already declared",line_count,$2->getName());
				semErrors++;
			}else {
				SymbolInfo* temp2 = new SymbolInfo($2->getName(), "ID");
				temp2->setIDType("FUNC");
				temp2->setFuncRet($1->getVarType());
				args.clear();
				h.Insert(*temp2);
			}
		}
		;
		 
func_definition :	type_specifier ID LPAREN parameter_list RPAREN
		 	{
				fprintf(outputs,"line: %d func_definition->type_specifier ID LPAREN parameter_list RPAREN compound_statement \n",line_count);
				
				listNode *temp = h.Lookup($2->getName(), "FUNC");
				if(args.size() != IDargs){
					fprintf(logs,"Error:Line %d: Parameter mismatch for Function %s\n", line_count,$2->getName());
					args.clear(); 
					IDargs = 0;
					semErrors++;
				}												
				if(temp){
					if(temp->item.isFuncDefined()== true){
					fprintf(logs,"Error:Line %d: %s function already defined\n", line_count,$2->getName());
						semErrors++;
						args.clear();
						IDargs = 0;
					}
					else if(strcmp(temp->item.getFuncRet(),$1->getVarType())){
						fprintf(logs,"Error:Line %d: function %s return type doesn't match that of declaration\n", line_count,$2->getName());
						semErrors++;
						args.clear();
						IDargs = 0; 
					} 
					else if(temp->item.ParamList.size() != args.size()){
						fprintf(logs,"Error:Line %d: function %s parameter list doesn't match that of declaration\n", line_count,$2->getName());
						args.clear();
						IDargs = 0;
						semErrors++;					
					}
					else{
						for(int i = 0; i<temp->item.ParamList.size(); i++){
							if(temp->item.ParamList[i] != args[i]){
								fprintf(logs,"Error:Line %d: function %s has argument mismatch\n", line_count,$2->getName());
								args.clear();
								IDargs = 0;
								semErrors++;	
							}
						}				
					}
				}
				else{
					SymbolInfo* temp = new SymbolInfo($2->getName(), "ID");
					temp->setIDType("FUNC");
					temp->setFuncRet($1->getVarType());
					
					for(int i = 0; i<args.size(); i++){
						temp->ParamList.push_back(args[i]);					
					}
					temp->setFuncDefined();
					h.Insert(*temp);
				}
			} compound_statement{
				SymbolInfo * func = new SymbolInfo();				
				$$ = func;
				$$->code += string($2->getName()) + " PROC NEAR\n\n";
				$$->code += $7->code;
				$$->code+=string(return_label)+":\n";
				if(args.size()!=0){
					$$->code+="  pop bp\n";
				}
				$$->code+="  ret ";
				int p=args.size()*2;
				if(p){
					string Result;       

					ostringstream convert;  
	
					convert << p;    

					Result = convert.str(); 
					$$->code+=Result+"\n";
				}
				$$->code+="\n";
				$$->code += "\n" + string($2->getName()) + " ENDP\n\n";
				args.clear();
				IDargs = 0;
				return_label = "";
			}
			
		| type_specifier ID LPAREN RPAREN
			{				
				fprintf(outputs,"line: %d func_definition->type_specifier ID LPAREN RPAREN compound_statement \n",line_count);
				listNode *temp = h.Lookup($2->getName(), "FUNC");
				if(temp){
					if(temp->item.isFuncDefined()== true){
					fprintf(logs,"Error:Line %d: %s function already defined\n", line_count,$2->getName());
						semErrors++;
						args.clear();
						IDargs = 0;
					}
					else if(strcmp(temp->item.getFuncRet(),$1->getVarType())){
						fprintf(logs,"Error:Line %d: function %s return type doesn't match that of declaration\n", line_count,$2->getName());
						semErrors++;
						args.clear();
						IDargs = 0; 
					} 
					else if(temp->item.ParamList.size() != args.size()){
						fprintf(logs,"Error:Line %d: function %s parameter list doesn't match that of declaration\n", line_count,$2->getName());
						args.clear();
						IDargs = 0;
						semErrors++;					
					}
				}
				else{
					SymbolInfo* temp = new SymbolInfo($2->getName(), "ID");
					temp->setIDType("FUNC");
					temp->setFuncRet($1->getVarType());
					temp->setFuncDefined();
					h.Insert(*temp);
				}
			} compound_statement{
				SymbolInfo * func = new SymbolInfo();				
				$$ = func;
				$$->code += string($2->getName()) + " PROC NEAR\n\n";
				$$->code += $6->code;
				$$->code+=string(return_label)+":\n";
				if(args.size()!=0){
					$$->code+="  pop bp\n";
				}
				$$->code+="  ret ";
				int p=args.size()*2;
				if(p){
					string Result;       

					ostringstream convert;  
	
					convert << p;    

					Result = convert.str(); 
					$$->code+=Result+"\n";
				}
				$$->code+="\n";
				$$->code += "\n" + string($2->getName()) + " ENDP\n\n";
				args.clear();
				IDargs = 0;
				return_label = "";
	
			}
		| type_specifier MAIN LPAREN RPAREN
			{
				
				fprintf(outputs,"line: %d func_definition->type_specifier MAIN LPAREN RPAREN compound_statement\n",line_count);
			}compound_statement{
				SymbolInfo * func = new SymbolInfo();				
				$$ = func;
				$$->code +="main PROC\n\n";
				cout<<"hi main"<<$6->getName()<<"bb"<<endl;
				$$->code += $6->code;
				cout<<"hi main"<<$6->code<<endl;
				$$->code+="\n";
				$$->code+="\tmov ah,4ch\n\tint 21h\n";
				$$->code+= "\nmain ENDP\n\n";
				args.clear();
				IDargs = 0;
				return_label = "";
	
			}
 		;				

parameter_list  : parameter_list COMMA type_specifier ID
			{
				fprintf(outputs,"line: %d parameter_list  -> parameter_list COMMA type_specifier ID  \n",line_count);
				//insertIntoST($4->getName(),$4->getType());
				args.push_back(variable_type);
				IDargs++;
				$4->setIDType("VAR");
				$4->setVarType(variable_type);//changed from $3->getVarType()
				SymbolInfo* temp = new SymbolInfo($4->getName(), $4->getType());
				temp->setIDType("VAR");
				paramList.push_back(*temp);
				
			}
		| parameter_list COMMA type_specifier
			{
				fprintf(outputs,"line: %d parameter_list  -> parameter_list COMMA type_specifier\n",line_count);
				args.push_back($3->getVarType());			
			}
 		| type_specifier ID
			{
				fprintf(outputs,"line: %d parameter_list -> type_specifier ID\n",line_count);
				args.push_back(variable_type);
				//insertIntoST($2->getName(),$2->getType());
				IDargs++;
				$2->setIDType("VAR");
				$2->setVarType(variable_type);//$1->getVarType()
				paramList.push_back(*$2);
			}
		| type_specifier
			{
				fprintf(outputs,"line: %d parameter_list  ->type_specifier\n",line_count);
				args.push_back(variable_type);
			}
 		;

 		
compound_statement : LCURL{
				h.EnterScope(); 
				for(int i = 0; i<paramList.size();i++) 
					h.Insert(paramList[i]);
				paramList.clear();
				
			  } 
		     statements RCURL{  h.ExitScope();
					$$=$3;
					cout<<"hi compStmt1"<<$$->getName()<<"bb"<<endl;;
					fprintf(outputs,"line: %d compound_statement -> LCURL statements RCURL\n",line_count);
			}
 		    | LCURL RCURL
			{
				$$=new SymbolInfo("compound_statement"," ");
				fprintf(outputs,"line: %d compound_statement -> LCURL RCURL\n",line_count);
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			$$=new SymbolInfo();
			fprintf(outputs,"line: %d var_declaration ->type_specifier declaration_list SEMICOLON\n",line_count);
			cout<<"hi varDec\n";	
		}
 		 ;
 		 
type_specifier	: INT
		{	
			fprintf(outputs,"line: %d type_specifier	: INT\n",line_count);	
			SymbolInfo* s= new SymbolInfo("INT");
			variable_type = "INT";
			$$ = s;
		}
 		| FLOAT
		{
			fprintf(outputs,"line: %d type_specifier	: FLOAT\n",line_count);
			SymbolInfo* s= new SymbolInfo("FLOAT");
			variable_type = "FLOAT";
			$$ = s;
	
		}
 		| VOID
		{
			fprintf(outputs,"line: %d type_specifier	: VOID\n",line_count);	
			SymbolInfo* s= new SymbolInfo("VOID");
			variable_type = "VOID";
			$$ = s;

		}
 		;
 		
declaration_list : declaration_list COMMA ID
			{
				cout<<"DecList\n";
				fprintf(outputs,"line: %d declaration_list -> declaration_list COMMA ID\n",line_count);		
				//insertIntoST($3->getName(),$3->getType());
				if(!strcmp(variable_type, "VOID")){
							fprintf(logs,"Error :variable type can't be void\n",line_count);
							semErrors++;
						}
						else{	
							
							listNode* temp = h.Lookup($3->getName(), "VAR");
							if(temp){
							fprintf(logs,"Error:Line %d:Variable %s already declared in the scope\n",line_count, $3->getName());	
								semErrors++;	
							}
							else{
								
								SymbolInfo* temp2 = new SymbolInfo($3->getName(), $3->getType());
								temp2->setVarType(variable_type);
								temp2->setIDType("VAR");
								h.Insert(*temp2);
								
							}
						}

			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
			{
				fprintf(outputs,"line: %d declaration_list -> declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n",line_count);
				
				if(!strcmp(variable_type, "VOID")){
					fprintf(logs,"Error:Line %d :array type can't be void\n",line_count);
					semErrors++;
				}
				else{
					listNode* temp = h.Lookup($3->getName(), "ARAY");
					if(temp){
					fprintf(logs,"Error:Line %d :Array %s already declared\n", line_count, $3->getName());
						semErrors++;			
					}
					else{
						SymbolInfo* temp2 = new SymbolInfo($3->getName(), $3->getType());
						temp2->setVarType(variable_type);
						temp2->setIDType("ARAY");
						int araSize = atoi($5->getName());
						temp2->setAraSize(araSize);
						h.Insert(*temp2);						
						h.printAllScopeInFile(logs);
					}
				}

			}
 		  | ID
			{
				
				fprintf(outputs,"line: %d declaration_list -> ID\n",line_count);
				if(!strcmp(variable_type, "VOID")){
					fprintf(logs,"Error:Line %d :variable type can't be void\n",line_count);
					semErrors++;
				}
				else{
					
					listNode* temp = h.Lookup($1->getName(), "VAR");
					if(temp){
						fprintf(logs,"Error:Line %d :variable %s already declared\n",line_count, $1->getName());	
						semErrors++;		
					}
					else{
						cout<<"hi id1"<<variable_type<<endl;
						SymbolInfo* temp2 = new SymbolInfo($1->getName(), $1->getType());
						temp2->setVarType(variable_type);
						temp2->setIDType("VAR");
						h.Insert(*temp2);		
						
					}
				}
				

			}
 		  | ID LTHIRD CONST_INT RTHIRD
			{
				fprintf(outputs,"line: %d declaration_list -> ID LTHIRD CONST_INT RTHIRD\n",line_count);
				//insertIntoST($1->getName(),$1->getType());
				if(!strcmp(variable_type, "VOID")){
					fprintf(logs,"Error:Line %d :array type can't be void\n",line_count);
					semErrors++;
				}
				else{
					listNode* temp = h.Lookup($3->getName(), "ARAY");
					if(temp){
					fprintf(logs,"Error:Line %d :Array %s already declared\n", line_count, $3->getName());
						semErrors++;
					}
					else{
						SymbolInfo* temp2 = new SymbolInfo($1->getName(), $1->getType());
						temp2->setVarType(variable_type);
						temp2->setIDType("ARAY");
						int araSize = atoi($3->getName());
						temp2->setAraSize(araSize);
						h.Insert(*temp2);						
						h.printAllScopeInFile(logs);			
					}
				}

	}
 		  ;
 		  
statements : statement
		{
				
			fprintf(outputs,"line: %d statements -> statement\n",line_count);
			$$=$1;
			cout<<"statements\n";
		}
	   | statements statement
		{
			fprintf(outputs,"line: %d statements -> statements statement\n",line_count);
			$$=$1;
			$$->code += $2->code;
			delete $2;		
		}
	   ;
	   
statement : COMMENT
		{
			fprintf(outputs,"line: %d statement -> comment\n",line_count);
		}
	  
	  |var_declaration
		{
			cout<<"statement\n";
			fprintf(outputs,"line: %d statement -> var_declaration\n",line_count);
			$$=new SymbolInfo("statement"," ");
		}
	  | expression_statement
		{
				
			fprintf(outputs,"line: %d statement -> expression_statement\n",line_count);
				$$=$1;		
		}
	  | compound_statement
		{
			fprintf(outputs,"line: %d statement -> compound_statement\n",line_count);
				$$=$1;		
		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{
			fprintf(outputs,"line: %d statement ->  FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",line_count);
			$$ = $3;
			char *label1 = newLabel();
			char *label2 = newLabel();
			$$->code += string(label1) + ":\n";
			$$->code+=$4->code;
			$$->code+="  mov ax , "+string($4->getName())+"\n";
			$$->code+="  cmp ax , 0\n";
			$$->code+="  je "+string(label2)+"\n";
			$$->code+=$7->code;
			$$->code+=$5->code;
			$$->code+="  jmp "+string(label1)+"\n";
			$$->code+=string(label2)+":\n";
		
		}
	  | IF LPAREN expression RPAREN statement %prec dummy_prec 
		{
			fprintf(outputs,"line: %d statement -> IF LPAREN expression RPAREN statement\n",line_count);
			$$=$3;	
			char *label=newLabel();
			$$->code+="  mov ax, "+string($3->getName())+"\n";
			$$->code+="  cmp ax, 0\n";
			$$->code+="  je "+string(label)+"\n";
			$$->code+=$5->code;
			$$->code+=string(label)+":\n";
					
		}
	  | IF LPAREN expression RPAREN statement ELSE statement
		{
			fprintf(outputs,"line: %d statement -> IF LPAREN expression RPAREN statement ELSE statement\n",line_count);
			$$=$3;
			//similar to if part
			char *elselabel=newLabel();
			char *exitlabel=newLabel();
			$$->code+="  mov ax,"+string($3->getName())+"\n";
			$$->code+="  cmp ax,0\n";
			$$->code+="  je "+string(elselabel)+"\n";
			$$->code+=$5->code;
			$$->code+="  jmp "+string(exitlabel)+"\n";
			$$->code+=string(elselabel)+":\n";
			$$->code+=$7->code;
			$$->code+=string(exitlabel)+":\n";
			
		}
	  | WHILE LPAREN expression RPAREN statement
		{
			fprintf(outputs,"line: %d statement -> WHILE LPAREN expression RPAREN statement\n",line_count);
			$$ = new SymbolInfo();
			char * label = newLabel();
			char * exit = newLabel();
			$$->code = string(label) + ":\n"; 
			$$->code+=$3->code;
			$$->code+="  mov ax , "+string($3->getName())+"\n";
			$$->code+="  cmp ax , 0\n";
			$$->code+="  je "+string(exit)+"\n";
			$$->code+=$5->code;
			$$->code+="  jmp "+string(label)+"\n";
			$$->code+=string(exit)+":\n";
			
		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
			fprintf(outputs,"line: %d statement -> PRINTLN LPAREN ID RPAREN SEMICOLON\n",line_count);
			$$->code += "  mov ax, " + string($3->getName()) +"\n";
			$$->code += "  call DECIMAL_OUT\n";
		}
	  | RETURN expression SEMICOLON
		{
			fprintf(outputs,"line: %d statement -> RETURN expression SEMICOLON\n",line_count);	
			$$=$2;
			$$->code+="  mov dx,"+string($2->getName())+"\n";
			$$->code+="  jmp   "+string(return_label)+"\n";
		}
	  ;
	  
expression_statement 	: SEMICOLON	
				{
					fprintf(outputs,"line: %d expression_statement 	-> SEMICOLON	\n",line_count);
					$$=new SymbolInfo(";","SEMICOLON");
					$$->code="";
					tempCount = 0;
				}		
			| expression SEMICOLON
				{
				
					fprintf(outputs,"line: %d expression_statement 	->expression SEMICOLON	\n",line_count);
					$$=$1;
					tempCount = 0;
				} 
			;
	  
variable : ID 	
		{				
				fprintf(outputs,"line: %d variable -> ID\n",line_count);
				listNode* temp = h.Lookup($1->getName(),"VAR");				
				if(!temp){				
					fprintf(logs,"Error:Line %d:Type Mismatch occured or %s is not declared\n",line_count,$1->getName());				
					semErrors++;
				}
				else{
					$$= new SymbolInfo($1);
					$$->code="";
					string str=string(string($$->getName())+to_string(h.getID()));
					std::vector<char> writable(str.begin(), str.end());
					writable.push_back('\0');
					$$->setName(&writable[0]);
					variables.push_back(string($$->getName())+to_string(h.getID()));
					$$->setType("notarray");
				}
		}	
	 | ID LTHIRD expression RTHIRD 
		{
			fprintf(outputs,"line: %d variable -> ID LTHIRD expression RTHIRD\n",line_count);
			listNode* t = h.Lookup($1->getName(),"ARAY");
			if(!t){
			fprintf(logs,"Error:Line %d:Type mismatch occured or %s is not declared\n",line_count,$2->getName());									
				semErrors++;				
			}
			else{
				static SymbolInfo temp=t->item;				
				if(!strcmp($3->getVarType(),"FLOAT")){
					fprintf(logs,"Error:Line %d:array index can't be float\n",line_count);		semErrors++;
				}
				if($3->intValue >= temp.getAraSize()){
					fprintf(logs,"Error:Line %d:array index out of bounds\n",line_count);				
					semErrors++;
					
				} 
				else 
				{
					$$= new SymbolInfo($1);
					$$->setType("ARAY");
					string str=string($$->getName())+to_string(h.getID());
					std::vector<char> writable(str.begin(), str.end());
					writable.push_back('\0');
					$$->setName(&writable[0]);
					arrays.push_back(string($$->getName())+to_string(h.getID()));
					arraySizes.push_back($1->getAraSize());
					$$->code=$3->code ;
					$$->code += "  mov bx, " +string($3->getName()) +"\n";
					$$->code += "  add bx, bx\n";
					delete $3;
					$$->setAraIndex($3->intValue);
				}
			}			
		
		}
	 ;
	 
expression : logic_expression	
		{
			fprintf(outputs,"line: %d expression -> logic_expression\n",line_count);
			$$ = $1; 
		}
	   | variable ASSIGNOP logic_expression
		{
			fprintf(outputs,"line: %d expression -> variable ASSIGNOP logic_expression\n",line_count);
			
			
			if(!strcmp($1->getIDType(),"dummy"))					printf("");
			if(strcmp($3->getVarType(), "INT"))			
				fprintf(logs,"Warning :line %d: converting float value to integer\n",line_count);		
			$$->code=$3->code+$1->code;
			$$->code+="  mov ax, "+string($3->getName())+"\n";
			if(!strcmp($$->getType(),"notarray")){ 
				$$->code+= "  mov "+string($1->getName())+", ax\n";
	
			$$ = $1;				
			}
		} 	
	   		;	
			
logic_expression 	: rel_expression
					{
						fprintf(outputs,"line: %d logic_expression -> rel_expression\n",line_count);
						$$ = $1; 
						
					} 	
		 			| rel_expression LOGICOP rel_expression
					{
						fprintf(outputs,"line: %d  : logic_expression -> rel_expression LOGICOP rel_expression\n",line_count);
						SymbolInfo* temp = new SymbolInfo("INT");
						$$ = temp;	
						$$->code+=$3->code;
					char * label1 = newLabel();
					char * label2 = newLabel();
					char * t = newTemp2();
					if(!strcmp($2->getName(),"&&")){
						$$->code += "  mov ax , " + string($1->getName()) +"\n";
						$$->code += "  cmp ax , 0\n";
				 		$$->code += "  je " + string(label1) +"\n";
						$$->code += "  mov ax , " + string($3->getName()) +"\n";
						$$->code += "  cmp ax , 0\n";
						$$->code += "  je " + string(label1) +"\n";
						$$->code += "  mov " + string(t) + " , 1\n";
						$$->code += "  jmp " + string(label2) + "\n";
						$$->code += string(label1) + ":\n" ;
						$$->code += "  mov " + string(t) + ", 0\n";
						$$->code += string(label2) + ":\n";
						$$->setName(t);
						
					}
					else if(!strcmp($2->getName(),"||")){
						$$->code += "  mov ax , " + string($1->getName()) +"\n";
						$$->code += "  cmp ax , 0\n";
				 		$$->code += "  jne " + string(label1) +"\n";
						$$->code += "  mov ax , " + string($3->getName()) +"\n";
						$$->code += "  cmp ax , 0\n";
						$$->code += "  jne " + string(label1) +"\n";
						$$->code += "  mov " + string(t) + " , 0\n";
						$$->code += "  jmp " + string(label2) + "\n";
						$$->code += string(label1) + ":\n" ;
						$$->code += "  mov " + string(t) + ", 1\n";
						$$->code += string(label2) + ":\n";
						$$->setName(t);
						
					}
					delete $3;

		}	
	   ;
			
			
rel_expression	: simple_expression 
			{
				fprintf(outputs,"line: %d rel_expression	-> simple_expression  \n",line_count);
				$$ = $1;
			}
		| simple_expression RELOP simple_expression	
			{
				fprintf(outputs,"line: %d rel_expression->simple_expression RELOP simple_expression  \n",line_count);
				SymbolInfo* temp = new SymbolInfo("INT");
				$$ = temp;	
				$$->code+=$3->code;
				$$->code+="  mov ax, " + string($1->getName())+"\n";
				$$->code+="  cmp ax, " + string($3->getName())+"\n";
				char *t=newTemp2();
				char *label1=newLabel();
				char *label2=newLabel();
				if(!strcmp($2->getName(),"<")){
					$$->code+="  jl " + string(label1)+"\n";
				}
				else if(!strcmp($2->getName(),"<=")){
					$$->code+="  jle " + string(label1)+"\n";
				}
				else if(!strcmp($2->getName(),">")){
					$$->code+="  jg " + string(label1)+"\n";
				}
				else if(!strcmp($2->getName(),">=")){
					$$->code+="  jge " + string(label1)+"\n";
				}
				else if(!strcmp($2->getName(),"==")){
					$$->code+="  je " + string(label1)+"\n";
				}
				else if(!strcmp($2->getName(),"!=")){
					$$->code+="  jne " + string(label1)+"\n";
				}
				
				$$->code+="  mov "+string(t) +", 0\n";
				$$->code+="  jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\n";
				$$->code+= "  mov "+string(t)+", 1\n";
				$$->code+=string(label2)+":\n";
				$$->setName(t);
				delete $3;
			}
		;
				
simple_expression : term 
			{
				fprintf(outputs,"line: %d simple_expression -> term   \n",line_count);
				$$ = $1;

			}
		  | simple_expression ADDOP term 
			{
				fprintf(outputs,"line: %d simple_expression -> simple_expression ADDOP term  \n",line_count);
				char* addop = $2->getName();
					
				if(!strcmp($1->getVarType(), "FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					$$ = temp;
				}
				else if(!strcmp($3->getVarType(), "FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					$$ = temp;
				}
				else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(), "INT")){
					SymbolInfo* temp = new SymbolInfo("INT");
					$$ = temp;
				}
				$$->code+=$3->code;
				if(!strcmp($2->getName(),"+")){
					char* temp = newTemp();
					$$->code += "  mov ax, " + string($1->getName()) + "\n";
					$$->code += "  add ax, " + string($3->getName()) + "\n";
					$$->code += "  mov " + string(temp) +" , ax\n";
					$$->setName(temp);
				}
				else if(!strcmp($2->getName(),"+")){
					char* temp = newTemp();
					$$->code += "  mov ax, " + string($1->getName()) + "\n";
					$$->code += "  sub ax, " + string($3->getName()) + "\n";
					$$->code += "  mov " + string(temp) +" , ax\n";
					$$->setName(temp);
				}
				delete $3;
				cout << endl;


			}
		  ;
					
term :	unary_expression
		{
				fprintf(outputs,"line: %d term :unary_expression \n",line_count);
				$$ = $1;
				
		}
     |  term MULOP unary_expression
		{
				
			fprintf(outputs,"line: %d  term MULOP unary_expression \n",line_count);
			char* mulop = $2->getName();
			$$=$1;
			$$->code += $3->code;
			$$->code += "  mov ax, "+ string($1->getName())+"\n";
			$$->code += "  mov bx, "+ string($3->getName()) +"\n";
			char *t=newTemp();
			if(!strcmp(mulop, "*"))
			{
				 if(!strcmp($1->getVarType(), "FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					$$ = temp;

				}
				else if(!strcmp($3->getVarType(), "FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					$$ = temp;
				}
				else if(!strcmp($3->getVarType(),"INT") && !strcmp($1->getVarType(),"INT")){
					SymbolInfo* temp = new SymbolInfo("INT");
					$$ = temp;
				} 
				$$->code += "  mul bx\n";
				$$->code += "  mov "+ string(t) + ", ax\n";
				
			}
			else if(!strcmp(mulop, "/"))
			{
				if(!strcmp($1->getVarType(), "FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					if($3->intValue== 0)
					{
						fprintf(logs,"Error:Line %d :Divide by zero\n",line_count);							
						semErrors++; 
					}							
					$$ = temp;
				}
				
				else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType() , "INT")){
					SymbolInfo* temp = new SymbolInfo("INT");
					if($3->intValue== 0)
					{
						fprintf(logs,"Error:Line %d :Divide by zero\n",line_count);							
						semErrors++; 
					}	
					$$ = temp;
				}
				$$->code += "  xor dx , dx\n";
				$$->code += "  div bx\n";
				$$->code += "  mov " + string(t) + " , ax\n";

			}
			else if(!strcmp(mulop, "%")){
				SymbolInfo* temp = new SymbolInfo("INT");
				if(!strcmp($1->getVarType() ,"FLOAT") || !strcmp($3->getVarType(), "FLOAT")){
					fprintf(logs,"Error: line:%d  Unsuported operand for mod operator\n",line_count);
					semErrors++;
				}
				else
					$$ = temp;
				$$->code += "  xor dx , dx\n";
				$$->code += "  div bx\n";
				$$->code += "  mov " + string(t) + " , dx\n";
				
			}
			$$->setName(t);
			cout << endl << $$->code << endl;
			delete $3;
				
		}
     ;

unary_expression : ADDOP unary_expression  
			{
				fprintf(outputs,"line: %d  unary_expression -> ADDOP unary_expression  \n",line_count);
				$$ = $2;
				if(!strcmp($1->getName(), "-"))
				{
					$$->code += "  mov ax, " + string($2->getName()) + "\n";
					$$->code += "  neg ax\n";
					$$->code += "  mov " + string($2->getName()) + " , ax\n";
				}
	
				
			}
		 | NOT unary_expression 
			{			
				fprintf(outputs,"line: %d  unary_expression -> NOT unary_expression  \n",line_count);
				SymbolInfo* temp = new SymbolInfo("INT");
				temp->setIDType("VAR");
				$$=temp;
				char *t=newTemp();
				$$->code="  mov ax, " + string($2->getName()) + "\n";
				$$->code+="  not ax\n";
				$$->code+="  mov "+string(t)+", ax";

			}
		 | factor   
			{
				fprintf(outputs,"line: %d  unary_expression -> factor \n",line_count);
				$$ = $1;
				
				
			}
		 ;
	
factor	: variable 
		{
			fprintf(outputs,"line: %d  factor-> variable  \n",line_count);
			if($$->getType()=="notarray"){
				
			}
			
			else{
				char *temp= newTemp();
				$$->code+="\tmov ax, " + string($1->getName()) + "[bx]\n";
				$$->code+= "\tmov " + string(temp) + ", ax\n";
				$$->setName(temp);
			}
		}
	| ID LPAREN argument_list RPAREN
		{
				
			fprintf(outputs,"line: %d  factor-> ID LPAREN argument_list RPAREN  \n",line_count);
			listNode *temp=h.Lookup($1->getName(),"FUNC");
			if(!temp)
				fprintf(logs,"Error:Line %d :function %s doesn't exist",line_count,$1->getName());
			else{
			  if(!strcmp(temp->item.getFuncRet() ,"VOID")){
			 	fprintf(logs,"Error:Line %d :function %s returns VOID",line_count,$1->getName());
			  } 
			  else{
				SymbolInfo *temp2 = new SymbolInfo(temp->item.getFuncRet());					
				$$ = temp2;
			  }
			}

					
		}
	| LPAREN expression RPAREN
		{
				fprintf(outputs,"line: %d  factor-> LPAREN expression RPAREN  \n",line_count);
				$$ = $2;
		}
	| CONST_INT 
		{
				fprintf(outputs,"line: %d  factor-> CONST_INT  \n",line_count);
				$1->setVarType("INT");			
				$1->intValue= atoi($1->getName());
				$1->setIDType("VAR");
				$$ = $1;	
		}
	| CONST_FLOAT
		{
				fprintf(outputs,"line: %d  factor-> CONST_FLOAT  \n",line_count);
				$1->setVarType("FLOAT");
				$1->floatValue= atof($1->getName());
				$1->setIDType("VAR");
				$$ = $1;

		}
	| variable INCOP 
		{
				fprintf(outputs,"line: %d  factor-> variable INCOP \n",line_count);
				$$ = $1;
				$$->code += "  mov ax , " +string($$->getName())+ "\n";
				$$->code += "  add ax , 1\n";
				$$->code += "  mov " +string($$->getName())+ " , ax\n";
		}
	| variable DECOP
		{
				fprintf(outputs,"line: %d  factor-> variable DECOP \n",line_count);	
				$$ = $1;
				$$->code += "  mov ax , " + string($$->getName())+ "\n";
				$$->code += "  sub ax , 1\n";
				$$->code += "  mov " + string($$->getName()) + " , ax\n";

		}
	;
	
argument_list : arguments
		{
				fprintf(outputs,"line: %d  argument_list : arguments \n",line_count);
		}
			  |
			  ;
	
arguments : arguments COMMA logic_expression
		{
				fprintf(outputs,"line: %d  arguments : arguments COMMA logic_expression\n",line_count);
		}
	      | logic_expression
		{
				fprintf(outputs,"line: %d  arguments : logic_expression\n",line_count);
		}
	      ;
 

%%
int main(int argc,char *argv[])
{
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	logs= fopen("logs.txt","w");
	outputs= fopen("parser.txt","w");
	yyin= fin;
	h.EnterScope();
	yyparse();
	fprintf(logs,"End of Parsing \n");
	h.printAllScopeInFile(logs);
	fprintf(logs,"Total Lines: %d\n",line_count-1);
	fprintf(logs,"Total Errors: %d\n",semErrors+errCount);
	fclose(yyin);
	fclose(logs);
	fclose(outputs);
	fclose(codeOuts);
	return 0;
}

