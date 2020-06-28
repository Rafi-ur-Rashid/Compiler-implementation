%option noyywrap
%{
#include<iostream>
#include<stdio.h>
#include<stdlib.h>
#include<cstring>
#include "y.tab.h"
using namespace std;
  int line_count=1;
  int errCount=0;
  extern YYSTYPE yylval;
  FILE* logs;
  FILE* outputs;
  void yyerror(char *);
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
	if(c[i]=='\\'){
	  continue;
	}
	else if(c[i]=='\n')
	{
	  line_count++;
	  continue;
	}
	else{
	  temp[j]=c[i];
	  j++;
	}
  }	
  return temp; 
}


%}
/*
'[!-~]' |'\\n'|'\\t'|'\\f'|'\\a'|'\\r'|'\\b'|'\\v'|'\\\'|'\\0'
*/
char [ -~]{-}[']
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
mLineComment ("/*"([^"*"]|"*"[^"/"])+"*/")
tooManyDecPoint {integer}*((\.)+{integer}+)+
illFormNum {integer}(\.{integer})?(E[+-]?(\.)*{integer})?(\.)*{integer}*
invalidId_number {integer}{identifier} 
multChar  ('({char}{char}+)')
unfinChar '{char}[^']?
unfinString (\"([^\"\n]|\\[\n])*)
unfinComment ("/*"([^"*"]|"*"[^"/"])+[^"*/"])

%%
{WHITESPACE} {}
{NEWLINE} {line_count++;}

";" 	{printf("hi semicolon\n");return SEMICOLON;}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}
"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"int" {printf("I m int\n");
	return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"void" {return VOID;}
"main"	{return MAIN;}
"println"	{return PRINTLN;}


{integer}       {
			printf("gotta\n");
			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), "CONST_INT");
			yylval =(YYSTYPE) s;
			return CONST_INT;
			//char * temp=yytext;
			//fprintf(tokenout,"<CONST_INT,%s>",temp);
			//insertIntoST(yytext,"CONST_INT");
			//fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,temp);
		}

{float}       {

			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char*)"CONST_FLOAT");
			yylval = (YYSTYPE)s;
			return CONST_FLOAT;
			//fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
			//insertIntoST(yytext,"CONST_FLOAT");
			//fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
		}

{identifier} 		{	 
				char* temp=(char*)malloc(yyleng*sizeof(char));
				SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"ID");
				yylval = (YYSTYPE)s;			
				return ID;	
			}

"+"		|

"-"		{
			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"ADDOP");
			yylval = (YYSTYPE)s;
			return ADDOP;
		}
		
"*"		|
"/"		|
"%"		{

			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"MULOP");
			yylval = (YYSTYPE)s;
			return MULOP;
			//fprintf(tokenout,"<MULOP,%s>",yytext);
			//insertIntoST(yytext,"MULOP");
			//fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			
		}
				

"=" 	{printf("hi ass\n");return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
		char* temp=(char*)malloc(yyleng*sizeof(char));
		SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"RELOP");
		yylval = (YYSTYPE)s;
		return RELOP;
	}

"&&"	|
"||"	{
			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"LOGICOP");
			yylval = (YYSTYPE)s;
			return LOGICOP;
		}
"!"		{	return NOT; }

{charLiteral}       {
			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"CONST_CHAR");
			yylval = (YYSTYPE)s;
			return CONST_CHAR;
		}

"<<"		|
">>"		{
			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"BITOP");
			yylval = (YYSTYPE)s;
			return BITOP;
		}

{string}        {
			char* temp=(char*)malloc(yyleng*sizeof(char));
			SymbolInfo* s= new SymbolInfo(strcpy(temp,(char*)yytext), (char *)"STRING");
			yylval = (YYSTYPE)s;
			return STRING;
		}

{sLineComment}  {
			return COMMENT;
		}
{mLineComment}  {
			return COMMENT;
		}
{tooManyDecPoint}  {   fprintf(logs,"Line no %d: Lexeme %s is found as too many decimal pointer error\n",line_count,yytext);
			errCount++;
		
		} 
{multChar}       {
			fprintf(logs,"Line no %d: Lexeme %s found as multi char error\n",line_count,some_func(yytext,yyleng));
			errCount++;
		}
{illFormNum}    {
			fprintf(logs,"Line no %d: Lexeme %s is found as ill form number error\n",line_count,yytext); 
			errCount++;
		}
{invalidId_number}  {
			fprintf(logs,"Line no %d: Lexeme %s is found as invalid id or number error\n",line_count,yytext); 
			errCount++;
		}
{unfinChar}  {
			fprintf(logs,"Line no %d: Lexeme %s is found as unfinished character error\n",line_count,yytext); 
			errCount++;
		}
{unfinString}  {
		fprintf(logs,"Line no %d: found unfinished string error\n",line_count);
		errCount++; 
		}
{unfinComment}  {
		fprintf(logs,"Line no %d: found unfinished comment error\n",line_count); 
		errCount++;
		}	
.		{
			fprintf(logs,"Line no %d: found Unrecognized character error\n",line_count); 
			errCount++;
		}

%%

/*
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
*/
