%{
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<cstdio>
#include<string>
#include<vector>
#include<iostream>
#include<bits/stdc++.h>
#include"1605057_SymbolTable.h"

using namespace std;


int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *logFile;
FILE *errorFile;
extern char *yytext;
//  int coerr;
int err=0;
int ferr=0;
int werr=0;
//  string sif="";
symbolTable st(50);
vector<symbolInfo*>fcall;
int lref;
symbolInfo*ret=new symbolInfo();
int line_count=1;
int error_count=0;
//string s="";
vector<symbolInfo*>var_list;
vector<symbolInfo*>param;
vector<vector<symbolInfo*> >nArg;
int curr=0;
// int ccount=0;

void yyerror(const char *s)
{
	//write your code
	//fprintf(stderr,"Error at line no. %d  %s\n",line_count,s);
	fprintf(errorFile,"Error at line. %d ***%s*** at '%s'\n\n",line_count,s,yytext);
	error_count++;
}

%}

%union{
symbolInfo* symInfo;
}

%token SEMICOLON INT IF ELSE FOR WHILE DO CHAR FLOAT DOUBLE VOID RETURN DEFAULT CONTINUE COMMA
%token ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD PRINTLN INCOP DECOP BREAK SWITCH CASE
 
%token <symInfo>ID CONST_INT CONST_FLOAT ADDOP MULOP RELOP LOGICOP BITOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <symInfo> start program unit var_declaration type_specifier declaration_list 
%type <symInfo>func_declaration parameter_list expression_statement variable expression term
%type <symInfo>logic_expression rel_expression simple_expression unary_expression factor
%type <symInfo>argument_list arguments statements statement compound_statement func_definition

%%

start : program
		{
			$$=new symbolInfo();
			$$->setName($1->getName());
			//cout<<"At line no. "<<line_count-1<<" start : program \n\n"<<$$->getName()<<"\n\n";
			/*fprintf(logFile,"***Symbol Table***\n\n");
			fclose(logFile);
			st.printAll();
			logFile=fopen("log.txt","a");
			//cout<<" Total lines: "<<line_count-1<<"\n\n";
			//cout<<" Total errors: "<<error_count<<"\n\n";
			fprintf(logFile,"\nTotal lines: %d\n\n",line_count-1);
			fprintf(logFile,"Total errors: %d\n\n",error_count);
			fprintf(errorFile,"Total errors: %d\n\n",error_count);*/
		}
		;

program : unit
		{	
			$$=new symbolInfo();

			$$->setName($1->getName());

			fprintf(logFile,"At line no. %d  program : unit \n\n%s",line_count,$$->getName().c_str());
			fprintf(logFile,"\n\n");
		}
		|
program unit    {
			$$=new symbolInfo();

			$$->setName($1->getName()+"\n"+$2->getName());
			
			//cout<<"At line no. "<<line_count<<" program : program unit \n\n"<<$$->getName()<<"\n\n";
			fprintf(logFile,"At line no. %d  program : program unit \n\n%s",line_count,$$->getName().c_str());
			fprintf(logFile,"\n\n");
}
		//|program error{$$=new symbolInfo();}
		;
	
unit : 	var_declaration
		{
			$$=new symbolInfo();

			$$->setName($1->getName());
			//cout<<"At line no. "<<line_count<<" unit : var_declaration \n\n"<<$$->getName()<<"\n\n";
			fprintf(logFile,"At line no. %d unit : var_declaration \n\n%s\n\n",line_count,$$->getName().c_str());
		}
		|
func_declaration {
			$$=new symbolInfo();

			$$->setName($1->getName());
			//cout<<"At line no. "<<line_count<<" unit : func_declaration \n\n"<<$$->getName()<<"\n\n";
			fprintf(logFile,"At line no. %d unit : func_declaration \n\n%s\n\n",line_count,$$->getName().c_str());
}
		| 
func_definition {
			$$=new symbolInfo();

			$$->setName($1->getName());
			//cout<<"At line no. "<<line_count<<" unit : func_definition \n\n"<<$$->getName()<<"\n\n";
			fprintf(logFile,"At line no. %d unit : func_definition \n\n%s\n\n",line_count,$$->getName().c_str());
}
		|
error		{	$$=new symbolInfo(); 
			//yyclearin;
		}
     		;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		
		if($1->getName()=="void" && $2->getName()=="main"){

		error_count++;

		fprintf(errorFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
		}
		
		$$=new symbolInfo();

		$$->setName($1->getName()+" "+$2->getName()+"("+$4->getName()+");");
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
		
		symbolInfo* a=st.lookupCurrent($2->getName());

		if(a==0){
			bool x= st.insertCurrent($2->getName(),$1->getName(),"function");
		
			symbolInfo* b=st.lookupCurrent($2->getName());
		
			string s1;
			string s2;
			int p_num;

			p_num=param.size();

			b->f= new func();

			for(int i=0; i<p_num;i++){
			
			s1=param[i]->getName();
			s2=param[i]->getType();
			
			b->f->setList(s1);
			b->f->setType(s2);

			}param.clear();
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){

			fprintf(errorFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str());

			error_count++;
			param.clear();
		}
		else {
			if(a->getType()!=$1->getName()){

			fprintf(errorFile,"Error at line. %d Return_type mismatch \n\n",line_count);

 			error_count++;		}

			if(a->f->getNop()!=param.size()){

			fprintf(errorFile,"Error at line. %d No. of parameters mismatch \n\n",line_count);

 			error_count++;		}
			else{
	
			vector<string>p;
			p=a->f->getType();

			for(int i=0;i<param.size();i++){

			if(param[i]->getType()!=p[i]){
			fprintf(errorFile,"Error at line. %d Parameter_type mismatch \n\n",line_count); 	error_count++; break;}
			}
	    	}
		param.clear();
		}
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
		
		if($1->getName()=="void" && $2->getName()=="main"){

		error_count++;

		fprintf(errorFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
		}
		
		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName()+"();");
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());

		symbolInfo* a=st.lookupCurrent($2->getName());
		if(a==0){
			bool x= st.insertCurrent($2->getName(),$1->getName(),"function");
			symbolInfo* b=st.lookupCurrent($2->getName());
			b->f= new func();
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){
			fprintf(errorFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str()); error_count++;
		}
		else {
			if(a->getType()!=$1->getName()){
			fprintf(errorFile,"Error at line. %d Return_type mismatch \n\n",line_count); 				error_count++;}
			if(a->f->getNop()!=0){
			fprintf(errorFile,"Error at line. %d No. of parameters mismatch \n\n",line_count); 				error_count++;	}
			
		param.clear();
		}

		}
		;
func_definition : type_specifier ID LPAREN parameter_list RPAREN{

		if($1->getName()=="void" && $2->getName()=="main"){
		error_count++;
		fprintf(errorFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
		}
		//$$=new symbolInfo();
		symbolInfo *a= st.lookupCurrent($2->getName());
		if(a==0){
			bool x=st.insertCurrent($2->getName(),$1->getName(),"function");

			symbolInfo* b=st.lookupCurrent($2->getName());
		
			string s1;
			string s2;
			int p_num=param.size();

			b->f= new func();

			for(int i=0; i<p_num;i++){
			
			s1=param[i]->getName();
			s2=param[i]->getType();
			
			b->f->setList(s1);
			b->f->setType(s2);

			}
			
			b->f->setDef();
			
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){
			fprintf(errorFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str()); error_count++;
		}
		else{
			if(a->f->getDef()!=0){
				error_count++;
				fprintf(errorFile,"Error at line. %d  Multiple defination of function %s\n\n",line_count,$2->getName().c_str());
			}else{
				a->f->setDef();
				if(a->getType()!=$1->getName()){
				fprintf(errorFile,"Error at line. %d Return_type mismatch \n\n",line_count); 				error_count++;}
				if(a->f->getNop()!=param.size()){
				fprintf(errorFile,"Error at line. %d No. of parameters mismatch \n\n",line_count); 		error_count++;	}
				else{
	
				vector<string>p;

				p=a->f->getType();

				for(int i=0;i<param.size();i++){

				if(param[i]->getType()!=p[i]){
				fprintf(errorFile,"Error at line. %d Parameter_type mismatch \n\n",line_count); 	error_count++; break;}
				}
	    			}							
			}
}

} 		compound_statement {

		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName());
		//String s="";
		//s=s+$1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName();
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n%s\n\n",line_count,$$->getName().c_str());
		//$$->setName($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName());
		if($1->getName()=="void" && (ret->getType()=="int"||ret->getType()=="float")){
			fprintf(errorFile,"Error at line. %d Inside void function return expression's type mismatch \n\n",lref);error_count++;
			//fprintf(logFile,"$1->get")
		}
		else if($1->getName()!="void" && $1->getName()!="int" && (ret->getType()=="int"||ret->getType()=="void")){
			fprintf(errorFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		else if($1->getName()!="void" && $1->getName()!="float" && (ret->getType()=="float"||ret->getType()=="void")){
			fprintf(errorFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		ret->setType("");
		}
		| type_specifier ID LPAREN RPAREN{ 
		
			//$$=new symbolInfo();
			if($1->getName()=="void" && $2->getName()=="main"){

			error_count++;

			fprintf(errorFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
			}
			
			symbolInfo *a= st.lookupCurrent($2->getName());
		if(a==0){
			bool x=st.insertCurrent($2->getName(),$1->getName(),"function");
			
			symbolInfo* b=st.lookupCurrent($2->getName());

			b->f= new func();

			b->f->setDef();
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){
			fprintf(errorFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str()); error_count++;
		}
		else{
			if(a->f->getDef()!=0){
				error_count++;
				fprintf(errorFile,"Error at line. %d  Multiple defination of function %s\n\n",line_count,$2->getName().c_str());
	
			}else{
				a->f->setDef();
				if(a->getType()!=$1->getName()){
				fprintf(errorFile,"Error at line. %d Return_type mismatch \n\n",line_count); 				error_count++;}
				if(a->f->getNop()!=0){
				fprintf(errorFile,"Error at line. %d No. of parameters mismatch \n\n",line_count); error_count++;}						
			}
}


}compound_statement {

		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName()+"()"+$6->getName());
		//String s="";
		//s=s+$1->getName()+" "+$2->getName()+"()"+$6->getName();
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d func_definition : type_specifier ID LPAREN RPAREN compound_statement \n\n%s\n\n",line_count,$$->getName().c_str());
		if($1->getName()=="void" && (ret->getType()=="int"||ret->getType()=="float")){
			fprintf(errorFile,"Error at line. %d Inside void function return expression's type mismatch \n\n",lref);error_count++;
			//fprintf(logFile,"$1->get")
		}
		else if($1->getName()!="void" && $1->getName()!="int" && (ret->getType()=="int"||ret->getType()=="void")){
			fprintf(errorFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		else if($1->getName()!="void" && $1->getName()!="float" && (ret->getType()=="float"||ret->getType()=="void")){
			fprintf(errorFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		ret->setType("");
		}
 		;
 		    
var_declaration : type_specifier declaration_list SEMICOLON 
					{
						$$=new symbolInfo();
						$$->setName($1->getName()+" "+$2->getName()+";");
						//cout<<"At line no. "<<line_count<<" var_declaration : type_specifier declaration_list SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
if($1->getName()!="void"){

	for(int i = 0; i < var_list.size(); i++) {
			//bool x=st.insertCurrent(tokens[i],$1->getName());
			if(var_list[i]->getObj()=="array"){

			bool x=st.insertCurrent(var_list[i]->getName(),$1->getName(),"array");

				if(!x) {fprintf(errorFile,"Error at line. %d Multiple Declaration of %s\n\n",line_count,var_list[i]->getName().c_str());error_count++;}
				else{
					symbolInfo *a=st.lookupCurrent(var_list[i]->getName());
					a->setIdx(var_list[i]->getIdx());
				}
				
}			else{
			bool x=st.insertCurrent(var_list[i]->getName(),$1->getName(),"var");
				if(!x) {fprintf(errorFile,"Error at line. %d Multiple Declaration of %s\n\n",line_count,var_list[i]->getName().c_str());error_count++;}
			
  			}
	}
}
else {
	fprintf(errorFile,"Error at line. %d Type_specifier can't be void in var_declaration rule \n\n",line_count);error_count++;	 		
}
        		
		fprintf(logFile,"At line no. %d var_declaration : type_specifier declaration_list SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());var_list.clear();
					}		 		
				;


parameter_list  : parameter_list COMMA type_specifier ID {

		$$=new symbolInfo();
		$$->setName($1->getName()+","+$3->getName()+" "+$4->getName());
		//cout<<"At line no. "<<line_count<<" parameter_list : parameter_list COMMA type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d parameter_list : parameter_list COMMA type_specifier ID \n\n%s\n\n",line_count,$$->getName().c_str());
		for(int i=0;i<param.size();i++){
			if(param[i]->getName()==$4->getName()){
				error_count++;
				fprintf(errorFile,"Error at line. %d Redefiniton of parameter %s \n\n",line_count,$4->getName().c_str());break;
			}
		}
		if($3->getName()=="void"){
			fprintf(errorFile,"Error at line. %d Void with id %s can't be passed as parameter\n\n",line_count,$4->getName().c_str());error_count++;
		}else{
		symbolInfo* a=new symbolInfo();
		a->setName($4->getName());
		a->setType($3->getName());
		//a->setObj("var");
		param.push_back(a);
		}
		}
		| parameter_list COMMA type_specifier {
		$$=new symbolInfo();
		$$->setName($1->getName()+","+$3->getName());
		//cout<<"At line no. "<<line_count<<" parameter_list : parameter_list COMMA type_specifier \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d parameter_list : parameter_list COMMA type_specifier \n\n%s\n\n",line_count,$$->getName().c_str());
		if($3->getName()=="void"){
			fprintf(errorFile,"Error at line. %d Void must be the only parameter\n\n",line_count);error_count++;
		}else{
		symbolInfo* a=new symbolInfo();
		a->setName("");
		a->setType($3->getName());
		//a->setObj("var");
		param.push_back(a);}
}
 		| type_specifier ID {
		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName());
		//cout<<"At line no. "<<line_count<<" parameter_list : type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d parameter_list : type_specifier ID \n\n%s\n\n",line_count,$$->getName().c_str());
		if($1->getName()=="void"){
			fprintf(errorFile,"Error at line. %d Void with id %s can't be passed as parameter\n\n",line_count,$2->getName().c_str());error_count++;
		}else{
		symbolInfo* a=new symbolInfo();
		a->setName($2->getName());
		a->setType($1->getName());
		//a->setObj("var");
		param.push_back(a);}
}
		| type_specifier {
		$$=new symbolInfo();
		$$->setName($1->getName());
		//cout<<"At line no. "<<line_count<<" parameter_list : type_specifier \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d parameter_list : type_specifier \n\n%s\n\n",line_count,$$->getName().c_str());
		if($1->getName()!="void"){
		symbolInfo* a=new symbolInfo();
		a->setName("");
		a->setType($1->getName());
		//a->setObj("var");
		param.push_back(a);}
}
 		;

compound_statement : LCURL{ 

		fclose(logFile);
		st.enterScope(50);
		logFile=fopen("1605057_log.txt","a");
		
		for(int i=0;i< param.size();i++){
		bool x=st.insertCurrent(param[i]->getName(),param[i]->getType(),"var");}
		
		param.clear();
		} statements RCURL {
		
		$$=new symbolInfo();
		$$->setName("{\n"+$3->getName()+"\n}");
		//cout<<"At line no. "<<line_count<<" parameter_list : type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d compound_statement : LCURL statements RCURL \n\n%s\n\n",line_count,$$->getName().c_str());
		
		fclose(logFile);
		st.exitScope();
		logFile=fopen("1605057_log.txt","a");//ret=new symbolInfo();
}
 		    | LCURL RCURL {
 		    
		fclose(logFile);
		st.enterScope(50);
		logFile=fopen("1605057_log.txt","a");
		
		for(int i=0;i< param.size();i++){
		bool x=st.insertCurrent(param[i]->getName(),param[i]->getType(),"var");}
		
		param.clear();
		$$=new symbolInfo();
		$$->setName("{\n}");
		//cout<<"At line no. "<<line_count<<" parameter_list : type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d compound_statement : LCURL RCURL \n\n%s\n\n",line_count,$$->getName().c_str());
		
		fclose(logFile);
		st.exitScope();
		logFile=fopen("1605057_log.txt","a");
}
 		    ;

 		 
type_specifier	: INT		{
					$$=new symbolInfo();
					$$->setName("int");
					//cout<<"At line no. "<<line_count<<" type_specifier : INT \n\n"<<$$->getName()<<"\n\n";
		fprintf(logFile,"At line no. %d type_specifier : INT \n\n%s\n\n",line_count,$$->getName().c_str());
				}
				|
FLOAT				{
					$$=new symbolInfo();
					$$->setName("float");
//cout<<"At line no. "<<line_count<<" type_specifier : FLOAT \n\n"<<$$->getName()<<"\n\n";
fprintf(logFile,"At line no. %d type_specifier : FLOAT \n\n%s\n\n",line_count,$$->getName().c_str());
				}
				|
VOID				{
					$$=new symbolInfo();
					$$->setName("void");
//cout<<"At line no. "<<line_count<<" type_specifier : VOID \n\n"<<$$->getName()<<"\n\n";
fprintf(logFile,"At line no. %d type_specifier : VOID \n\n%s\n\n",line_count,$$->getName().c_str());
				}
 				;

declaration_list : declaration_list COMMA ID {
		
		$$=new symbolInfo();
		symbolInfo *a=new symbolInfo();
		
		a->setName($3->getName());
		
		var_list.push_back(a);
		
		$$->setName($1->getName()+","+$3->getName());
		
		//bool x= st.insertCurrent($3->getName(),"ID");
		
		//cout<<"At line no. "<<line_count<<" declaration_list : declaration_list COMMA ID \n\n"<<$$->getName()<<"\n\n";
fprintf(logFile,"At line no. %d declaration_list : declaration_list COMMA ID \n\n%s\n\n",line_count,$$->getName().c_str());
}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
 		  
		$$=new symbolInfo();
		symbolInfo *a=new symbolInfo();
		
		a->setName($3->getName());
		a->setObj("array");
		a->setIdx(atoi($5->getName().c_str()));
		
		var_list.push_back(a);
		
		$$->setName($1->getName()+","+$3->getName()+"["+$5->getName()+"]");
		/*symbolInfo *t=st.lookupCurrent($3->getName());
		if(t==0)
		{
		    st.insertCurrent($3->getName(),"ID");
		}*/
		//cout<<"At line no. "<<line_count<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n"<<$$->getName()<<"\n\n";
fprintf(logFile,"At line no. %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n%s\n\n",line_count,$$->getName().c_str());
}
 		  | ID {
 		  
		$$=new symbolInfo();
		symbolInfo *a=new symbolInfo();
		
		a->setName($1->getName());
		
		var_list.push_back(a);
		$$->setName($1->getName());
		/*symbolInfo *t=st.lookupCurrent($1->getName());
		if(t==0)
		{
		    st.insertCurrent($1->getName(),"ID");
		}*/
		//cout<<"At line no. "<<line_count<<" declaration_list : ID \n\n"<<$$->getName()<<"\n\n";
fprintf(logFile,"At line no. %d declaration_list : ID \n\n%s\n\n",line_count,$$->getName().c_str());
}
 		  | ID LTHIRD CONST_INT RTHIRD {

		$$=new symbolInfo();
		symbolInfo *a=new symbolInfo();
		
		a->setName($1->getName());
		a->setObj("array");
		a->setIdx(atoi($3->getName().c_str()));
		
		var_list.push_back(a);
		$$->setName($1->getName()+"["+$3->getName()+"]");
		/*symbolInfo *t=st.lookupCurrent($1->getName());
		if(t==0)
		{
		    st.insertCurrent($1->getName(),"ID");
		}*/
		//cout<<"At line no. "<<line_count<<" declaration_list : ID LTHIRD CONST_INT RTHIRD \n\n"<<$$->getName()<<"\n\n";
fprintf(logFile,"At line no. %d declaration_list : ID LTHIRD CONST_INT RTHIRD \n\n%s\n\n",line_count,$$->getName().c_str());
}
 		  ;

statements : statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName());
		
fprintf(logFile,"At line no. %d statements : statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	   | 
statements statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName()+"\n"+$2->getName());
		
fprintf(logFile,"At line no. %d statements : statements statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	   ;
	   
statement : var_declaration {

		$$=new symbolInfo();
		
		$$->setName($1->getName());
		//err=line_count;
fprintf(logFile,"At line no. %d statement : var_declaration \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | 
expression_statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName());
		//err=line_count;
fprintf(logFile,"At line no. %d statement : expression_statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | 
compound_statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName());
		
fprintf(logFile,"At line no. %d statement : compound_statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
	  
		$$=new symbolInfo();
		
		$$->setName("for("+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName());
		/*if($3->getType()!="SEMICOLON" && $3->getType()!="int" && $3->getType()!="float"){
			error_count++;
			fprintf(errorFile,"Error at line. %d Invalid expression inside for()\n\n",ferr);
		}*/
		if($4->getType()!="SEMICOLON" && $4->getType()!="int" && $4->getType()!="float"){
			error_count++;
			fprintf(errorFile,"Error at line. %d Invalid expression inside for()\n\n",ferr);
		}
		/*else if($5->getType()!="int" && $5->getType()!="float"){
			error_count++;
			fprintf(errorFile,"Error at line. %d Invalid expression inside for()\n\n",ferr);
		}*/
fprintf(logFile,"At line no. %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		$$=new symbolInfo();
		//coerr=err;
		$$->setName("if("+$3->getName()+") "+$5->getName());

		if($3->getType()!="int" && $3->getType()!="float"){
			fprintf(errorFile,"Error at line. %d Invalid expression if(%s)\n\n",err,$3->getName().c_str());
			error_count++;
		}
		
fprintf(logFile,"At line no. %d statement : IF LPAREN expression RPAREN statement \n\n%s\n\n",line_count,$$->getName().c_str());
		//coerr=err;//err=0;
}
	  | IF LPAREN expression RPAREN statement ELSE statement {
	  
		$$=new symbolInfo();
		$$->setName("if("+$3->getName()+") "+$5->getName()+"\nelse "+$7->getName());
		
		if($3->getType()!="int" && $3->getType()!="float"){
			fprintf(errorFile,"Error at line. %d Invalid expression if(%s)\n\n",err,$3->getName().c_str());
			error_count++;
		}
		
fprintf(logFile,"At line no. %d statement : IF LPAREN expression RPAREN statement ELSE statement \n\n%s\n\n",line_count,$$->getName().c_str());
		
}
	  | WHILE LPAREN expression RPAREN statement {
	  
		$$=new symbolInfo();
		$$->setName("while("+$3->getName()+") "+$5->getName());

		if($3->getType()!="int" && $3->getType()!="float"){
			fprintf(errorFile,"Error at line. %d Invalid expression inside while()\n\n",werr);
			error_count++;
		}
		
fprintf(logFile,"At line no. %d statement : WHILE LPAREN expression RPAREN statement \n\n%s\n\n",line_count,$$->getName().c_str());
		
}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		$$=new symbolInfo();
		$$->setName("println("+$3->getName()+");");
		
fprintf(logFile,"At line no. %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | RETURN expression SEMICOLON {
		$$=new symbolInfo();
		$$->setName("return "+$2->getName()+";");
		lref=line_count;
		ret->setType($2->getType());
//fprintf(logFile,"%s\n",$2->getType().c_str());
//fprintf(logFile,"%s\n",ret->getType().c_str());
fprintf(logFile,"At line no. %d statement : RETURN expression SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | error {$$=new symbolInfo();
	   // yyclearin;
}
	  //| error RCURL     {$$=new symbolInfo();}
	  ;

expression_statement 	: SEMICOLON {

	$$=new symbolInfo();
	
	$$->setName(";");
	
	$$->setType("SEMICOLON");
		
fprintf(logFile,"At line no. %d expression_statement : SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}			
			| 
expression SEMICOLON {

	$$=new symbolInfo();
	
	$$->setName($1->getName()+";");
	
	$$->setType($1->getType());
		
fprintf(logFile,"At line no. %d expression_statement : expression SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}			
			;
	  
variable : ID {
	$$=new symbolInfo();
	
	$$->setType("int");
	
	symbolInfo* a=st.lookupCurrent($1->getName());
	
	if(a==0){
		fprintf(errorFile,"Error at line. %d Undeclared Variable %s\n\n",line_count,$1->getName().c_str());
		
		 error_count++;
}
	else if(a!=0 && a->getObj()!="var"){
		fprintf(errorFile,"Error at line. %d '%s' not a variable type \n\n",line_count,$1->getName().c_str());
		
		 error_count++;
}
	else $$->setType(a->getType());
	
	$$->setName($1->getName());
		
fprintf(logFile,"At line no. %d variable : ID \n\n%s \n\n",line_count,$$->getName().c_str());
}				
	 | 
ID LTHIRD expression RTHIRD {

	$$=new symbolInfo();
	
	$$->setType("int");
	
	symbolInfo* a=st.lookupCurrent($1->getName());
	
	if(a==0){
		fprintf(errorFile,"Error at line. %d Undeclared array used %s\n\n",line_count,$1->getName().c_str());
		
		 error_count++;
}
	else if(a!=0 && a->getObj()!="array"){
		fprintf(errorFile,"Error at line. %d '%s' not an array type\n\n",line_count,$1->getName().c_str());
		
		 error_count++;
}
	else $$->setType(a->getType());

	$$->setName($1->getName()+"["+$3->getName()+"]");
	
	if($3->getType()!="int"){
		error_count++;
		//if($3->getType()=="float") 
		fprintf(errorFile,"Error at line. %d Non-integer array index\n\n",line_count);
		//else fprintf(errorFile,"Error at line. %d Missing array index\n\n",line_count); 
	}
		
fprintf(logFile,"At line no. %d variable : ID LTHIRD expression RTHIRD \n\n%s \n\n",line_count,$$->getName().c_str());
}	
	 ;
	 
 expression : logic_expression	{
 
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());
	//err=line_count;	
fprintf(logFile,"At line no. %d expression : logic_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	
	   | 
variable ASSIGNOP logic_expression {//err=line_count;

	$$=new symbolInfo();
	
	$$->setName($1->getName()+"="+$3->getName());
	
	$$->setType($1->getType());
	
	symbolInfo *a=st.lookupCurrent($1->getName());
	
	if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else if(a!=0){
		$$->setType($1->getType());
		
		if(a->getType()!=$3->getType()){
			fprintf(errorFile,"Error at line. %d Type mismatch between the two sides of ASSIGNOP\n\n",line_count);
			error_count++;
		}
	}
		
fprintf(logFile,"At line no. %d expression : variable ASSIGNOP logic_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}		
	   ;
			
logic_expression : rel_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());	
fprintf(logFile,"At line no. %d logic_expression : rel_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	 	
		 | 
rel_expression LOGICOP rel_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName()+" "+$2->getName()+" "+$3->getName());
	
	$$->setType("int");
	if($1->getType()!="int" && $1->getType()!="float"){
	
		error_count++;
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
}
	else if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
}
		
fprintf(logFile,"At line no. %d logic_expression : rel_expression LOGICOP rel_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	
		 ;
			
rel_expression	: simple_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	$$->setType($1->getType());	
	
fprintf(logFile,"At line no. %d rel_expression : simple_expression \n\n%s \n\n",line_count,$$->getName().c_str());
} 
		| 
simple_expression RELOP simple_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName()+" "+$2->getName()+" "+$3->getName());
	$$->setType("int");
	
	if($1->getType()!="int" && $1->getType()!="float"){
	
		error_count++;
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
}
	else if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
}	
fprintf(logFile,"At line no. %d rel_expression : simple_expression RELOP simple_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	
		;
				
simple_expression : term  {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());	
fprintf(logFile,"At line no. %d simple_expression : term  \n\n%s \n\n",line_count,$$->getName().c_str());
} 
		  | 
simple_expression ADDOP term {

	$$=new symbolInfo();
	$$->setName($1->getName()+$2->getName()+$3->getName());
		
fprintf(logFile,"At line no. %d simple_expression : simple_expression ADDOP term \n\n%s \n\n",line_count,$$->getName().c_str());

	if($1->getType()!="int" && $1->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		fprintf(errorFile,"Error at line. %d Invalid expression \n\n",line_count);
}
	else if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		fprintf(errorFile,"Error at line. %d Invalid expression \n\n",line_count);
}
	else if($1->getType()=="float"||$3->getType()=="float") $$->setType("float");
	
	else $$->setType("int");
	
}
		  ;
					
term :	unary_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());
		
fprintf(logFile,"At line no. %d term : unary_expression \n\n%s \n\n",line_count,$$->getName().c_str());
} 
     |  
term MULOP unary_expression {

	$$=new symbolInfo();
	$$->setName($1->getName()+$2->getName()+$3->getName());
		
fprintf(logFile,"At line no. %d term : term MULOP unary_expression \n\n%s \n\n",line_count,$$->getName().c_str());

	if($2->getName()=="%"){
	
		$$->setType("int");
		
		if($1->getType()!="int" || $3->getType()!="int"){
		error_count++;
		fprintf(errorFile,"Error at line. %d Non-integer operand on modulus operator\n\n",line_count);
		}

	}
	
	else{
		if($1->getType()!="int" && $1->getType()!="float"){
		
		error_count++;
		
		$$->setType("int");
		
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		else if($3->getType()!="int" && $3->getType()!="float"){
		
		error_count++;
		
		$$->setType("int");
		
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		else if($1->getType()!="int" || $3->getType()!="int"){
		
		$$->setType("float");
		}
		else $$->setType("int");
	}
	
	/*else if($2->getName()=="/"){
		if($1->getType()!="int" && $1->getType()!="float"){
		error_count++;$$->setType("int");
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		else if($3->getType()!="int" && $3->getType()!="float"){
		error_count++;$$->setType("int");
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		else if($1->getType()!="int" || $3->getType()!="int"){
		$$->setType("float");
		}
		else $$->setType("int");
	}*/
}
     ;

unary_expression : ADDOP unary_expression {

	$$=new symbolInfo();
	$$->setName($1->getName()+$2->getName());
	$$->setType($2->getType());
		
fprintf(logFile,"At line no. %d unary_expression : ADDOP unary_expression \n\n%s \n\n",line_count,$$->getName().c_str());
 
	if($2->getType()!="int" && $2->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
}
		 | 
NOT unary_expression {

	$$=new symbolInfo();
	
	$$->setName("!"+$2->getName());
	
	$$->setType($2->getType());
		
fprintf(logFile,"At line no. %d unary_expression : NOT unary_expression \n\n%s\n\n",line_count,$$->getName().c_str());

	if($2->getType()!="int" && $2->getType()!="float"){
	
		error_count++;$$->setType("int");
		
		fprintf(errorFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		$$->setType("int");
}
		 | 
factor {
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());
		
fprintf(logFile,"At line no. %d unary_expression : factor \n\n%s \n\n",line_count,$$->getName().c_str());
} 
		 ;
	
factor	: variable {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());
		
fprintf(logFile,"At line no. %d factor : variable \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| ID LPAREN argument_list RPAREN{
	
	$$=new symbolInfo();
	
	$$->setName($1->getName()+"("+$3->getName()+")");
	
	$$->setType("int");
	//err=line_count;
	
	symbolInfo *a=st.lookupCurrent($1->getName());
	
	if(a==0){
	
		fprintf(errorFile,"Error at line. %d No function declared as %s\n\n",line_count,$1->getName().c_str());
		
		error_count++;
	}
	else if(a!=0 && a->getObj()!="function"){
	
		fprintf(errorFile,"Error at line. %d This id is not used as a function\n\n",line_count);
		
		error_count++;
	}
	else{
		/*if(a->f->getDef()!=1){
			fprintf(errorFile,"Error at line. %d Function declared but not defined\n\n",line_count);
			error_count++;
		}*/
		//else{
			
			vector<string>p;
			
			p=a->f->getType();

			//fprintf(logFile,"curr %d \n\n",curr);
			//fprintf(logFile,"func %s called and arguments %d arglist %s\n\n",a->getName().c_str(),nArg[curr].size(),$3->getName().c_str());
			/*for(int i=0;i<nArg[curr].size();i++){
			fprintf(logFile,"%s+",nArg[curr][i]->getName().c_str());
			}*/
			/*if(p.size()==fcall.size()){
				
				int i=0;
				
				while(i<fcall.size()){             //for(int i=0;i<fcall.size();i++){
				
				string arg_str;
				
				arg_str = fcall[i]->getType();
				
				if(p[i]!=arg_str){
				
					fprintf(errorFile,"Error at line. %d Argument value doesn't match with parameter type\n\n",line_count);
					
					error_count++;break;
				}
				i++;
				}
			}*/
			if(p.size()==nArg[curr].size()){
				
				int i=0;
				
				while(i<nArg[curr].size()){             //for(int i=0;i<fcall.size();i++){
				
				string arg_str;
				
				arg_str = nArg[curr][i]->getType();
				
				if(p[i]!=arg_str){
				
					fprintf(errorFile,"Error at line. %d Argument value doesn't match with parameter type in func %s\n\n",line_count,$1->getName().c_str());
					
					error_count++;break;
				}
				i++;
				}
			}
			else{
				fprintf(errorFile,"Error at line. %d %s function call can't be done; No. of parameters mismatch\n\n",line_count,$1->getName().c_str());
				
				error_count++;
			}
		//}
		$$->setType(a->getType());
	}
	nArg.pop_back();

	curr=nArg.size()-1;
	
	//fcall.clear();	fprintf(logFile,"curr %d \n\n",curr);
	//int bidx=

	/*while(nArg[curr].size()!=0){
		nArg[curr].erase(nArg[curr].begin());
	}*/
	/*for(int i=0;i<nArg[curr].size();i++){
		nArg[curr].erase(nArg[curr].begin());i--;
	}*///curr--;

	//if(curr>0) nArg[curr].pop_back(); curr--;
	//if(curr>0) nArg[curr].erase(nArg[curr].begin(), nArg[curr].end() -1); curr--;
	//if(curr>0) curr--;
	//if(curr==0) ccount=0;
	//nArg[curr].pop_back(); //curr--;
	/*if(curr>0){
	for(int i=0;i<nArg[curr].size();i++){
	 nArg[curr].erase(nArg[curr].begin(), nArg[curr].end() -1);}
	 //curr--;
	}
	if(curr==0){
	for(int i=0;i<nArg[curr].size();i++){
	 nArg[curr].erase(nArg[curr].begin(), nArg[curr].end() -1);}
	 }
	if(curr>0) nArg[curr].pop_back(); curr--;
	 if(curr==0) nArg[curr].pop_back(); */

	/*if(curr>=0) {
	nArg[curr].pop_back(); 
	//if(curr>0) curr--;
	}*/
	/*if(curr==0){
		//nArg[0].pop_back();
		if(nArg[0].size()>0) nArg[0].erase(nArg[0].begin(), nArg[0].end() -1);
		//ccount=
	}*/
	
	
fprintf(logFile,"At line no. %d factor : ID LPAREN argument_list RPAREN \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| LPAREN expression RPAREN{
	
	$$=new symbolInfo();
	
	$$->setName("("+$2->getName()+")");
	
	$$->setType($2->getType());
		
fprintf(logFile,"At line no. %d factor : LPAREN expression RPAREN \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| CONST_INT {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType("int");	
fprintf(logFile,"At line no. %d factor : CONST_INT \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| CONST_FLOAT {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType("float");	
fprintf(logFile,"At line no. %d factor : CONST_FLOAT \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| variable INCOP {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName()+"++");
	
	$$->setType($1->getType());
		
fprintf(logFile,"At line no. %d factor : variable INCOP \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| variable DECOP {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName()+"--");
	
	$$->setType($1->getType());
		
fprintf(logFile,"At line no. %d factor : variable DECOP \n\n%s \n\n",line_count,$$->getName().c_str());
}
	;
	
argument_list : arguments{

	$$=new symbolInfo();
	
	$$->setName($1->getName());
		
fprintf(logFile,"At line no. %d argument_list : arguments \n\n%s\n\n",line_count,$$->getName().c_str());
}
		| 
%empty	{  
	$$=new symbolInfo(); 

	nArg.push_back(vector<symbolInfo*>());

	curr=nArg.size()-1;

	 //curr++;
	
	 //if(ccount==1) curr++;

	 //ccount=1;

	 $$->setName("");

fprintf(logFile,"At line no. %d argument_list :  \n\n",line_count);}
			  ;
	
arguments : arguments COMMA logic_expression{

	$$=new symbolInfo();
	
	$$->setName($1->getName()+","+$3->getName());
	
	symbolInfo *a= new symbolInfo();
	
	a->setName($3->getName());
	
	a->setType($3->getType());
	
	a->setObj($3->getObj());	
fprintf(logFile,"At line no. %d arguments : arguments COMMA logic_expression \n\n%s\n\n",line_count,$$->getName().c_str());

	//fcall.push_back(a);fprintf(logFile,"%d \n\n",curr);

	nArg[curr].push_back(a);
}
	      | 
logic_expression{

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	symbolInfo *a= new symbolInfo();
	
	a->setName($1->getName());
	
	a->setType($1->getType());
	
	a->setObj($1->getObj());
	
	//fcall.push_back(a);

	//fprintf(logFile,"ccount %d \n\n",ccount);
	//if(ccount==1){ curr++;}//fprintf(logFile,"%d \n\n",curr);
	//curr++;
	//nArg[curr].push_back(a); fprintf(logFile,"curr %d \n\n",curr);
	
	//nArg.push_back(fcall);
	//ccount=1;
	
	nArg.push_back(vector<symbolInfo* >());

	curr=nArg.size()-1;

	nArg[curr].push_back(a);
		
fprintf(logFile,"At line no. %d arguments : logic_expression \n\n%s\n\n",line_count,$$->getName().c_str());
	
}
	      ;

%%
int main(int argc,char *argv[])
{

	if((yyin=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	logFile=fopen("1605057_log.txt","w");
	errorFile=fopen("1605057_error.txt","w");

	//yyin=fp;
	yyparse();
	fclose(yyin);
	fclose(logFile);
	fclose(errorFile);

	return 0;
}

