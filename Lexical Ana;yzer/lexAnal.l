%option noyywrap
%{
#include<stdio.h>
#include<stdlib.h>
#include "1505045_symbol table.cpp"
int line_count=1;
  SymbolTable h;
  FILE logout;
  FILE tokenout;

char* some_func(char* c,int l) {
  char* temp=(char*)malloc(l*sizeof(char)-2);
  int j=0;
  for(int i=1;i<l-1;i++)
  {
	temp[j]=c[i];
	j++;
  }	
  return temp; 
}

char* some_func2(char* c,int l) {
  char* temp=(char*)malloc(l*sizeof(char)-2);
  int j=0;
  for(int i=1;i<l-1;i++)
  {
	  temp[j]=c[i];
	j++;
  }	
  return temp; 
}

void insertIntoST(char* name,char* type)
{
  SymbolInfo info;
  info.setName(name);
  info.setType(type);
  h.Insert(info); 
  h.printCurrentScopeInFile(logout);
}

%}
/*
'[!-~]' |'\\n'|'\\t'|'\\f'|'\\a'|'\\r'|'\\b'|'\\v'|'\\\'|'\\0'
*/
char [ -~]
chars {char}+
WHITESPACE [ \t\f\r\v]+ 
charLiteral '\\n'|'\\t'|'\\f'|'\\a'|'\\r'|'\\b'|'\\v'|'\\\'|'\\0'|'{char}'
/* */
digit [0-9]
integer {digit}+
float  {integer}(\.{integer})?(E[+-]?{integer})?
letter [a-zA-Z] 
identifier (_|{letter})(_|{letter}|{digit})* 
NEWLINE \n 
string  \"([^\"\n]|\\{NEWLINE})*\"
sLineComment ("//"){chars}$ 
mLineComment (("/*")((.)|{NEWLINE})*("*/")) 
tooManyDecPoint {integer}*((\.)+{integer}+)+
illFormNum {integer}(\.{integer})?(E[+-]?(\.)*{integer})?(\.)*{integer}*
invalidId_number {integer}{identifier}
/*multChar  '{char}{chars}'*/
unfinChar '{char}[^']?
/*unfinString \"([^\"\n]|(\\{NEWLINE}))* */
%%
{WHITESPACE} {}
{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"for"	{
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}
"do"	{
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}
		
"int"	{
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}
"float"	{
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}
		
"void"	{
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}
"switch"	{
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
		
"default"	{
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
"else"	{
			fprintf(tokenout,"<ELSE>");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}
		
"while"	{
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}
"break"	{
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}
		
"char"	{
			fprintf(tokenout,"<CHAR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}
"double"	{
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}
		
"return"	{
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		}
"case"	{
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}
		
"continue"	{
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}

{integer}       {
			char * temp=yytext;
			fprintf(tokenout,"<CONST_INT,%s>",temp);
			insertIntoST(yytext,"CONST_INT");
			fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,temp);
		}

{float}       {
			fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
			insertIntoST(yytext,"CONST_FLOAT");
			fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
		}

{charLiteral}       {
			fprintf(tokenout,"<CONST_CHAR,%s>",some_func(yytext,yyleng));
			insertIntoST(some_func(yytext,yyleng),"CONST_CHAR");
			fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,some_func(yytext,yyleng));
		}

"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			insertIntoST(yytext,"ADDOP");
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			
		}
		
"*"		|
"/"		|
"%"		{
			fprintf(tokenout,"<MULOP,%s>",yytext);
			insertIntoST(yytext,"MULOP");
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			
		}
				
"++"		|

"--"		{
			fprintf(tokenout,"<INCOP,%s>",yytext);
			insertIntoST(yytext,"INCOP");
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
			
		}
"<"		|
"<="		|
">"		|
">="		|
"=="		|
"!="		{
			fprintf(tokenout,"<RELOP,%s>",yytext);
			insertIntoST(yytext,"RELOP");
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
			
		}
"="		{
			fprintf(tokenout,"<ASSIHNOP,%s>",yytext);
			insertIntoST(yytext,"ASSIHNOP");
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			
		}
"&&"		|
"||"		{
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			insertIntoST(yytext,"LOGICOP");
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
			
		}
"|"		|
"&"		|
"^"		|
"<<"		|
">>"		{
			fprintf(tokenout,"<BITOP,%s>",yytext);
			insertIntoST(yytext,"BITOP");
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
			
		}
"!"		{
			fprintf(tokenout,"<NOT,%s>",yytext);
			insertIntoST(yytext,"NOT");
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
			
		}
"("		{
			fprintf(tokenout,"<LPAREN,%s>",yytext);
			insertIntoST(yytext,"LPAREN");
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
			
		}
")"		{
			fprintf(tokenout,"<RPAREN,%s>",yytext);
			insertIntoST(yytext,"RPAREN");
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
			
		}
"{"		{
			fprintf(tokenout,"<LCURL,%s>",yytext);
			insertIntoST(yytext,"LCURL");
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
			
		}
"}"		{
			fprintf(tokenout,"<RCURL,%s>",yytext);
			insertIntoST(yytext,"RCURL");
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
			
		}
"["		{
			fprintf(tokenout,"<LTHIRD,%s>",yytext);
			insertIntoST(yytext,"LTHIRD");
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
			
		}
"]"		{
			fprintf(tokenout,"<RTHIRD,%s>",yytext);
			insertIntoST(yytext,"RTHIRD");
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
			
		}
","		{
			fprintf(tokenout,"<COMMA,%s>",yytext);
			insertIntoST(yytext,"COMMA");
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
			
		}
";"		{
			fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			insertIntoST(yytext,"SEMICOLON");
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			
		}
{identifier}		{
			fprintf(tokenout,"<ID,%s>",yytext);
			insertIntoST(yytext,"ID");
			fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
			
		}

{string}        {
			fprintf(tokenout,"<STRING,%s>",some_func2(yytext,yyleng));
			
			fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_count,some_func(yytext,yyleng));
		}

{sLineComment}  {
			fprintf(tokenout,"<sLine,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <sLine> Lexeme %s found\n",line_count,some_func(yytext,yyleng));
		}
{mLineComment}  {
			fprintf(tokenout,"<mLine,%s>",yytext);
			
			fprintf(logout,"Line no %d: TOKEN <mLine> Lexeme %s found\n",line_count,some_func(yytext,yyleng));
		}
{tooManyDecPoint}  {   fprintf(logout,"Line no %d: Lexeme %s is found as too many decimal pointer error\n",line_count,yytext);
		
		} 
{illFormNum}    {
			fprintf(logout,"Line no %d: Lexeme %s is found as ill form number error\n",line_count,yytext); 
		}
{invalidId_number}  {
			fprintf(logout,"Line no %d: Lexeme %s is found as invalid id or number error\n",line_count,yytext); 
		}
{unfinChar}  {
			fprintf(logout,"Line no %d: Lexeme %s is found as unfinished character error\n",line_count,yytext); 
		}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
  	h.EnterScope();
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}

