%{
#include<iostream>
#include<cstdlib>
#include<cmath>
#include <vector>
#include <limits>
#include "1505045_symbolTable.cpp"
using namespace std;
char* variable_type;
int yyparse(void);
int yylex(void);
extern FILE* yyin;
extern FILE* logs;
extern FILE* outputs;
SymbolTable h;
int IDargs = 0;
extern int errCount;
vector<char*> args; 
bool funcDef = false;
extern int line_count;
int semErrors=0;
vector<SymbolInfo> paramList; 
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
			cout<<"hi start\n"<<endl;
			fprintf(outputs," start -> program\n",line_count);
		}
	;

program : program unit
		{
			fprintf(outputs,"program -> program unit\n",line_count);
		} 
	| unit
		{
			cout<<"hi unit\n"<<endl;
			fprintf(outputs,"program -> unit\n",line_count);
		} 
	;
	
unit : var_declaration
		{
			cout<<"hi var dec"<< endl;
			fprintf(outputs,"unit -> var_declaration\n",line_count);
		}
     | func_declaration
	{
			fprintf(outputs,"unit -> func_declaration\n",line_count);
	}
     | func_definition
	{
			fprintf(outputs,"unit -> func_definition\n",line_count);
	}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON 
		{
						
			fprintf(outputs,"func_declaration -> type_specifier ID LPAREN parameter_list RPAREN SEMICOLON     %s function decl.\n",line_count,$2->getName());
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
				printf("hi func decl\n");
			fprintf(outputs,"func_declaration->type_specifier ID LPAREN RPAREN SEMICOLON    %s function decl.\n",$2->getName());
			listNode *temp = h.Lookup($2->getName(), "FUNC");
			printf("hi2 func decl\n");
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
		 
func_definition :	type_specifier ID LPAREN parameter_list RPAREN compound_statement
		 	{
				fprintf(outputs,"func_definition->type_specifier ID LPAREN parameter_list RPAREN compound_statement    %s function defn.\n",$2->getName());
				
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
				args.clear();
				IDargs = 0;
				
	

				
			}
		| type_specifier ID LPAREN RPAREN compound_statement
			{				
				fprintf(outputs,"func_definition->type_specifier ID LPAREN RPAREN compound_statement    %s function defn.\n",$2->getName() );
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
				args.clear();
				IDargs = 0;
			}
		| type_specifier MAIN LPAREN RPAREN compound_statement
			{
				fprintf(outputs,"func_definition->type_specifier MAIN LPAREN RPAREN compound_statement     Main function\n");
			}
 		;				

parameter_list  : parameter_list COMMA type_specifier ID
			{
				fprintf(outputs,"parameter_list  -> parameter_list COMMA type_specifier ID    %s\n",$4->getName());
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
				fprintf(outputs,"parameter_list  -> parameter_list COMMA type_specifier\n");
				args.push_back($3->getVarType());			
			}
 		| type_specifier ID
			{
				fprintf(outputs,"parameter_list -> type_specifier ID\n");
				args.push_back(variable_type);
				//insertIntoST($2->getName(),$2->getType());
				IDargs++;
				$2->setIDType("VAR");
				$2->setVarType(variable_type);//$1->getVarType()
				paramList.push_back(*$2);
			}
		| type_specifier
			{
				fprintf(outputs,"parameter_list  ->type_specifier\n");
				args.push_back(variable_type);
			}
 		;

 		
compound_statement : LCURL{
				h.EnterScope(); 
				for(int i = 0; i<paramList.size();i++) 
					h.Insert(paramList[i]);
				paramList.clear();
			  } 
		     statements {h.printAllScopeInFile(logs);}
	             RCURL{h.ExitScope();}
			{
				fprintf(outputs,"compound_statement -> LCURL statements RCURL\n");
			}
 		    | LCURL RCURL
			{
				fprintf(outputs,"compound_statement -> LCURL RCURL\n");
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		{
			//printf("hi var dec\n");
			fprintf(outputs,"var_declaration ->type_specifier declaration_list SEMICOLON\n");	
		}
 		 ;
 		 
type_specifier	: INT
		{
			//printf("hi type spec.\n");
			fprintf(outputs,"type_specifier	: INT\n");	
			SymbolInfo* s= new SymbolInfo("INT");
			variable_type = "INT";
			$$ = s;
		}
 		| FLOAT
		{
			fprintf(outputs,"type_specifier	: FLOAT\n");
			SymbolInfo* s= new SymbolInfo("FLOAT");
			variable_type = "FLOAT";
			$$ = s;
	
		}
 		| VOID
		{
			fprintf(outputs,"type_specifier	: VOID\n");	
			SymbolInfo* s= new SymbolInfo("VOID");
			variable_type = "VOID";
			$$ = s;

		}
 		;
 		
declaration_list : declaration_list COMMA ID
			{
				
				fprintf(outputs,"declaration_list -> declaration_list COMMA ID\n");
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
								h.printAllScopeInFile(logs);
							}
						}

			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
			{
				fprintf(outputs,"declaration_list -> declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n");
				//insertIntoST($3->getName(),$3->getType());
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
						if(!strcmp(variable_type, "INT")){								
							for(int i = temp2->ints.size(); i<araSize; i++){
								temp2->ints.push_back(0);
							}							
						}
						else if(!strcmp(variable_type,"FLOAT")){								
							for(int i = temp2->floats.size(); i<araSize; i++){
								temp2->floats.push_back(0);
							}							
						}
						else if(!strcmp(variable_type ,"CHAR")){								
							for(int i = temp2->chars.size(); i<araSize; i++){
								temp2->chars.push_back('\0');
							}							
						}
						h.Insert(*temp2);						
						h.printAllScopeInFile(logs);
					}
				}

			}
 		  | ID
			{
				//printf("hi id\n");
				fprintf(outputs,"declaration_list -> ID\n");
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
						SymbolInfo* temp2 = new SymbolInfo($1->getName(), $1->getType());
						temp2->setVarType(variable_type);
						temp2->setIDType("VAR");
						h.Insert(*temp2);		
						listNode* temp = h.Lookup($1->getName(),"VAR");
						h.printAllScopeInFile(logs);		
					}
				}
				

			}
 		  | ID LTHIRD CONST_INT RTHIRD
			{
				fprintf(outputs,"declaration_list -> ID LTHIRD CONST_INT RTHIRD\n");
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
				//printf("hi sts\n");
				fprintf(outputs,"statements -> statement\n");
		}
	   | statements statement
		{
				fprintf(outputs,"statements -> statements statement\n");
		}
	   ;
	   
statement : COMMENT
		{
			fprintf(outputs,"statement -> comment\n");
		}
	  
	  |var_declaration
		{
				fprintf(outputs,"statement -> var_declaration\n");
		}
	  | expression_statement
		{
				//printf("hi stat\n");
				fprintf(outputs,"statement -> expression_statement\n");
		}
	  | compound_statement
		{
				fprintf(outputs,"statement -> compound_statement\n");
		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
		{
				fprintf(outputs,"statement ->  FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
		}
	  | IF LPAREN expression RPAREN statement %prec dummy_prec 
		{
				fprintf(outputs,"statement -> IF LPAREN expression RPAREN statement\n");
		}
	  | IF LPAREN expression RPAREN statement ELSE statement
		{
				fprintf(outputs,"statement -> IF LPAREN expression RPAREN statement ELSE statement\n");
		}
	  | WHILE LPAREN expression RPAREN statement
		{
				fprintf(outputs,"statement -> WHILE LPAREN expression RPAREN statement\n");
		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
		{
				fprintf(outputs,"statement -> PRINTLN LPAREN ID RPAREN SEMICOLON\n");
		}
	  | RETURN expression SEMICOLON
		{
				fprintf(outputs,"statement -> RETURN expression SEMICOLON\n");
		}
	  ;
	  
expression_statement 	: SEMICOLON	
				{
				fprintf(outputs,"expression_statement 	-> SEMICOLON	\n");
				}		
			| expression SEMICOLON
				{
				//printf("hi expr semicol\n");
				fprintf(outputs,"expression_statement 	->expression SEMICOLON	\n");
				} 
			;
	  
variable : ID 	
		{				
				fprintf(outputs,"variable -> ID\n");
				listNode* temp = h.Lookup($1->getName(),"VAR");				
				if(!temp){				
					fprintf(logs,"Error:Line %d:Type Mismatch occured or %s is not declared\n",line_count,$1->getName());				
					semErrors++;
				}
				else{
					static SymbolInfo si=temp->item;
					$$ =&si;
					
				}
		}	
	 | ID LTHIRD expression RTHIRD 
		{
			fprintf(outputs,"variable -> ID LTHIRD expression RTHIRD\n");
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
				if($3->ints[0] >= temp.getAraSize()){
					fprintf(logs,"Error:Line %d:array index out of bounds\n",line_count);				
					semErrors++;
					//temp->setAraIndex(0);
				} 
				else temp.setAraIndex($3->ints[0]);
				if(!strcmp(temp.getVarType() , "INT")){
					while(temp.ints.size() <= temp.getAraIndex()){
						temp.ints.push_back(0);
					}
				}
				else if(!strcmp(temp.getVarType(), "FLOAT")){
					while(temp.floats.size() <= temp.getAraIndex()){
						temp.floats.push_back(0);
					}
				}
				else if(!strcmp(temp.getVarType(), "CHAR")){
					while(temp.chars.size() <= temp.getAraIndex()){
						temp.chars.push_back('\0');
					}
				}
				$$ = &temp;
				//variable_type = temp->getVarType();
			}			
		
		}
	 ;
	 
expression : logic_expression	
		{
				fprintf(outputs,"expression -> logic_expression\n");
		}
	   | variable ASSIGNOP logic_expression
		{
				fprintf(outputs,"expression -> variable ASSIGNOP logic_expression\n");
				char* vType = $1->getVarType();
				printf("hi express %s\n",$1->getIDType());
				if(!strcmp($1->getIDType(),"dummy"))					printf("");
				else if(!strcmp(vType, "INT")){
					if(!strcmp($1->getIDType() ,"VAR")){
						$1->ints.push_back(0);
						if(!strcmp($3->getVarType(), "INT")){
							if(!strcmp($3->getIDType(), "VAR"))$1->ints[0] = $3->ints[0];
							else $1->ints[0] = $3->ints[$3->getAraIndex()];
						}
						else{
							fprintf(logs,"Warning :line %d: converting float value to integer\n",line_count);
							if(!strcmp($3->getIDType() , "VAR"))$1->ints[0] = (int)$3->floats[0];
							else $1->ints[0] = (int)$3->floats[$3->getAraIndex()];
						}
					}
					else if(!strcmp($1->getIDType(), "ARAY")){
						$1->ints.push_back(0);
						if(!strcmp($3->getVarType(), "INT")){
							if(!strcmp($3->getIDType(), "VAR"))$1->ints[$1->getAraIndex()] = $3->ints[0];
							else $1->ints[$1->getAraIndex()] = $3->ints[$3->getAraIndex()];
						}
						else{
							fprintf(logs,"Warning :line %d: converting float value to integer\n",line_count);
							if(!strcmp($3->getIDType(), "VAR"))$1->ints[$1->getAraIndex()] = (int)$3->floats[0];
							else $1->ints[$1->getAraIndex()] = (int)$3->floats[$3->getAraIndex()];
						}
					}
				}
				else if(!strcmp(vType, "FLOAT")){
					if(!strcmp($1->getIDType() , "VAR")){
						$1->floats.push_back(0);
						if(!strcmp($3->getVarType() , "INT")){
							if(!strcmp($3->getIDType(),"VAR"))$1->floats[0] = (float)$3->ints[0];
							else $1->floats[0] = (float)$3->ints[$3->getAraIndex()];
						}
						else{
							if(!strcmp($3->getIDType(), "VAR"))$1->floats[0] = $3->floats[0];
							else $1->floats[0] = $3->floats[$3->getAraIndex()];
						}
					}
					else if(!strcmp($1->getIDType() , "ARAY")){
						$1->floats.push_back(0);
						if(!strcmp($3->getVarType(),"INT")){
							if(!strcmp($3->getIDType(), "VAR"))$1->floats[$1->getAraIndex()] = (float)$3->ints[0];
							else $1->floats[$1->getAraIndex()] = (float)$3->ints[$3->getAraIndex()];
						}
						else{
							fprintf(logs,"Warning :line %d: converting float value to integer\n",line_count);
							if(!strcmp($3->getIDType(), "VAR"))$1->floats[$1->getAraIndex()] = $3->floats[0];
							else $1->floats[$1->getAraIndex()] = $3->floats[$3->getAraIndex()];
						}
					}
				}
				$$ = $1;				
			} 	
	   		;
			
logic_expression 	: rel_expression
					{
						fprintf(outputs,"logic_expression -> rel_expression\n");
						$$ = $1; 
						$$->ints.push_back(0);
						$$->floats.push_back(0);
						
					} 	
		 			| rel_expression LOGICOP rel_expression
					{
						fprintf(outputs," : logic_expression -> rel_expression LOGICOP rel_expression\n");
						SymbolInfo* temp = new SymbolInfo("INT");
						if($1->getVarType() == "CHAR" || $3->getVarType() == "CHAR"){
							//logFile << "Logical operation not allowed for char datatype" << endl;
							temp->ints.push_back(0);
						}
						string logicop = $2->getName();
						if(logicop == "&&"){
							if($1->getVarType() == "FLOAT"){
								$1->floats.push_back(0);
								if($1->floats[0] == 0){
									temp->ints[0] = 0;								
								}
								else if($3->getVarType() == "FLOAT"){
									$3->floats.push_back(0);
									if($3->floats[0] == 0) temp->ints[0] = 0;
									else temp->ints[0] = 1;
								}
								else if($3->getVarType() == "INT"){
									$3->ints.push_back(0);
									if($3->ints[0] == 0) temp->ints[0] = 0;
									else temp->ints[0] = 1;
								}
							}
							else if($1->getVarType() == "INT"){
								$1->ints.push_back(0);
								if($1->ints[0] == 0) temp->ints[0] = 0;
								else if($3->getVarType() == "FLOAT"){
									if($3->floats[0] == 0) temp->ints[0] = 0;
									else temp->ints[0] = 1;
								}
								else if($3->getVarType() == "INT"){\
									$3->ints.push_back(0);
									if($3->ints[0] == 0) temp->ints[0] = 0;
									else temp->ints[0] = 1;
								}
							}
						}
						else if(logicop == "||"){
							if($1->getVarType() == "FLOAT"){
								$1->floats.push_back(0);
								if($1->floats[0] != 0){
									temp->ints[0] = 1;								
								}
								else if($3->getVarType() == "FLOAT"){
									$3->floats.push_back(0);
									if($3->floats[0] != 0) temp->ints[0] = 1;
									else temp->ints[0] =0;
								}
								else if($3->getVarType() == "INT"){
									if($3->ints[0] != 0) temp->ints[0] = 1;
									else temp->ints[0] =0;
								}
							}
							else if($1->getVarType() == "INT"){
								$1->ints.push_back(0);
								if($1->ints[0] != 0) temp->ints[0] = 1;
								else if($3->getVarType() == "FLOAT"){
									$3->floats.push_back(0);									
									if($3->floats[0] != 0) temp->ints[0] = 1;
									else temp->ints[0] =0;
								}
								else if($3->getVarType() == "INT"){
									$3->ints.push_back(0);
									if($3->ints[0] != 0) temp->ints[0] = 1;
									else temp->ints[0] =0;
								}
							}
						}
						$$ = temp;	
			
		}	
	   ;
			
			
rel_expression	: simple_expression 
			{
				fprintf(outputs,"rel_expression	-> simple_expression  \n");
				$$ = $1;
				$$->ints.push_back(0);
				$$->floats.push_back(0);

			}
		| simple_expression RELOP simple_expression	
			{
				fprintf(outputs,"rel_expression	->simple_expression RELOP simple_expression  \n");
				SymbolInfo* temp = new SymbolInfo("INT");
				char* relop = $2->getName();
				char* type1 = $1->getVarType();
				char* type2 = $3->getVarType();
				if(!strcmp(relop ,"==")){
					if(strcmp(type1, type2)){
						//logFile << "Type mismatch for == operand" << endl;						
					}
					else if(!strcmp(type1, "INT")){
						if($1->ints[0] == $3->ints[0]) temp->ints[0] =1;
						else temp->ints[0] =0;
					}
					else if(!strcmp(type1,"FLOAT")){
						if($1->floats[0] == $3->floats[0]) temp->ints[0] =1;
						else temp->ints[0] =0;		
					}
					else if(!strcmp(type1, "CHAR")){
						if($1->chars[0] == $3->chars[0]) temp->ints[0] =1;
						else temp->ints[0] =0;		
					}
				}
				else if(!strcmp(relop,"!=")){
					if(strcmp(type1, type2)){
						//logFile << "Type mismatch for != operand" << endl;						
					}
					else if(!strcmp(type1, "INT")){
						if($1->ints[0] != $3->ints[0]) temp->ints[0] =1;
						else temp->ints[0] =0;
					}
					else if(!strcmp(type1, "FLOAT")){
						if($1->floats[0] != $3->floats[0]) temp->ints[0] =1;
						else temp->ints[0] =0;	
					}
					else if(!strcmp(type1, "CHAR")){
						if($1->chars[0] != $3->chars[0]) temp->ints[0] =1;
						else temp->ints[0] =0;	
					}
				}
				else if(!strcmp(relop, "<=") || !strcmp(relop, "<")){
					if(!strcmp(type1, "INT")){
						if(!strcmp(type2 ,"INT")){
							if($1->ints[0] < $3->ints[0]) temp->ints[0] =1;
							else if($1->ints[0] == $3->ints[0]) temp->ints[0] =1;
							else temp->ints[0] =0;
						}
						else if(!strcmp(type2, "FLOAT")){
							if($1->ints[0] < $3->floats[0]) temp->ints[0] =1;
							else if($1->ints[0] == $3->floats[0]) temp->ints[0] =1;
							else temp->ints[0] =0;
						}
					}
					else if(!strcmp(type1,"FLOAT")){
						if(!strcmp(type2, "INT")){
							if($1->floats[0] < $3->ints[0]) temp->ints[0] =1;
							else if($1->floats[0] == $3->ints[0])temp->ints[0] =1;
							else temp->ints[0] =0;
						}
						else if(!strcmp(type2, "FLOAT")){
							if($1->floats[0] < $3->floats[0]) temp->ints[0] =1;
							else if($1->floats[0] == $3->floats[0]) temp->ints[0] =1;
							else temp->ints[0] =0;
						}
					}

				}
				else if(!strcmp(relop, ">=") ||!strcmp(relop, ">")){
					if(!strcmp(type1, "INT")){
						if(!strcmp(type2, "INT")){
							if($1->ints[0] > $3->ints[0]) temp->ints[0] =1;
							else if($1->ints[0] == $3->ints[0])temp->ints[0] =1;
							else temp->ints[0] =0;
						}
						else if(!strcmp(type2, "FLOAT")){
							if($1->ints[0] > $3->floats[0]) temp->ints[0] =1;
							else if($1->ints[0] == $3->floats[0]) temp->ints[0] =1;
							else temp->ints[0] =0;
						}
					}
					else if(!strcmp(type1, "FLOAT")){
						if(!strcmp(type2, "INT")){
							if($1->floats[0] > $3->ints[0]) temp->ints[0] =1;
							else if($1->floats[0] == $3->ints[0]) temp->ints[0] =1;
							else temp->ints[0] =0;
						}
						else if(!strcmp(type2, "FLOAT")){
							if($1->floats[0] > $3->floats[0]) temp->ints[0] =1;
							else if($1->floats[0] == $3->floats[0]) temp->ints[0] =1;
							else temp->ints[0] =0;
						}
					}

				}
				$$ = temp;	

			}
		;
				
simple_expression : term 
			{
				fprintf(outputs,"simple_expression -> term   \n");
				$$ = $1;
				$$->ints.push_back(0);
				$$->floats.push_back(0);

			}
		  | simple_expression ADDOP term 
			{
				fprintf(outputs,"simple_expression -> simple_expression ADDOP term  \n");
				char* addop = $2->getName();
					//logFile << $1->ints[0] << "+" << $3->ints[0] << endl;
				if(!strcmp(addop, "+")){
					if(!strcmp($1->getIDType(), "VAR")){
						if(!strcmp($3->getIDType(), "VAR")){						
							if(!strcmp($1->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(), "INT")){
									temp->floats[0] =$1->floats[0] + $3->ints[0];							
								}
								else{
									temp->floats[0]=$1->floats[0] + $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(),"INT")){
									temp->floats[0]=$1->ints[0] + $3->floats[0];							
								}
								else{
									temp->floats[0]= $1->floats[0] + $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0] = $1->ints[0] + $3->ints[0];
								$$ = temp;
							}
						}
						else if(!strcmp($3->getIDType(), "ARAY")){						
							if(!strcmp($1->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(), "INT")){
									temp->floats[0] = $1->floats[0] + $3->ints[$3->getAraIndex()];							
								}
								else{
									temp->floats[0]= $1->floats[0] + $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(), "INT")){
									temp->floats[0]=$1->ints[0] + $3->floats[$3->getAraIndex()];							
								}
								else{
									temp->floats[0] = $1->floats[0] + $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0] =$1->ints[0] + $3->ints[$3->getAraIndex()];
								$$ = temp;
							}
						}
					}
					else if(!strcmp($1->getIDType() ,"ARAY")){
						if(!strcmp($3->getIDType(), "VAR")){						
							if(!strcmp($1->getVarType(),"FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(), "INT")){
									temp->floats[0] =$1->floats[$1->getAraIndex()] + $3->ints[0];							
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] + $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(),"FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType() ,"INT")){
									temp->floats[0]=$1->ints[$1->getAraIndex()] + $3->floats[0];							
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] + $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(),"INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0]=$1->ints[$1->getAraIndex()] + $3->ints[0];
								$$ = temp;
							}
						}
						else if(!strcmp($3->getIDType(), "ARAY")){						
							if(!strcmp($1->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType() ,"INT")){
									temp->floats[0]=$1->floats[$1->getAraIndex()] + $3->ints[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] + $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(), "INT")){
									temp->floats[0]=$1->ints[$1->getAraIndex()] + $3->floats[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] + $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0]=$1->ints[$1->getAraIndex()] + $3->ints[$3->getAraIndex()];
								$$ = temp;
							}
						}
					}
				}
				else if(!strcmp(addop, "-")){
					if(!strcmp($1->getIDType() , "VAR")){
						if(!strcmp($3->getIDType(),"VAR")){						
							if(!strcmp($1->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(), "INT")){
									temp->floats[0]=$1->floats[0] - $3->ints[0];							
								}
								else{
									temp->floats[0]=$1->floats[0] - $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(), "INT")){
									temp->floats[0]=$1->ints[0] - $3->floats[0];							
								}
								else{
									temp->floats[0]=$1->floats[0] - $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType() ,"INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0]=$1->ints[0] - $3->ints[0];
								$$ = temp;
							}
						}
						else if(!strcmp($3->getIDType(), "ARAY")){						
							if(!strcmp($1->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(), "INT")){
									temp->floats[0]=$1->floats[0] - $3->ints[$3->getAraIndex()];							
								}
								else{
									temp->floats[0]=$1->floats[0] - $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(), "INT")){
									temp->floats[0]=$1->ints[0] - $3->floats[$3->getAraIndex()];							
								}
								else{
									temp->floats[0]=$1->floats[0] - $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0]=$1->ints[0] - $3->ints[$3->getAraIndex()];
								$$ = temp;
							}
						}
					}
					else if(!strcmp($1->getIDType(), "ARAY")){
						if(!strcmp($3->getIDType() ,"VAR")){						
							if(!strcmp($1->getVarType() ,"FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(), "INT")){
									temp->floats[0]=$1->floats[$1->getAraIndex()] - $3->ints[0];							
								}
								else{
									temp->floats[0]= $1->floats[$1->getAraIndex()] - $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType() ,"FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(),"INT")){
									temp->floats[0]=$1->ints[$1->getAraIndex()] - $3->floats[0];							
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] - $3->floats[0];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(),"INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0]=$1->ints[$1->getAraIndex()] - $3->ints[0];
								$$ = temp;
							}
						}
						else if(!strcmp($3->getIDType(),"ARAY")){						
							if(!strcmp($1->getVarType(),"FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($3->getVarType(),"INT")){
									temp->floats[0]=$1->floats[$1->getAraIndex()] - $3->ints[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] - $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(),"FLOAT")){
								SymbolInfo* temp = new SymbolInfo("FLOAT");
								if(!strcmp($1->getVarType(), "INT")){
									temp->floats[0]=$1->ints[$1->getAraIndex()] - $3->floats[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=$1->floats[$1->getAraIndex()] - $3->floats[$3->getAraIndex()];
								}
								$$ = temp;
							}
							else if(!strcmp($3->getVarType(),"INT") && !strcmp($1->getVarType(), "INT")){
								SymbolInfo* temp = new SymbolInfo("INT");
								temp->ints[0]=$1->ints[$1->getAraIndex()] - $3->ints[$3->getAraIndex()];
								$$ = temp;
							}
						}
					}
				}


			}
		  ;
					
term :	unary_expression
		{
				fprintf(outputs,"term :	unary_expression \n");
				$$ = $1;
				$$->ints.push_back(0);
				$$->floats.push_back(0);
		}
     |  term MULOP unary_expression
		{
				printf("hi mulop\n");
				fprintf(outputs," term MULOP unary_expression \n");
				char* mulop = $2->getName();
				if(!strcmp(mulop, "*"))
				{
				   if(!strcmp($1->getIDType(), "VAR")){	
					 if(!strcmp($3->getIDType(), "VAR")){		
					     if(!strcmp($1->getVarType(), "FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($3->getVarType(), "INT")){
								temp->floats[0]=$1->floats[0] * $3->ints[0];							
							}
							else{
								temp->floats[0]=$1->floats[0] * $3->floats[0];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(), "FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($1->getVarType(),"INT")){
								temp->floats[0]=$1->ints[0] * $3->floats[0];							
							}
							else{
								temp->floats[0]=$1->floats[0] * $3->floats[0];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(),"INT") && !strcmp($1->getVarType(),"INT")){
							SymbolInfo* temp = new SymbolInfo("INT");
							temp->ints[0]=$1->ints[0] * $3->ints[0];
							$$ = temp;
						}
					}
					else if(!strcmp($3->getIDType(), "ARAY")){		
						if(!strcmp($1->getVarType() ,"FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($3->getVarType() ,"INT")){
								temp->floats[0]=$1->floats[0] * $3->ints[$3->getAraIndex()];							
							}
							else{
								temp->floats[0]=$1->floats[0] * $3->floats[$3->getAraIndex()];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(), "FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($1->getVarType(), "INT")){
								temp->floats[0]=$1->ints[0] * $3->floats[$3->getAraIndex()];							
							}
							else{
								temp->floats[0]=$1->floats[0] * $3->floats[$3->getAraIndex()];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(),"INT") && !strcmp($1->getVarType(), "INT")){
							SymbolInfo* temp = new SymbolInfo("INT");
							temp->ints[0]=$1->ints[0] * $3->ints[0];
							$$ = temp;
						}
					}
				}
				else if(!strcmp($1->getIDType(), "ARAY")){	
					if(!strcmp($3->getIDType(), "VAR")){		
						if(!strcmp($1->getVarType(), "FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($3->getVarType(), "INT")){
								temp->floats[0]=$1->floats[$1->getAraIndex()] * $3->ints[0];							
							}
							else{
								temp->floats[0]=$1->floats[$1->getAraIndex()] * $3->floats[0];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(), "FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($1->getVarType(), "INT")){
								temp->floats[0]=$1->ints[$1->getAraIndex()] * $3->floats[0];							
							}
							else{
								temp->floats[0]=$1->floats[$1->getAraIndex()] * $3->floats[0];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(), "INT")){
							SymbolInfo* temp = new SymbolInfo("INT");
							temp->ints[0]=$1->ints[$1->getAraIndex()] * $3->ints[0];
							$$ = temp;
						}
					}
					else if(!strcmp($3->getIDType(), "ARAY")){		
						if(!strcmp($1->getVarType(),"FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($3->getVarType(), "INT")){
								temp->floats[0]=$1->floats[$1->getAraIndex()] * $3->ints[$3->getAraIndex()];
							}
							else{
								temp->floats[0]=$1->floats[$1->getAraIndex()] * $3->floats[$3->getAraIndex()];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(), "FLOAT")){
							SymbolInfo* temp = new SymbolInfo("FLOAT");
							if(!strcmp($1->getVarType(), "INT")){
								temp->floats[0]=$1->ints[$1->getAraIndex()] * $3->floats[$3->getAraIndex()];
							}
							else{
								temp->floats[0]=$1->floats[$1->getAraIndex()] * $3->floats[$3->getAraIndex()];
							}
							$$ = temp;
						}
						else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType(),"INT")){
							SymbolInfo* temp = new SymbolInfo("INT");
							temp->ints[0]=$1->ints[$1->getAraIndex()] * $3->ints[0];
							$$ = temp;
						}
					}
				}
			}
			else if(!strcmp(mulop, "/"))
			{
				if(!strcmp($1->getVarType(), "FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					if(!strcmp($3->getVarType(), "INT")){
						if(!strcmp($1->getIDType(), "VAR")){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->ints[0] != 0)temp->floats[0]=$1->floats[0] / $3->ints[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
									fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");							

									semErrors++; 
								}							
							}
							else if(!strcmp($3->getIDType(), "ARAY")){
								if($3->ints[$3->getAraIndex()] != 0)temp->floats[0]=$1->floats[0] / $3->ints[$3->getAraIndex()];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
						else if(!strcmp($1->getIDType(),"ARAY")){
							if(!strcmp($3->getIDType(),"VAR")){
								if($3->ints[0] != 0)temp->floats[0]=$1->floats[$1->getAraIndex()] / $3->ints[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(),"ARAY")){
								if($3->ints[$3->getAraIndex()] != 0){
									temp->floats[0]=$1->floats[$1->getAraIndex()] / $3->ints[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
					}
					else if(!strcmp($3->getVarType(), "FLOAT")){
						if(!strcmp($1->getIDType(), "VAR")){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->floats[0] != 0)temp->floats[0]=$1->floats[0] / $3->floats[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(), "ARAY")){
								if($3->floats[$3->getAraIndex()] != 0)temp->floats[0]=$1->floats[0] / $3->floats[$3->getAraIndex()];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
						else if(!strcmp($1->getIDType(), "ARAY")){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->floats[0] != 0)temp->floats[0]=$1->floats[$1->getAraIndex()] / $3->floats[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(),"ARAY")){
								if($3->floats[$3->getAraIndex()] != 0){
									temp->floats[0]=$1->floats[$1->getAraIndex()] / $3->floats[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
					}
					$$ = temp;
				}
				else if(!strcmp($3->getVarType(),"FLOAT")){
					SymbolInfo* temp = new SymbolInfo("FLOAT");
					if(!strcmp($1->getVarType(), "INT")){
						if($1->getIDType() == "VAR"){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->floats[0] != 0)temp->floats[0]=$1->ints[0] / $3->floats[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(), "ARAY")){
								if($3->floats[$3->getAraIndex()] != 0)temp->floats[0]=$1->ints[0] / $3->floats[$3->getAraIndex()];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
						else if(!strcmp($1->getIDType(),"ARAY")){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->floats[0] != 0)temp->floats[0]=$1->ints[$1->getAraIndex()] / $3->floats[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(), "ARAY")){
								if($3->floats[$3->getAraIndex()] != 0){
									temp->floats[0]=$1->ints[$1->getAraIndex()] / $3->floats[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
					}
					else if(!strcmp($1->getVarType(), "FLOAT")){
						if(!strcmp($1->getIDType(), "VAR")){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->floats[0] != 0)temp->floats[0]=$1->floats[0] / $3->floats[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(),"ARAY")){
								if($3->floats[$3->getAraIndex()] != 0)temp->floats[0]=$1->floats[0] / $3->floats[$3->getAraIndex()];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
						else if(!strcmp($1->getIDType(),"ARAY")){
							if(!strcmp($3->getIDType(), "VAR")){
								if($3->floats[0] != 0)temp->floats[0]=$1->floats[$1->getAraIndex()] / $3->floats[0];
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}							
							}
							else if(!strcmp($3->getIDType(), "ARAY")){
								if($3->floats[$3->getAraIndex()] != 0){
									temp->floats[0]=$1->floats[$1->getAraIndex()] / $3->floats[$3->getAraIndex()];
								}
								else{
									temp->floats[0]=numeric_limits<float>::infinity();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
									semErrors++;
								}
							}
						}
					}				
					$$ = temp;
				}
				else if(!strcmp($3->getVarType(), "INT") && !strcmp($1->getVarType() , "INT")){
					SymbolInfo* temp = new SymbolInfo("INT");
					if(!strcmp($1->getIDType() , "VAR")){	
						if(!strcmp($3->getIDType() , "VAR")){			
							if($3->ints[0] != 0)temp->ints[0]=$1->ints[0] / $3->ints[0];
							else{
								temp->ints[0]=numeric_limits<int>::max();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
								semErrors++;
							}
						}
						else if(!strcmp($3->getIDType(), "ARAY")){
							if($3->ints[$3->getAraIndex()] != 0)temp->ints[0]=$1->ints[0] / $3->ints[$3->getAraIndex()];
							else{
								temp->ints[0]=numeric_limits<int>::max();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
								semErrors++;
							}
						}
					}
					else if(!strcmp($1->getIDType() ,"ARAY")){
						if(!strcmp($3->getIDType() , "VAR")){			
							if($3->ints[0] != 0)temp->ints[0]=$1->ints[$1->getAraIndex()] / $3->ints[0];
							else{
								temp->ints[0]=numeric_limits<int>::max();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
								semErrors++;
							}
						}
						else if(!strcmp($3->getIDType(), "ARAY")){
							if($3->ints[$3->getAraIndex()] != 0)
							{
								temp->ints[0]=$1->ints[$1->getAraIndex()] / $3->ints[$3->getAraIndex()];
							}
							else{
								temp->floats[0]=numeric_limits<int>::max();
							fprintf(logs,"Error:Line %d :Divide by zero\n,line_count");
								semErrors++;
							}
						}
					}
					$$ = temp;
				}
			}
			else if(!strcmp(mulop, "%")){
				SymbolInfo* temp = new SymbolInfo("INT");
				temp->setIDType("VAR");
				if(!strcmp($1->getVarType() ,"FLOAT") || !strcmp($3->getVarType(), "FLOAT")){
					fprintf(logs," Error: Unsuported operand for mod operator\n");
					semErrors++;
				}
				else if(!strcmp($1->getVarType(), "INT") && !strcmp($3->getVarType(), "INT")){
					if(!strcmp($1->getIDType(), "VAR")){
						if(!strcmp($3->getIDType(), "VAR"))temp->ints[0]=($1->ints[0])%($3->ints[0]);
						else temp->ints[0]= ($1->ints[0])%($3->ints[$3->getAraIndex()]);					
					}
					else{
						if(!strcmp($3->getIDType(), "VAR"))temp->ints[0]=($1->ints[$1->getAraIndex()])%($3->ints[0]);
						else temp->ints[0]=($1->ints[$1->getAraIndex()])%($3->ints[$3->getAraIndex()]);					
					}
				}
				$$ = temp;
			}

				
		}
     ;

unary_expression : ADDOP unary_expression  
			{
				fprintf(outputs," unary_expression -> ADDOP unary_expression  \n");
				if(!strcmp($1->getName(), "-")){
						if(!strcmp($2->getVarType(),"VAR")){
							$2->ints[0] = (-1)*($2->ints[0]);
						}
						else if(!strcmp($2->getVarType(),"ARA")){
							$2->ints[$2->getAraIndex()] = (-1)*($2->ints[$2->getAraIndex()]);
						}
				}
				$$ = $2;
				
			}
		 | NOT unary_expression 
			{			
				fprintf(outputs," unary_expression -> NOT unary_expression  \n");
				SymbolInfo* temp = new SymbolInfo("INT");
				temp->setIDType("VAR");
				int value;
				if(!strcmp($2->getVarType(),"INT")){
					if(!strcmp($2->getIDType(), "VAR")) value = $2->ints[0];
					else if(!strcmp($2->getIDType() ,"ARA"))value = $2->ints[$2->getAraIndex()];
				}
				else if($2->getVarType() == "FLOAT"){
					if($2->getIDType() == "VAR") value = (int)$2->floats[0];
					else if($2->getIDType() == "ARAY") value = (int)$2->floats[$2->getAraIndex()];
				} 
				if(value!= 0) value = 0;
				else value = 1;
				temp->ints[0]=value;
				$$=temp;
				

			}
		 | factor   
			{
				fprintf(outputs," unary_expression -> factor \n");
				$$ = $1;
				$$->ints.push_back(0);
				$$->floats.push_back(0);
			}
		 ;
	
factor	: variable 
		{
				fprintf(outputs," factor-> variable  \n");
		}
	| ID LPAREN argument_list RPAREN
		{
				printf("hi factor\n");
				fprintf(outputs," factor-> ID LPAREN argument_list RPAREN  \n");
				listNode *temp=h.Lookup($1->getName(),"FUNC");
				if(!temp)
					fprintf(logs,"Error:Line %d :function %s doesn't exist",line_count,$1->getName());
				else{
				  if(!strcmp(temp->item.getFuncRet() ,"VOID")){
				 	fprintf(logs,"Error:Line %d :function %s returns VOID",line_count,$1->getName());
				  } 
				  else{
					SymbolInfo *temp2 = new SymbolInfo(temp->item.getFuncRet());					
					if(!strcmp(temp2->getVarType(),"INT"))temp2->ints[0] = 0;		
					if(!strcmp(temp2->getVarType(),"FLOAT"))temp2->floats[0] = 0;
					else if(!strcmp(temp2->getVarType(),"CHAR"))temp2->chars[0] = '\0';
					$$ = temp2;
				  }
				}

					
		}
	| LPAREN expression RPAREN
		{
				fprintf(outputs," factor-> LPAREN expression RPAREN  \n");
				$$ = $2;
		}
	| CONST_INT 
		{
				fprintf(outputs," factor-> CONST_INT  \n");
				$1->setVarType("INT");			
				$1->ints[0]= atoi($1->getName());
				$1->setIDType("VAR");
				$$ = $1;	
		}
	| CONST_FLOAT
		{
				fprintf(outputs," factor-> CONST_FLOAT  \n");
				$1->setVarType("FLOAT");
				$1->floats[0]= atof($1->getName());
				$1->setIDType("VAR");
				$$ = $1;

		}
	| variable INCOP 
		{
				fprintf(outputs," factor-> variable INCOP \n");
				if($1->getIDType() == "ARAY"){
				  if($1->getVarType() == "INT"){
					$1->ints[$1->getAraIndex()] = $1->ints[$1->getAraIndex()]+1; 
				  }
				  else if($1->getVarType() == "FLOAT"){
					$1->floats[$1->getAraIndex()] = $1->floats[$1->getAraIndex()]+1.0; 
				  }			
				}
				else if($1->getIDType() == "VAR"){
				  if($1->getVarType() == "INT"){
					$1->ints[0] = $1->ints[0]+1; 
				  }
				  else if($1->getVarType() == "FLOAT"){
					$1->floats[0] = $1->floats[0]+1.0; 
				  }					
				}
			$$ = $1;
		}
	| variable DECOP
		{
				fprintf(outputs," factor-> variable DECOP \n");
				if($1->getIDType() == "ARAY"){
				  if($1->getVarType() == "INT"){
					$1->ints[$1->getAraIndex()] = $1->ints[$1->getAraIndex()]-1; 
				  }
				  else if($1->getVarType() == "FLOAT"){
					$1->floats[$1->getAraIndex()] = $1->floats[$1->getAraIndex()]-1.0; 
				  }			
				}
				else if($1->getIDType() == "VAR"){
				  if($1->getVarType() == "INT"){
					$1->ints[0] = $1->ints[0]-1; 
				  }
				  else if($1->getVarType() == "FLOAT"){
					$1->floats[0] = $1->floats[0]-1.0; 
				  }					
				}
			$$ = $1;
		}
	;
	
argument_list : arguments
		{
				fprintf(outputs," argument_list : arguments \n");
		}
			  |
			  ;
	
arguments : arguments COMMA logic_expression
		{
				fprintf(outputs," arguments : arguments COMMA logic_expression\n");
		}
	      | logic_expression
		{
				fprintf(outputs," arguments : logic_expression\n");
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
	return 0;
}

