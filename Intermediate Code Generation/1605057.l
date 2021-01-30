%option noyywrap

%x ML_COMMENT
%x TL_COMMENT
%x SL_STRING


%{
//here you add your symbol table header file
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include<iostream>
#include<bits/stdc++.h>

#include"1605057_SymbolTable.h"
#include"y.tab.h"

using namespace std;

int comment=0;
int comment2=0;
string cmnt="";
string cmnt2="";
string str1="";
string str2="";
int str=0;
extern int err;
extern int ferr;
extern int werr;
extern int line_count;
extern int error_count;

extern string sif;
extern symbolTable st;
extern FILE *logFile;
 //extern FILE *errorFile;
//  extern symbolInfo *ret;
%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
ADDOP [+-] 
MULOP [*/%]

%%

{WHITESPACE} {}

{NEWLINE} {line_count++;}

"if"	{err=line_count;  return IF;}		
"else"	{return ELSE;}
"for"	{ferr=line_count;  return FOR;}
"while"	{werr=line_count;  return WHILE;}
"do"	{return DO;}
"break" {return BREAK;}

"int"	{return INT;}
"char"	{return CHAR;}
"float"	{return FLOAT;}
"double" {return DOUBLE;}
"void"	{return VOID;}
"return" {return RETURN;}
"switch" {return SWITCH;}
"case" {return CASE;}

"default" {return DEFAULT;}		
"continue" {return CONTINUE;}
"println"	{return PRINTLN;}

"!"	{return NOT;}

"("	{ 
	return LPAREN;}

")"	{return RPAREN;}
"{"	{
	//fclose(logFile);
	//st.enterScope(10);
	//logFile=fopen("log.txt","a");
        return LCURL;}
"}"	{//ret=new symbolInfo();
	//fclose(logFile);
	//st.exitScope();
	//logFile=fopen("log.txt","a");
	return RCURL;}
"["	{return LTHIRD;}
"]"	{return RTHIRD;}
","	{return COMMA;}
"="	{return ASSIGNOP;}
";" {return SEMICOLON;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
	symbolInfo *si= new  symbolInfo();
	si->setName(yytext);
	si->setType("RELOP");
	yylval.symInfo=si;
	return RELOP;
}
"&&"	|
"||"	{
	symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("LOGICOP");
	yylval.symInfo=si;
	return LOGICOP;
}
"&" 		|  
"|"		|
"^"		|
">>"		|
"<<"		{
	symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("BITOP");
	yylval.symInfo=si;
	return BITOP;	
}


{ADDOP}		{
	symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("ADDOP");
	yylval.symInfo=si;
	return ADDOP;	
}
{MULOP}		{
	symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("MULOP");
	yylval.symInfo=si;
	return MULOP;	
}
\'  		{fprintf(logFile,"Lexical error at line. %d ",line_count);
	 	fprintf(logFile,"Unterminated character %s\n\n",yytext);error_count++;}

\'\'   {fprintf(logFile,"Lexical error at line_no %d: ",line_count);
	fprintf(logFile,"Empty character constant error %s\n\n",yytext);
	error_count++;}


[_a-zA-Z][0-9a-zA-Z_]* {
	symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("ID");
	yylval.symInfo=si;
	return ID;
}
{DIGIT}+ 	{symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("CONST_INT");
	yylval.symInfo=si;
	return CONST_INT;
}
{DIGIT}+[.]{DIGIT}*[eE][-+]{DIGIT}+ |
{DIGIT}+[.]{DIGIT}*[eE]{DIGIT}+ |
{DIGIT}+[.] |
{DIGIT}*[.]{DIGIT}+ |
{DIGIT}*[.]{DIGIT}+[eE]{DIGIT}+ |
{DIGIT}*[.]{DIGIT}+[eE][-+]{DIGIT}+ |
{DIGIT}+[Ee]{DIGIT}+   {symbolInfo* si= new symbolInfo();

	si->setName(yytext);
	si->setType("CONST_FLOAT");
	yylval.symInfo=si;
	return CONST_FLOAT;}

\'[^\n\\\']\' 	{ 	
		 symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			
		}

\'\\n\'		{
		 symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
		}
\'\\t\'		{
		 symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
		}
\'\\a\'		{
		 symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
		}			
\'\\f\'		{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}
\'\\r\'			{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}
\'\\b\'			{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		// return CONST_CHAR;
			}
\'\\v\'			{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}
\'\\0\'			{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}
\'\\\\\'		{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}
\'\\\"\'		{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}
\'\\\'\'		{
			symbolInfo* si= new symbolInfo();
		 si->setName(yytext);
		 si->setType("CONST_CHAR");
		 yylval.symInfo=si;
		 //return CONST_CHAR;
			}

"/*"		{ comment=line_count; cmnt=cmnt+string(yytext); BEGIN(ML_COMMENT); }

<ML_COMMENT>"*/" 	{ cmnt=cmnt+string(yytext);
			 // fprintf(logout,"\nLine no %d: TOKEN <COMMENT> Lexeme %s found\n",comment,cmnt.c_str()); 
			  cmnt="";
			  BEGIN(INITIAL); // return ML_COMMENT;
			}

<ML_COMMENT>[^*\n]+	{cmnt=cmnt+string(yytext);}
	
<ML_COMMENT>"*"		{cmnt=cmnt+string(yytext);}
		
<ML_COMMENT>"\n"	{cmnt=cmnt+string(yytext); line_count += 1; }


<ML_COMMENT><<EOF>>	{ fprintf(logFile,"Lexical error at line. %d ",comment);
			  fprintf(logFile,"Unterminated comment %s \n\n",cmnt.c_str());
			  cmnt="";
			  BEGIN(INITIAL);
			  error_count++;
			}

"//"	        {comment2=line_count; cmnt2=cmnt2+string(yytext);BEGIN(TL_COMMENT);}

<TL_COMMENT>(\\){NEWLINE}  {cmnt2=cmnt2+string(yytext); line_count += 1;}

<TL_COMMENT>{NEWLINE} 	{
		 	 //fprintf(logout,"\nLine no %d: TOKEN <COMMENT> Lexeme %s found\n",comment2,cmnt2.c_str()); 
			 cmnt2="";line_count += 1; BEGIN(INITIAL);
			//return SL_COMMENT;
			}

<TL_COMMENT>.	  {cmnt2=cmnt2+string(yytext);}

<TL_COMMENT><<EOF>>  {fprintf(logFile,"Lexical error at line. %d ",comment2);
		      fprintf(logFile,"Unterminated comment %s \n\n",cmnt2.c_str());
		      cmnt2="";
		      BEGIN(INITIAL);
		      error_count++;
		      }

[0-9]+[a-zA-Z_]+[0-9a-zA-Z_]* {fprintf(logFile,"Lexical error at line. %d ",line_count);
			       fprintf(logFile,"Invalid prefix on ID %s\n\n",yytext);
			       error_count++;}

\'((\\)*[^\n\'\\]+)*(\\\\)+\' |

\'[^\'\n][^\'\n]*[^\\\n\']\'  {fprintf(logFile,"Lexical error at line. %d ",line_count);
	 	  		fprintf(logFile,"Multi character constant error %s\n\n",yytext);
		                error_count++;}



\'[^\'\n]+  |
\'[^\'\n]*(\\)\'	{fprintf(logFile,"Lexical error at line. %d ",line_count);
	 	         fprintf(logFile,"Unterminated character %s\n\n",yytext);error_count++;}




["]		{str=line_count;str1=str1+string(yytext);
		str2=str2+string(yytext);BEGIN(SL_STRING);}

<SL_STRING>["]	{str1=str1+string(yytext);
		 str2=str2+string(yytext);
		 //fprintf(tokenout,"<STRING, %s> ",str1.c_str());
	         //fprintf(logout,"\nLine no %d: TOKEN <STRING> Lexeme %s found\n",str,str2.c_str()); 
		 str1="";
		 str2="";
		 str=0;
		 BEGIN(INITIAL); //return STRING;
			}

<SL_STRING>(\\){NEWLINE}  {str2=str2+string(yytext);line_count += 1;}

<SL_STRING>[^\n\\\"]	  {str1=str1+string(yytext); str2=str2+string(yytext);}

<SL_STRING>(\\)"n"   {char c='\n'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"t"   {char c='\t'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"b"   {char c='\b'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"v"   {char c='\v'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"0"   {char c='\0'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"r"   {char c='\r'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"a"   {char c='\a'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)"f"   {char c='\f'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)(\")   {char c='\"'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)(\')   {char c='\''; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)(\\)   {char c='\\'; string s(1,c); str1=str1+s; str2=str2+string(yytext);}

<SL_STRING>(\\)[^\n\t\b\v\0\r\a\f\\\"\']   {char *c= yytext;string s(1,c[1]);str1=str1+s;
					  str2=str2+string(yytext);}

<SL_STRING>{NEWLINE}  {line_count += 1; 
		       fprintf(logFile,"Lexical error at line. %d ",str);
		       fprintf(logFile,"Unterminated string %s \n\n",str2.c_str());
		       str1="";
		       str2="";
		       str=0;
		       BEGIN(INITIAL);
		       error_count++;
			 }

<SL_STRING><<EOF>>    {fprintf(logFile,"Lexical error at line. %d ",str);
		       fprintf(logFile,"Unterminated string %s \n\n",str2.c_str());
		       str1="";
		       str2="";
		       str=0;
		       BEGIN(INITIAL);
		       error_count++;}


{DIGIT}+[.]{DIGIT}*[.]+[.0-9]* |
[.]+{DIGIT}+[.]+[.0-9]*	     {fprintf(logFile,"Lexical error at line. %d ",line_count);
			     fprintf(logFile,"Too many decimal point %s \n\n",yytext);
			     error_count++;}

[.][Ee]{DIGIT}+ |
{DIGIT}+[.]{DIGIT}*[Ee] |
{DIGIT}*[.]{DIGIT}+[Ee] |
{DIGIT}+[Ee][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}*[.]{DIGIT}+[eE][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}*[.]{DIGIT}+[eE][.]*[-+][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}+[.]{DIGIT}*[eE][.]*[-+][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}+[.]{DIGIT}*[eE][.]*{DIGIT}+[.]+[0-9]*         {fprintf(logFile,"Lexical error at line. %d ",line_count);
          fprintf(logFile,"Ill formed number %s \n\n",yytext);
          error_count++;}



.  {fprintf(logFile,"Lexical error at line. %d ",line_count);
    fprintf(logFile,"Unrecognized character %s \n\n",yytext);
    error_count++;}

<<EOF>> {

	symbolInfo *a=st.lookupCurrent("main");
		
	if(a==0){
		error_count++;
		fprintf(logFile,"Error at line. %d No main function found!\n",line_count-1);
	}

	//st.printAll();
	 //line_count--;
	 //fprintf(logout,"Total lines: %d\n",line_count);
	 //fprintf(logout,"Total errors: %d",error_count);
	// fprintf(logFile,"***Symbol Table***\n\n");
	// fclose(logFile);
	// st.printAll();
	// logFile=fopen("1605057_log.txt","a");
			//cout<<" Total lines: "<<line_count-1<<"\n\n";
			//cout<<" Total errors: "<<error_count<<"\n\n";
	 fprintf(logFile,"\nTotal lines: %d\n\n",line_count-1);
	 fprintf(logFile,"Total errors: %d\n\n",error_count);
	// fprintf(errorFile,"Total errors: %d\n\n",error_count);
	 return 0;}


%%
