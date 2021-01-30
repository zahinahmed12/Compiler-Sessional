%{
#include<sstream>
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

FILE *asm_code;
FILE *op_asm;
 //FILE *errorFile;
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

vector<string> all_variable;
vector<string> some_var;
vector<symbolInfo*> array_with_idx;

string function_name="";

void yyerror(const char *s)
{
	//write your code
	//fprintf(stderr,"Error at line no. %d  %s\n",line_count,s);
	fprintf(logFile,"Error at line. %d ***%s*** at '%s'\n\n",line_count,s,yytext);
	error_count++;
}

int labelCount=0;
int tempCount=0;


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

void optimized_asm(FILE *asm_code){

	vector<string>str_lines;
	ssize_t code_line;
	size_t length=0;
	char *lines;
	lines=NULL;

	while((code_line=getline( &lines, &length, asm_code))!=-1)
	{
		str_lines.push_back(string(lines));
	
	}
	/*for(int i=0;i<str_lines.size();i++){
		printf("%s%d\n",str_lines[i].c_str(),str_lines[i].size());
	}*/

	int vec_size=str_lines.size();
	
	bool arr[vec_size];

	int i=0;
	while(i<vec_size){

		arr[i]=true;
		i++;
	}

	int j=0;
	while(j<vec_size-1){

		string line1="";
		string line2="";

		line1=str_lines[j];
		line2=str_lines[j+1];

		if(str_lines[j].size()!=str_lines[j+1].size() || str_lines[j].size()<8 || str_lines[j+1].size()<8){
			
			//arr[j]=true;
			//arr[j+1]=true;
			//continue;
		}

		else if(line1.size()>=7 && (line1[4]!='M' || line1[5]!='O' || line1[6]!='V')){
			//arr[j]=true;
			//arr[j+1]=true;
			//continue;
		}
		else if(line2.size()>=7 && (line2[4]!='M' || line2[5]!='O' || line2[6]!='V')){
			//arr[j]=true;
			//arr[j+1]=true;
			//continue;
		}
		//arr[i]=true;

		else{
			string f1="";
			string f2="";
			//string l1="";
			//string l2="";
			
			for(int i=4;i<line1.size()-1;i++){
				f1.push_back(line1[i]);
			}
			for(int i=4;i<line2.size()-1;i++){
				f2.push_back(line2[i]);
			}
			string p11="";
			string p12="";
			string p21="";
			string p22="";

			string w1;
			string w2;

			vector<string>tokens1;
			vector<string>tokens2;
		
			stringstream check1(f1);
			//stringstream check1(f2);

			while(getline(check1,w1,' ')){
				tokens1.push_back(w1);
			}
			p11=tokens1[0];
			p12=tokens1[1];

			stringstream check2(f2);

			while(getline(check2,w2,' ')){
				tokens2.push_back(w2);
			}
			p21=tokens2[0];
			p22=tokens2[1];


			string nw1;
			string nw2;

			vector<string>part1;
			vector<string>part2;
		
			stringstream check3(p12);
			//stringstream check1(f2);

			while(getline(check3,nw1,',')){
				part1.push_back(nw1);
			}
			//p11=tokens1[0];
			//p12=tokens1[1];

			stringstream check4(p22);

			while(getline(check4,nw2,',')){
				part2.push_back(nw2);
			}
			//p21=tokens2[0];
			//p22=tokens2[1];

			//char ca1[]=p11;
			//int c1=strcmp(p11,"MOV");
			//int c2=strcmp(p11,p21);
			//int c3=strcmp(part1[0],part2[1]);
			//int c4=strcmp(part1[1],part[0]);

			/*int c1=p11.compare("MOV");
			int c2=p11.compare(p21);
			int c3=part1[0].compare(part2[1]);
			int c4=part1[1].compare(part2[0]);


			if(!c1 && !c2 && !c3 && !c4){
				arr[j]=true;
				arr[j+1]=false;
			}*/
//printf("dunno %s,%s,%s,%s,%s,%s\n",p11.c_str(),p21.c_str(),part1[0].c_str(),part2[1].c_str(),part1[1].c_str(),part2[0].c_str());
			if(p11=="MOV" && p11==p21 && part1[0]==part2[1] && part1[1]==part2[0]){
				//arr[j]=true;
				arr[j+1]=false;
//printf("yess %s,%s,%s,%s,%s,%s\n",p11.c_str(),p21.c_str(),part1[0].c_str(),part2[1].c_str(),part1[1].c_str(),part2[0].c_str());
			}
			else{
				//arr[j]=true;
				//arr[j+1]=true;
//printf("noo %s,%s,%s,%s,%s,%s\n",p11.c_str(),p21.c_str(),part1[0].c_str(),part2[1].c_str(),part1[1].c_str(),part2[0].c_str());
			}
		}
		j++;
	}
	for(int i=0;i<vec_size;i++){

		if(arr[i]==true){
			fprintf(op_asm,"%s",str_lines[i].c_str());
		}
	}
	fclose(op_asm);
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

			/*symbolInfo *a=st.lookupCurrent("main");
		
			if(a==0){
				error_count++;
				fprintf(logFile,"Error at line. %d No main function found!\n",line_count);
			}*/
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

			if(error_count==0){

				string code="";

				code=code+".MODEL SMALL\n";

				code=code+".STACK 100H\n";

				code=code+".DATA\n";
				
				for(int i=0;i<all_variable.size();i++){

					code=code+all_variable[i]+" dw ?\n";
				}
				for(int i=0;i<array_with_idx.size();i++){
					
					ostringstream temp;
					temp<<array_with_idx[i]->getIdx();

					code=code+array_with_idx[i]->getName()+" dw "+temp.str()+" dup(?)\n";
				}

				$1->setCode(code+".CODE\n"+$1->getCode());

				//$1->setCode($1->getCode()+"OUTDEC PROC  \n");
				
				$1->setCode($1->getCode()+"PRINT_AN_INT PROC  \n");

				string code2="    PUSH AX\n";
				code2=code2+"    PUSH BX\n";
				code2=code2+"    PUSH CX\n";
				code2=code2+"    PUSH DX\n";
				code2=code2+"    CMP AX,0\n";
				code2=code2+"    JGE CYCLE1\n";
				code2=code2+"    PUSH AX\n";
				code2=code2+"    MOV DL,'-'\n";
				code2=code2+"    MOV AH,2\n";
				
				code2=code2+"    INT 21H\n";
				code2=code2+"    POP AX\n";
				code2=code2+"    NEG AX\n";
				code2=code2+"    CYCLE1:\n";
				code2=code2+"    XOR CX,CX\n";
				code2=code2+"    MOV BX,10\n\n";
				code2=code2+"    REPEAT:\n";
				code2=code2+"    XOR DX,DX\n";
				code2=code2+"    DIV BX\n";
				code2=code2+"    PUSH DX\n";
				code2=code2+"    INC CX\n";
				code2=code2+"    OR AX,AX\n";
				code2=code2+"    JNE REPEAT\n\n";
				code2=code2+"    MOV AH,2\n\n";
				code2=code2+"    CYCLE2:\n";
				code2=code2+"    POP DX\n";
				code2=code2+"    OR DL,30H\n";
				code2=code2+"    INT 21H\n";
				code2=code2+"    LOOP CYCLE2\n\n";
				//code2=code2+"    JMP END_FUNC\n";
				
				//code2=code2+"    END_FUNC:\n";
				code2=code2+"    MOV AH,2\n";
				code2=code2+"    MOV DL,0DH\n";
				code2=code2+"    INT 21H\n";
				code2=code2+"    MOV DL,0AH\n";
				code2=code2+"    INT 21H\n";
				code2=code2+"    POP DX\n";
				code2=code2+"    POP CX\n";
				code2=code2+"    POP BX\n";
				code2=code2+"    POP AX\n";
				code2=code2+"    RET\n";
				code2=code2+"    PRINT_AN_INT ENDP\n\n";
				code2=code2+"END MAIN\n";

				$1->setCode($1->getCode()+code2);
				
				//fopen("1605057_code.asm","a");
				fprintf(asm_code,"%s",$1->getCode().c_str());
				fclose(asm_code);
				asm_code=fopen("1605057_code.asm","r");
				optimized_asm(asm_code);
				fclose(asm_code);
				
			}
		}
		;

program : unit
		{	
			$$=new symbolInfo();

			$$->setName($1->getName());
		
			$$->setCode($1->getCode());

			//fprintf(logFile,"At line no. %d  program : unit \n\n%s",line_count,$$->getName().c_str());
			//fprintf(logFile,"\n\n");
		}
		|
program unit    {
			$$=new symbolInfo();

			$$->setName($1->getName()+"\n"+$2->getName());
			
			$$->setCode($1->getCode()+$2->getCode());
			//cout<<"At line no. "<<line_count<<" program : program unit \n\n"<<$$->getName()<<"\n\n";
			//fprintf(logFile,"At line no. %d  program : program unit \n\n%s",line_count,$$->getName().c_str());
			//fprintf(logFile,"\n\n");
}
		//|program error{$$=new symbolInfo();}
		;
	
unit : 	var_declaration
		{
			$$=new symbolInfo();

			$$->setName($1->getName());
			
                        $$->setCode($1->getCode());

			some_var.clear();			
			//cout<<"At line no. "<<line_count<<" unit : var_declaration \n\n"<<$$->getName()<<"\n\n";
			//fprintf(logFile,"At line no. %d unit : var_declaration \n\n%s\n\n",line_count,$$->getName().c_str());
		}
		|
func_declaration {
			$$=new symbolInfo();

			$$->setName($1->getName());

			$$->setCode($1->getCode());
			//cout<<"At line no. "<<line_count<<" unit : func_declaration \n\n"<<$$->getName()<<"\n\n";
			//fprintf(logFile,"At line no. %d unit : func_declaration \n\n%s\n\n",line_count,$$->getName().c_str());
}
		| 
func_definition {
			$$=new symbolInfo();

			$$->setName($1->getName());

			$$->setCode($1->getCode());
			//cout<<"At line no. "<<line_count<<" unit : func_definition \n\n"<<$$->getName()<<"\n\n";
			//fprintf(logFile,"At line no. %d unit : func_definition \n\n%s\n\n",line_count,$$->getName().c_str());
}
		|
error		{	$$=new symbolInfo(); 
			//yyclearin;
		}
     		;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		
		if($1->getName()=="void" && $2->getName()=="main"){

		error_count++;

		fprintf(logFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
		}
		
		$$=new symbolInfo();

		$$->setName($1->getName()+" "+$2->getName()+"("+$4->getName()+");");
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
		
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

			fprintf(logFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str());

			error_count++;
			param.clear();
		}
		else {
			if(a->getType()!=$1->getName()){

			fprintf(logFile,"Error at line. %d Return_type mismatch \n\n",line_count);

 			error_count++;		}

			if(a->f->getNop()!=param.size()){

			fprintf(logFile,"Error at line. %d No. of parameters mismatch \n\n",line_count);

 			error_count++;		}
			else{
	
			vector<string>p;
			p=a->f->getType();

			for(int i=0;i<param.size();i++){

			if(param[i]->getType()!=p[i]){
			fprintf(logFile,"Error at line. %d Parameter_type mismatch \n\n",line_count); 	error_count++; break;}
			}
	    	}
		param.clear();
		}
		}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
		
		if($1->getName()=="void" && $2->getName()=="main"){

		error_count++;

		fprintf(logFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
		}
		
		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName()+"();");
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());

		symbolInfo* a=st.lookupCurrent($2->getName());
		if(a==0){
			bool x= st.insertCurrent($2->getName(),$1->getName(),"function");
			symbolInfo* b=st.lookupCurrent($2->getName());
			b->f= new func();
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){
			fprintf(logFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str()); error_count++;
		}
		else {
			if(a->getType()!=$1->getName()){
			fprintf(logFile,"Error at line. %d Return_type mismatch \n\n",line_count); 				error_count++;}
			if(a->f->getNop()!=0){
			fprintf(logFile,"Error at line. %d No. of parameters mismatch \n\n",line_count); 				error_count++;	}
			
		param.clear();
		}

		}
		;
func_definition : type_specifier ID LPAREN parameter_list RPAREN{

		if($1->getName()=="void" && $2->getName()=="main"){
			error_count++;
			fprintf(logFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
		}
		//$$=new symbolInfo();
		function_name=$2->getName();
		
		symbolInfo *a= st.lookupCurrent($2->getName());
		if(a==0){
			bool x=st.insertCurrent($2->getName(),$1->getName(),"function");

			symbolInfo* b=st.lookupCurrent($2->getName());
		
			string s1;
			string s2;
			int p_num=param.size();

			b->f= new func();

			ostringstream temp;
			//temp<<(st.currentTable->getTableId()+1);
			temp<<(st.counter+1);

			for(int i=0; i<p_num;i++){
			
				s1=param[i]->getName();
				s2=param[i]->getType();
			
				b->f->setList(s1+temp.str());
				b->f->setType(s2);

			}
			b->f->setDef();
			
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){
			fprintf(logFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str()); error_count++;
		}
		else{
			if(a->f->getDef()!=0){
				error_count++;
				fprintf(logFile,"Error at line. %d  Multiple defination of function %s\n\n",line_count,$2->getName().c_str());
			}else{
				a->f->setDef();

				if(a->getType()!=$1->getName()){
				fprintf(logFile,"Error at line. %d Return_type mismatch \n\n",line_count); 				error_count++;}
				if(a->f->getNop()!=param.size()){
				fprintf(logFile,"Error at line. %d No. of parameters mismatch \n\n",line_count); 		error_count++;	}
				else{
	
				vector<string>p;

				p=a->f->getType();

				for(int i=0;i<param.size();i++){

				if(param[i]->getType()!=p[i]){
					fprintf(logFile,"Error at line. %d Parameter_type mismatch \n\n",line_count); 	error_count++; break;}
				}
				//a->f->getList().clear();
				
				//printf("p %d\n",a->f->getNop());
				//a->f->getType().clear();
				//printf("t %d\n",a->f->getNop());
				//a->f->setNop();
				//printf("n %d\n",a->f->getNop());

				ostringstream temp;
				//temp<<(st.currentTable->getTableId()+1);
				temp<<(st.counter+1);
				a->f->remove_param();

				string s1;
			        string s2;
				
				for(int i=0;i<param.size();i++){

					s1=param[i]->getName();
					s2=param[i]->getType();
			
					a->f->setList(s1+temp.str());
					a->f->setType(s2);
				}//printf("n %d\n",a->f->getNop());

	    			}							
			}
		}

		all_variable.push_back($2->getName()+"_retn");

} 		compound_statement {

		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName());
		//String s="";
		//s=s+$1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName();
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n\n%s\n\n",line_count,$$->getName().c_str());
		//$$->setName($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+$7->getName());
		if($1->getName()=="void" && (ret->getType()=="int"||ret->getType()=="float")){
			fprintf(logFile,"Error at line. %d Inside void function return expression's type mismatch \n\n",lref);error_count++;
			//fprintf(logFile,"$1->get")
		}
		else if($1->getName()!="void" && $1->getName()!="int" && (ret->getType()=="int"||ret->getType()=="void")){
			fprintf(logFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		else if($1->getName()!="void" && $1->getName()!="float" && (ret->getType()=="float"||ret->getType()=="void")){
			fprintf(logFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		else{
			$$->setCode($2->getName()+" PROC\n");
			
			if($2->getName()=="main"){

				string code=$$->getCode();
				code=code+"    MOV AX,@DATA\n";
				code=code+"    MOV DS,AX\n";
				code=code+$7->getCode();
				code=code+"LabelReturn_"+$2->getName()+":\n";
				code=code+"    MOV AH,4CH\n";
				code=code+"    INT 21H\n";

				$$->setCode(code);
				
			}
			else{
				symbolInfo *d= st.lookupCurrent($2->getName());
				
				string code=$$->getCode();
				code=code+"    PUSH AX\n";
				code=code+"    PUSH BX\n";
				code=code+"    PUSH CX\n";
				code=code+"    PUSH DX\n";
				
				vector<string> f_parameter=d->f->getList();
				for(int i=0;i<f_parameter.size();i++){
					code=code+"    PUSH "+f_parameter[i]+"\n";
				}
				for(int i=0;i<some_var.size();i++){
					code=code+"    PUSH "+some_var[i]+"\n";
					d->f->local_var.push_back(some_var[i]);
				}//printf("%d\n",d->f->local_var.size());
				
				/*for(int i=0;i<d->f->local_var.size();i++){
					//code=code+"    PUSH "+some_var[i]+"\n";
					//d->f->local_var.push_back(some_var[i]);
					printf("%s\n",d->f->local_var[i].c_str());
				}*/
				
				code=code+$7->getCode()+"LabelReturn_"+$2->getName()+":\n";

				for(int i=some_var.size()-1;i>=0;i--){
					code=code+"    POP "+some_var[i]+"\n";
				}
				for(int i=f_parameter.size()-1;i>=0;i--){
					code=code+"    POP "+f_parameter[i]+"\n";
				}

				some_var.clear();

				code=code+"    POP DX\n";
				code=code+"    POP CX\n";
				code=code+"    POP BX\n";
				code=code+"    POP AX\n";
				code=code+"    RET\n";
				$$->setCode(code+$2->getName()+" ENDP\n");
				
			}
		}
		ret->setType("");
		}
		| type_specifier ID LPAREN RPAREN{ 
		
			//$$=new symbolInfo();
			if($1->getName()=="void" && $2->getName()=="main"){

			error_count++;

			fprintf(logFile,"Error at line. %d Main function having void type specifier\n\n",line_count);
			}
			
			function_name=$2->getName();

			symbolInfo *a= st.lookupCurrent($2->getName());
		if(a==0){
			bool x=st.insertCurrent($2->getName(),$1->getName(),"function");
			
			symbolInfo* b=st.lookupCurrent($2->getName());

			b->f= new func();

			b->f->setDef();
		}
		else if(a!=0 && (a->getObj()=="var" || a->getObj()=="array")){
			fprintf(logFile,"Error at line. %d Multiple declaration of %s \n\n",line_count,$2->getName().c_str()); error_count++;
		}
		else{
			if(a->f->getDef()!=0){
				error_count++;
				fprintf(logFile,"Error at line. %d  Multiple defination of function %s\n\n",line_count,$2->getName().c_str());
	
			}else{
				a->f->setDef();
				if(a->getType()!=$1->getName()){
				fprintf(logFile,"Error at line. %d Return_type mismatch \n\n",line_count); 				error_count++;}
				if(a->f->getNop()!=0){
				fprintf(logFile,"Error at line. %d No. of parameters mismatch \n\n",line_count); error_count++;}						
			}
		}
		all_variable.push_back($2->getName()+"_retn");

}compound_statement {

		$$=new symbolInfo();
		$$->setName($1->getName()+" "+$2->getName()+"()"+$6->getName());
		//String s="";
		//s=s+$1->getName()+" "+$2->getName()+"()"+$6->getName();
		//cout<<"At line no. "<<line_count<<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON  \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d func_definition : type_specifier ID LPAREN RPAREN compound_statement \n\n%s\n\n",line_count,$$->getName().c_str());
		if($1->getName()=="void" && (ret->getType()=="int"||ret->getType()=="float")){
			fprintf(logFile,"Error at line. %d Inside void function return expression's type mismatch \n\n",lref);error_count++;
			//fprintf(logFile,"$1->get")
		}
		else if($1->getName()!="void" && $1->getName()!="int" && (ret->getType()=="int"||ret->getType()=="void")){
			fprintf(logFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		else if($1->getName()!="void" && $1->getName()!="float" && (ret->getType()=="float"||ret->getType()=="void")){
			fprintf(logFile,"Error at line. %d Return type doesn't match with the returned value\n\n",lref);error_count++;
		}
		else{
			$$->setCode($2->getName()+" PROC\n");
			
			if($2->getName()=="main"){

				string code=$$->getCode();
				code=code+"    MOV AX,@DATA\n";
				code=code+"    MOV DS,AX\n";
				code=code+$6->getCode();
				code=code+"LabelReturn_"+$2->getName()+":\n";
				code=code+"    MOV AH,4CH\n";
				code=code+"    INT 21H\n";

				$$->setCode(code);
				
			}
			else{
				symbolInfo *d= st.lookupCurrent($2->getName());
				
				string code=$$->getCode();
				code=code+"    PUSH AX\n";
				code=code+"    PUSH BX\n";
				code=code+"    PUSH CX\n";
				code=code+"    PUSH DX\n";
				
				/*vector<string> f_parameter=d->f->getList();
				for(int i=0;i<f_parameter.size();i++){
					code=code+"    PUSH "+f_parameter[i]+"\n";
				}*/
				for(int i=0;i<some_var.size();i++){
					code=code+"    PUSH "+some_var[i]+"\n";
					d->f->local_var.push_back(some_var[i]);
				}//printf("%d\n",d->f->local_var.size());
				
				code=code+$6->getCode()+"LabelReturn_"+$2->getName()+":\n";

				for(int i=some_var.size()-1;i>=0;i--){
					code=code+"    POP "+some_var[i]+"\n";
				}
				/*for(int i=f_parameter.size();i<=0;i--){
					code=code+"    POP "+f_parameter[i]+"\n";
				}*/

				some_var.clear();

				code=code+"    POP DX\n";
				code=code+"    POP CX\n";
				code=code+"    POP BX\n";
				code=code+"    POP AX\n";
				code=code+"    RET\n";
				$$->setCode(code+$2->getName()+" ENDP\n");
				
			}
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
		//printf("%s\n",var_list[i]->getName().c_str());
			if(var_list[i]->getObj()=="array"){

			bool x=st.insertCurrent(var_list[i]->getName(),$1->getName(),"array");

				if(!x) {fprintf(logFile,"Error at line. %d Multiple Declaration of %s\n\n",line_count,var_list[i]->getName().c_str());error_count++;}
				else{
					symbolInfo *a=st.lookupCurrent(var_list[i]->getName());
					a->setIdx(var_list[i]->getIdx());

					symbolInfo *b=new symbolInfo();

					ostringstream temp;
    					temp<<st.currentTable->getTableId();
    					
					b->setName(var_list[i]->getName()+temp.str());
					b->setType(var_list[i]->getType());
					b->setObj(var_list[i]->getObj());
					b->setIdx(var_list[i]->getIdx());

					array_with_idx.push_back(b);
				}
				
}			else{
			bool x=st.insertCurrent(var_list[i]->getName(),$1->getName(),"var");
				if(!x) {fprintf(logFile,"Error at line. %d Multiple Declaration of %s\n\n",line_count,var_list[i]->getName().c_str());error_count++;
}
				else{
					ostringstream temp;
    					temp<<st.currentTable->getTableId();

					all_variable.push_back(var_list[i]->getName()+temp.str());

					some_var.push_back(var_list[i]->getName()+temp.str());
				}
			
  			}
	}
}
else {
	fprintf(logFile,"Error at line. %d Type_specifier can't be void in var_declaration rule \n\n",line_count);error_count++;	 		
}
		var_list.clear();
        		
		//fprintf(logFile,"At line no. %d var_declaration : type_specifier declaration_list SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());var_list.clear();
					}		 		
				;


parameter_list  : parameter_list COMMA type_specifier ID {

		$$=new symbolInfo();
		$$->setName($1->getName()+","+$3->getName()+" "+$4->getName());
		//cout<<"At line no. "<<line_count<<" parameter_list : parameter_list COMMA type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d parameter_list : parameter_list COMMA type_specifier ID \n\n%s\n\n",line_count,$$->getName().c_str());
		for(int i=0;i<param.size();i++){
			if(param[i]->getName()==$4->getName()){
				error_count++;
				fprintf(logFile,"Error at line. %d Redefiniton of parameter %s \n\n",line_count,$4->getName().c_str());break;
			}
		}
		if($3->getName()=="void"){
			fprintf(logFile,"Error at line. %d Void with id %s can't be passed as parameter\n\n",line_count,$4->getName().c_str());error_count++;
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
		//fprintf(logFile,"At line no. %d parameter_list : parameter_list COMMA type_specifier \n\n%s\n\n",line_count,$$->getName().c_str());
		if($3->getName()=="void"){
			fprintf(logFile,"Error at line. %d Void must be the only parameter\n\n",line_count);error_count++;
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
		//fprintf(logFile,"At line no. %d parameter_list : type_specifier ID \n\n%s\n\n",line_count,$$->getName().c_str());
		if($1->getName()=="void"){
			fprintf(logFile,"Error at line. %d Void with id %s can't be passed as parameter\n\n",line_count,$2->getName().c_str());error_count++;
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
		//fprintf(logFile,"At line no. %d parameter_list : type_specifier \n\n%s\n\n",line_count,$$->getName().c_str());
		if($1->getName()!="void"){
		symbolInfo* a=new symbolInfo();
		a->setName("");
		a->setType($1->getName());
		//a->setObj("var");
		param.push_back(a);}
}
 		;

compound_statement : LCURL{ 

		//fclose(logFile);
		st.enterScope(50);
		//logFile=fopen("1605057_log.txt","a");
		
		for(int i=0;i< param.size();i++){
			bool x=st.insertCurrent(param[i]->getName(),param[i]->getType(),"var");

			ostringstream temp;
			temp<<st.currentTable->getTableId();
			//temp<<st.counter;

			all_variable.push_back(param[i]->getName()+temp.str());
		}
		
		param.clear();
		} statements RCURL {
		
		$$=new symbolInfo();

		$$->setName("{\n"+$3->getName()+"\n}");

		$$->setCode($3->getCode());
		//cout<<"At line no. "<<line_count<<" parameter_list : type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d compound_statement : LCURL statements RCURL \n\n%s\n\n",line_count,$$->getName().c_str());
		
		//fclose(logFile);
		st.exitScope();
		//logFile=fopen("1605057_log.txt","a");//ret=new symbolInfo();
}
 		    | LCURL RCURL {
 		    
		//fclose(logFile);
		st.enterScope(50);
		//logFile=fopen("1605057_log.txt","a");
		
		for(int i=0;i< param.size();i++){
			bool x=st.insertCurrent(param[i]->getName(),param[i]->getType(),"var");

			ostringstream temp;
			temp<<st.currentTable->getTableId();

			all_variable.push_back(param[i]->getName()+temp.str());

		}
		
		param.clear();
		$$=new symbolInfo();
		$$->setName("{\n}");
		//cout<<"At line no. "<<line_count<<" parameter_list : type_specifier ID \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d compound_statement : LCURL RCURL \n\n%s\n\n",line_count,$$->getName().c_str());
		
		//fclose(logFile);
		st.exitScope();
		//logFile=fopen("1605057_log.txt","a");
}
 		    ;

 		 
type_specifier	: INT		{
					$$=new symbolInfo();
					$$->setName("int");
					//cout<<"At line no. "<<line_count<<" type_specifier : INT \n\n"<<$$->getName()<<"\n\n";
		//fprintf(logFile,"At line no. %d type_specifier : INT \n\n%s\n\n",line_count,$$->getName().c_str());
				}
				|
FLOAT				{
					$$=new symbolInfo();
					$$->setName("float");
//cout<<"At line no. "<<line_count<<" type_specifier : FLOAT \n\n"<<$$->getName()<<"\n\n";
//fprintf(logFile,"At line no. %d type_specifier : FLOAT \n\n%s\n\n",line_count,$$->getName().c_str());
				}
				|
VOID				{
					$$=new symbolInfo();
					$$->setName("void");
//cout<<"At line no. "<<line_count<<" type_specifier : VOID \n\n"<<$$->getName()<<"\n\n";
//fprintf(logFile,"At line no. %d type_specifier : VOID \n\n%s\n\n",line_count,$$->getName().c_str());
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
//fprintf(logFile,"At line no. %d declaration_list : declaration_list COMMA ID \n\n%s\n\n",line_count,$$->getName().c_str());
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
//fprintf(logFile,"At line no. %d declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n%s\n\n",line_count,$$->getName().c_str());
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
//fprintf(logFile,"At line no. %d declaration_list : ID \n\n%s\n\n",line_count,$$->getName().c_str());
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
//fprintf(logFile,"At line no. %d declaration_list : ID LTHIRD CONST_INT RTHIRD \n\n%s\n\n",line_count,$$->getName().c_str());
}
 		  ;

statements : statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName());

		$$->setCode($1->getCode());
		
//fprintf(logFile,"At line no. %d statements : statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	   | 
statements statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName()+"\n"+$2->getName());

		$$->setCode($1->getCode()+$2->getCode());
		
//fprintf(logFile,"At line no. %d statements : statements statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	   ;
	   
statement : var_declaration {

		$$=new symbolInfo();
		
		$$->setName($1->getName());
		//err=line_count;
//fprintf(logFile,"At line no. %d statement : var_declaration \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | 
expression_statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName());

		$$->setCode($1->getCode());
		//err=line_count;
//fprintf(logFile,"At line no. %d statement : expression_statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | 
compound_statement {

		$$=new symbolInfo();
		
		$$->setName($1->getName());

		$$->setCode($1->getCode());
		
//fprintf(logFile,"At line no. %d statement : compound_statement \n\n%s\n\n",line_count,$$->getName().c_str());
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
			fprintf(logFile,"Error at line. %d Invalid expression inside for()\n\n",ferr);
		}
		else{
			string code=$3->getCode();

			char *label1=newLabel();	
			char *label2=newLabel();

			code=code+string(label1)+":";
			code=code+"\n";

			code=code+$4->getCode();

			code=code+"    MOV AX,"+$4->get_id_with_scope_id();
			code=code+"\n";
			code=code+"    CMP AX,0";
			code=code+"\n";						
			code=code+"    JE "+string(label2);
			code=code+"\n";

			code=code+$7->getCode();		
			code=code+$5->getCode();

			code=code+"    JMP "+string(label1);
			code=code+"\n";				
			code=code+string(label2)+":";
			code=code+"\n";

			$$->setCode(code);
		}
		/*else if($5->getType()!="int" && $5->getType()!="float"){
			error_count++;
			fprintf(errorFile,"Error at line. %d Invalid expression inside for()\n\n",ferr);
		}*/
//fprintf(logFile,"At line no. %d statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		$$=new symbolInfo();
		//coerr=err;
		$$->setName("if("+$3->getName()+") "+$5->getName());

		if($3->getType()!="int" && $3->getType()!="float"){
			fprintf(logFile,"Error at line. %d Invalid expression if(%s)\n\n",err,$3->getName().c_str());
			error_count++;
		}
		else{
			string code=$3->getCode();

			char *label1=newLabel();	
			//char *label2=newLabel();

			//code=code+string(label1)+":";
			//code=code+"\n";

			//code=code+$3->getCode();

			code=code+"    MOV AX,"+$3->get_id_with_scope_id();
			code=code+"\n";
			code=code+"    CMP AX,0";
			code=code+"\n";						
			code=code+"    JE "+string(label1);
			code=code+"\n";

			//code=code+$7->getCode();		
			code=code+$5->getCode();

			//code=code+"    JMP "+string(label1);
			//code=code+"\n";				
			code=code+string(label1)+":";
			code=code+"\n";

			$$->setCode(code);
		}
		
//fprintf(logFile,"At line no. %d statement : IF LPAREN expression RPAREN statement \n\n%s\n\n",line_count,$$->getName().c_str());
		//coerr=err;//err=0;
}
	  | IF LPAREN expression RPAREN statement ELSE statement {
	  
		$$=new symbolInfo();
		$$->setName("if("+$3->getName()+") "+$5->getName()+"\nelse "+$7->getName());
		
		if($3->getType()!="int" && $3->getType()!="float"){
			fprintf(logFile,"Error at line. %d Invalid expression if(%s)\n\n",err,$3->getName().c_str());
			error_count++;
		}
		else{
			string code=$3->getCode();

			char *label1=newLabel();	
			char *label2=newLabel();

			//code=code+string(label1)+":";
			//code=code+"\n";

			//code=code+$3->getCode();

			code=code+"    MOV AX,"+$3->get_id_with_scope_id();
			code=code+"\n";
			code=code+"    CMP AX,0";
			code=code+"\n";						
			code=code+"    JE "+string(label1);
			code=code+"\n";

			//code=code+$7->getCode();		
			code=code+$5->getCode();

			code=code+"    JMP "+string(label2);
			code=code+"\n";				
			code=code+string(label1)+":";
			code=code+"\n";
			code=code+$7->getCode();
			//code=code+"    JMP "+string(label2);
			//code=code+"\n";				
			code=code+string(label2)+":";
			code=code+"\n";

			$$->setCode(code);
		}
//fprintf(logFile,"At line no. %d statement : IF LPAREN expression RPAREN statement ELSE statement \n\n%s\n\n",line_count,$$->getName().c_str());
		
}
	  | WHILE LPAREN expression RPAREN statement {
	  
		$$=new symbolInfo();
		$$->setName("while("+$3->getName()+") "+$5->getName());

		if($3->getType()!="int" && $3->getType()!="float"){
			fprintf(logFile,"Error at line. %d Invalid expression inside while()\n\n",werr);
			error_count++;
		}
		else{
			string code="";

			char *label1=newLabel();	
			char *label2=newLabel();

			code=code+string(label1)+":";
			code=code+"\n";

			code=code+$3->getCode();

			code=code+"    MOV AX,"+$3->get_id_with_scope_id();
			code=code+"\n";
			code=code+"    CMP AX,0";
			code=code+"\n";						
			code=code+"    JE "+string(label2);
			code=code+"\n";

			//code=code+$7->getCode();		
			code=code+$5->getCode();

			code=code+"    JMP "+string(label1);
			code=code+"\n";				
			code=code+string(label2)+":";
			code=code+"\n";

			$$->setCode(code);
		}
		
//fprintf(logFile,"At line no. %d statement : WHILE LPAREN expression RPAREN statement \n\n%s\n\n",line_count,$$->getName().c_str());
		
}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		$$=new symbolInfo();
		$$->setName("println("+$3->getName()+");");
		
		int scope_id=st.find_scope_id($3->getName());

		string code="";

		if(scope_id!=-1){
			
			ostringstream temp;
			temp<<scope_id;
			
			code=code+"    MOV AX,"+$3->getName()+temp.str()+"\n";
			code=code+"    CALL PRINT_AN_INT\n";
		}
		else{
			fprintf(logFile,"Error at line. %d Undeclared variable\n",line_count);
			error_count++;
		}
		$$->setCode(code);
		
//fprintf(logFile,"At line no. %d statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}
	  | RETURN expression SEMICOLON {
		$$=new symbolInfo();
		$$->setName("return "+$2->getName()+";");
		lref=line_count;
		ret->setType($2->getType());

		if($2->getType()!="void"){

			string code=$2->getCode();
			code=code+"    MOV AX,"+$2->get_id_with_scope_id()+"\n";
			code=code+"    MOV "+function_name+"_retn,AX\n";
			code=code+"    JMP LabelReturn_"+function_name+"\n";
			$$->setCode(code);
		}


//fprintf(logFile,"%s\n",$2->getType().c_str());
//fprintf(logFile,"%s\n",ret->getType().c_str());
//fprintf(logFile,"At line no. %d statement : RETURN expression SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
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
		
//fprintf(logFile,"At line no. %d expression_statement : SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}			
			| 
expression SEMICOLON {

	$$=new symbolInfo();
	
	$$->setName($1->getName()+";");
	
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());
		
//fprintf(logFile,"At line no. %d expression_statement : expression SEMICOLON \n\n%s\n\n",line_count,$$->getName().c_str());
}			
			;
	  
variable : ID {
	$$=new symbolInfo();
	
	$$->setType("int");
	
	symbolInfo* a=st.lookupCurrent($1->getName());
	
	if(a==0){
		fprintf(logFile,"Error at line. %d Undeclared Variable %s\n\n",line_count,$1->getName().c_str());
		
		 error_count++;
	}
	else if(a!=0 && a->getObj()!="var"){
		fprintf(logFile,"Error at line. %d '%s' not a variable type \n\n",line_count,$1->getName().c_str());
		
		 error_count++;
	}
	else{
		$$->setType(a->getType());

		int scope_id=st.find_scope_id($1->getName());
		ostringstream temp;
		temp<<scope_id;

		$$->set_id_with_scope_id($1->getName()+temp.str());
	} 
	
	$$->setName($1->getName());
		
//fprintf(logFile,"At line no. %d variable : ID \n\n%s \n\n",line_count,$$->getName().c_str());
}				
	 | 
ID LTHIRD expression RTHIRD {

	$$=new symbolInfo();
	
	$$->setType("int");
	
	symbolInfo* a=st.lookupCurrent($1->getName());
	
	if(a==0){
		fprintf(logFile,"Error at line. %d Undeclared array used %s\n\n",line_count,$1->getName().c_str());
		
		 error_count++;
	}
	else if(a!=0 && a->getObj()!="array"){
		fprintf(logFile,"Error at line. %d '%s' not an array type\n\n",line_count,$1->getName().c_str());
		
		 error_count++;
	}
	else{
		$$->setType(a->getType());

		int scope_id=st.find_scope_id($1->getName());
		ostringstream temp;
		temp<<scope_id;

		$$->set_id_with_scope_id($1->getName()+temp.str());

		if($3->getType()=="int"){

			string code=$3->getCode();
			code=code+"    MOV BX,"+$3->get_id_with_scope_id()+"\n";
			code=code+"    ADD BX,BX\n";
			$$->setCode(code);
		}
	}

	//$$->setName($1->getName()+"["+$3->getName()+"]");
	$$->setName($1->getName());
	
	if($3->getType()!="int"){
		error_count++;
		//if($3->getType()=="float") 
		fprintf(logFile,"Error at line. %d Non-integer array index\n\n",line_count);
		//else fprintf(errorFile,"Error at line. %d Missing array index\n\n",line_count); 
	}
		
//fprintf(logFile,"At line no. %d variable : ID LTHIRD expression RTHIRD \n\n%s \n\n",line_count,$$->getName().c_str());
}	
	 ;
	 
 expression : logic_expression	{
 
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());
	//err=line_count;	
//fprintf(logFile,"At line no. %d expression : logic_expression \n\n%s \n\n",line_count,$$->getName().c_str());
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
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else if(a!=0){
		$$->setType($1->getType());
		
		if(a->getType()!=$3->getType()){
			fprintf(logFile,"Error at line. %d Type mismatch between the two sides of ASSIGNOP\n\n",line_count);
			error_count++;
		}
		else{
			string code=$3->getCode();

			code=code+$1->getCode();

			code=code+"    MOV AX,"+ $3->get_id_with_scope_id();
			code=code+"\n";

			if(a->getObj()=="var"){
													
													
				code=code+"    MOV "+$1->get_id_with_scope_id()+",AX";
				code=code+"\n";
			}
			else{

				code=code+"    MOV "+$1->get_id_with_scope_id()+"[BX],AX";
				code=code+"\n";
			}
			$$->setCode(code);

			$$->set_id_with_scope_id($1->get_id_with_scope_id());

		}
	}
		
//fprintf(logFile,"At line no. %d expression : variable ASSIGNOP logic_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}		
	   ;
			
logic_expression : rel_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());	
//fprintf(logFile,"At line no. %d logic_expression : rel_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	 	
		 | 
rel_expression LOGICOP rel_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName()+" "+$2->getName()+" "+$3->getName());
	
	$$->setType("int");
	if($1->getType()!="int" && $1->getType()!="float"){
	
		error_count++;
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else{
		string code=$1->getCode();
		code=code+$3->getCode();

		char *label1=newLabel();
		char *label2=newLabel();
		//char *label3=newLabel();
		char *temp=newTemp();

		if($2->getName()=="&&"){
			
			code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"\n";
			code=code+"    CMP AX,0\n";
			code=code+"    JE "+string(label1)+"\n";
			code=code+"    MOV AX,"+$3->get_id_with_scope_id()+"\n";
			code=code+"    CMP AX,0\n";
			code=code+"    JE "+string(label1)+"\n";
			code=code+"    MOV "+string(temp)+",1\n";
			code=code+"    JMP "+string(label2)+"\n";
			code=code+string(label1)+":\n";
			code=code+"    MOV "+string(temp)+",0\n";
			code=code+string(label2)+":\n";
		}
		else{
			code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"\n";
			code=code+"    CMP AX,1\n";
			code=code+"    JE "+string(label1)+"\n";
			code=code+"    MOV AX,"+$3->get_id_with_scope_id()+"\n";
			code=code+"    CMP AX,1\n";
			code=code+"    JE "+string(label1)+"\n";
			code=code+"    MOV "+string(temp)+",0\n";
			code=code+"    JMP "+string(label2)+"\n";
			code=code+string(label1)+":\n";
			code=code+"    MOV "+string(temp)+",1\n";
			code=code+string(label2)+":\n";
		}
		all_variable.push_back(temp);
		
		$$->setCode(code);

		$$->set_id_with_scope_id(temp);
	}
		
//fprintf(logFile,"At line no. %d logic_expression : rel_expression LOGICOP rel_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	
		 ;
			
rel_expression	: simple_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());	
	
//fprintf(logFile,"At line no. %d rel_expression : simple_expression \n\n%s \n\n",line_count,$$->getName().c_str());
} 
		| 
simple_expression RELOP simple_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName()+" "+$2->getName()+" "+$3->getName());
	$$->setType("int");
	
	if($1->getType()!="int" && $1->getType()!="float"){
	
		error_count++;
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else{
		string code=$1->getCode();
		code=code+$3->getCode();
		
		code=code+"    MOV AX," + $1->get_id_with_scope_id()+"\n";
		code=code+"    CMP AX," + $3->get_id_with_scope_id()+"\n";
		char *temp=newTemp();
		char *label1=newLabel();
		char *label2=newLabel();

		if($2->getName()=="<"){
			code=code+"    JL " + string(label1)+"\n";
		}
		else if($2->getName()=="<="){
			code=code+"    JLE " + string(label1)+"\n";
		}
		else if($2->getName()==">"){
			code=code+"    JG " + string(label1)+"\n";
		}
		else if($2->getName()==">="){
			code=code+"    JGE " + string(label1)+"\n";
		}
		else if($2->getName()=="=="){
			code=code+"    JE " + string(label1)+"\n";
		}
		else{
			code=code+"    JNE " + string(label1)+"\n";
		}
				
		code=code+"    MOV "+string(temp) +",0\n";
		code=code+"    JMP "+string(label2) +"\n";
		code=code+string(label1)+":\n";
		code=code+"    MOV "+string(temp)+",1\n";
		code=code+string(label2)+":\n";

		all_variable.push_back(temp);

		$$->setCode(code);

		$$->set_id_with_scope_id(temp);
	
	}	
//fprintf(logFile,"At line no. %d rel_expression : simple_expression RELOP simple_expression \n\n%s \n\n",line_count,$$->getName().c_str());
}	
		;
				
simple_expression : term  {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());	
//fprintf(logFile,"At line no. %d simple_expression : term  \n\n%s \n\n",line_count,$$->getName().c_str());
} 
		  | 
simple_expression ADDOP term {

	$$=new symbolInfo();
	$$->setName($1->getName()+$2->getName()+$3->getName());
		
//fprintf(logFile,"At line no. %d simple_expression : simple_expression ADDOP term \n\n%s \n\n",line_count,$$->getName().c_str());

	if($1->getType()!="int" && $1->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		fprintf(logFile,"Error at line. %d Invalid expression \n\n",line_count);
	}
	else if($3->getType()!="int" && $3->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		fprintf(logFile,"Error at line. %d Invalid expression \n\n",line_count);
	}
	else{
		if($1->getType()=="float"||$3->getType()=="float") $$->setType("float");
	
		else $$->setType("int");

		string code=$1->getCode();
		code=code+$3->getCode();
		
		code=code+"    MOV AX," + $1->get_id_with_scope_id()+"\n";
		char *temp=newTemp();

		if($2->getName()=="+"){
			code=code+"    ADD AX,"+$3->get_id_with_scope_id()+"\n";
			//code=code+"    MOV "+string(temp)+",AX\n";
		}
		else{
			code=code+"    SUB AX,"+$3->get_id_with_scope_id()+"\n";
		}
		code=code+"    MOV "+string(temp)+",AX\n";

		all_variable.push_back(temp);

		$$->setCode(code);

		$$->set_id_with_scope_id(temp);
	}
	
	
}
		  ;
					
term :	unary_expression {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());
		
//fprintf(logFile,"At line no. %d term : unary_expression \n\n%s \n\n",line_count,$$->getName().c_str());
} 
     |  
term MULOP unary_expression {

	$$=new symbolInfo();
	$$->setName($1->getName()+$2->getName()+$3->getName());
		
//fprintf(logFile,"At line no. %d term : term MULOP unary_expression \n\n%s \n\n",line_count,$$->getName().c_str());

	if($2->getName()=="%"){
	
		$$->setType("int");
		
		if($1->getType()!="int" || $3->getType()!="int"){
			error_count++;
			fprintf(logFile,"Error at line. %d Non-integer operand on modulus operator\n\n",line_count);
		}
		else{
			string code=$1->getCode();
			code=code+$3->getCode();
		
			code=code+"    MOV AX," + $1->get_id_with_scope_id()+"\n";
			code=code+"    MOV BX," + $3->get_id_with_scope_id()+"\n";

			char *temp=newTemp();
			code=code+"    XOR DX,DX\n";
			code=code+"    DIV BX\n";
			code=code+"    MOV "+ string(temp) + ",DX\n";
			
			$$->setCode(code);

			$$->set_id_with_scope_id(temp);
			
			all_variable.push_back(temp);
		}

	}
	
	else{
		if($1->getType()!="int" && $1->getType()!="float"){
		
		error_count++;
		
		$$->setType("int");
		
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		else if($3->getType()!="int" && $3->getType()!="float"){
		
		error_count++;
		
		$$->setType("int");
		
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
		}
		else{
			if($1->getType()!="int" || $3->getType()!="int"){
		
				$$->setType("float");
			}
			else $$->setType("int");

			string code=$1->getCode();
			code=code+$3->getCode();
		
			code=code+"    MOV AX," + $1->get_id_with_scope_id()+"\n";
			code=code+"    MOV BX," + $3->get_id_with_scope_id()+"\n";

			char *temp=newTemp();
			
			if($2->getName()=="*"){	
				code=code+"    MUL BX\n";
				code=code+"    MOV "+ string(temp) + ",AX\n";
			}
			else{
				code=code+"    XOR DX,DX\n";
				code=code+"    DIV BX\n";
				code=code+"    MOV "+ string(temp) + ",AX\n";
			}
			$$->setCode(code);

			$$->set_id_with_scope_id(temp);

			all_variable.push_back(temp);

		}
		
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
		
//fprintf(logFile,"At line no. %d unary_expression : ADDOP unary_expression \n\n%s \n\n",line_count,$$->getName().c_str());
 
	if($2->getType()!="int" && $2->getType()!="float"){
	
		error_count++;
		$$->setType("int");
		
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else{
		string code=$2->getCode();
		if($1->getName()=="-"){
			code=code+"    MOV AX,"+$2->get_id_with_scope_id()+"\n";
			code=code+"    NEG AX\n";
			code=code+"    MOV "+$2->get_id_with_scope_id()+",AX\n";
		}
		$$->setCode(code);

		$$->set_id_with_scope_id($2->get_id_with_scope_id());
	}
}
		 | 
NOT unary_expression {

	$$=new symbolInfo();
	
	$$->setName("!"+$2->getName());
	
	$$->setType($2->getType());
		
//fprintf(logFile,"At line no. %d unary_expression : NOT unary_expression \n\n%s\n\n",line_count,$$->getName().c_str());

	if($2->getType()!="int" && $2->getType()!="float"){
	
		error_count++;$$->setType("int");
		
		fprintf(logFile,"Error at line. %d Invalid expression\n\n",line_count);
	}
	else{
		string code=$2->getCode();
		
		code=code+"    MOV AX,"+$2->get_id_with_scope_id()+"\n";
		code=code+"    NOT AX\n";
		code=code+"    MOV "+$2->get_id_with_scope_id()+",AX\n";
		
		$$->setCode(code);

		$$->set_id_with_scope_id($2->get_id_with_scope_id());
	}

	$$->setType("int");
}
		 | 
factor {
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());

	$$->setCode($1->getCode());

	$$->set_id_with_scope_id($1->get_id_with_scope_id());
		
//fprintf(logFile,"At line no. %d unary_expression : factor \n\n%s \n\n",line_count,$$->getName().c_str());
} 
		 ;
	
factor	: variable {

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType($1->getType());
		
//fprintf(logFile,"At line no. %d factor : variable \n\n%s \n\n",line_count,$$->getName().c_str());
	string code=$1->getCode();

	symbolInfo *a=st.lookupCurrent($1->getName());

	if(a!=0 && a->getObj()=="var"){

		$$->set_id_with_scope_id($1->get_id_with_scope_id());

	}
	else if(a!=0 && a->getObj()=="array"){

		char *temp=newTemp();
		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"[BX]\n";
		code=code+"    MOV "+string(temp)+",AX\n";
		
		all_variable.push_back(temp);
				
		$$->set_id_with_scope_id(temp);
//printf("%s\n",a->getName().c_str());
	}

	$$->setCode(code);
//cout<<"daf"<<$$->get_id_with_scope_id()<<' '<<$$->getName()<<' '<<boolalpha<<(a==NULL)<<"\n";
}
	| ID LPAREN argument_list RPAREN{
	
	$$=new symbolInfo();
	
	$$->setName($1->getName()+"("+$3->getName()+")");
	
	$$->setType("int");
	//err=line_count;
	
	symbolInfo *a=st.lookupCurrent($1->getName());
	
	if(a==0){
	
		fprintf(logFile,"Error at line. %d No function declared as %s\n\n",line_count,$1->getName().c_str());
		
		error_count++;
	}
	else if(a!=0 && a->getObj()!="function"){
	
		fprintf(logFile,"Error at line. %d This id is not used as a function\n\n",line_count);
		
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
			string code=$3->getCode();

			/*if(a->getName()!="main"){
			
				vector<string> param_all=a->f->getList();
				
				for(int i=0;i<param_all.size();i++){
					code=code+"    PUSH "+param_all[i]+"\n";
				}

				for(int i=0;i<a->f->local_var.size();i++){
					code=code+"    PUSH "+a->f->local_var[i]+"\n";
				}
				
			}*/
			if(p.size()==nArg[curr].size()){
				
				int i=0;
				
				while(i<nArg[curr].size()){             //for(int i=0;i<fcall.size();i++){
				
				string arg_str;
				
				arg_str = nArg[curr][i]->getType();

				vector<string> param_all2=a->f->getList();

				code=code+"    MOV AX,"+nArg[curr][i]->get_id_with_scope_id()+"\n";
				code=code+"    MOV "+param_all2[i]+",AX\n";
				
				if(p[i]!=arg_str){
				
					fprintf(logFile,"Error at line. %d Argument value doesn't match with parameter type in func %s\n\n",line_count,$1->getName().c_str());
					
					error_count++;break;
				}
			
				i++;
				}
				code=code+"    CALL "+$1->getName()+"\n";
				code=code+"    MOV AX,"+$1->getName()+"_retn"+"\n";
				char *temp=newTemp();
				code=code+"    MOV "+string(temp)+",AX\n";

				all_variable.push_back(temp);				
				$$->set_id_with_scope_id(temp);

				/*if(a->getName()!="main"){
			
				vector<string> param_all3=a->f->getList();

				for(int i=a->f->local_var.size()-1;i>=0;i--){
					code=code+"    POP "+a->f->local_var[i]+"\n";
				}
				for(int i=param_all3.size()-1;i>=0;i--){
					code=code+"    POP "+param_all3[i]+"\n";
				}
				
				}*/
				$$->setCode(code);
			}
			else{
				fprintf(logFile,"Error at line. %d %s function call can't be done; No. of parameters mismatch\n\n",line_count,$1->getName().c_str());
				
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
	
	
//fprintf(logFile,"At line no. %d factor : ID LPAREN argument_list RPAREN \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| LPAREN expression RPAREN{
	
	$$=new symbolInfo();
	
	$$->setName("("+$2->getName()+")");
	
	$$->setType($2->getType());

	$$->setCode($2->getCode());

	$$->set_id_with_scope_id($2->get_id_with_scope_id());
		
//fprintf(logFile,"At line no. %d factor : LPAREN expression RPAREN \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| CONST_INT {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType("int");

	char *temp=newTemp();

	string code="    MOV "+string(temp)+",";

	code=code+$1->getName();

	code=code+"\n";

	$$->setCode(code);

	$$->set_id_with_scope_id(temp);	

	all_variable.push_back(temp);
//fprintf(logFile,"At line no. %d factor : CONST_INT \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| CONST_FLOAT {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setType("float");

	char *temp=newTemp();

	string code="    MOV "+string(temp)+",";

	code=code+$1->getName();

	code=code+"\n";

	$$->setCode(code);

	$$->set_id_with_scope_id(temp);	

	all_variable.push_back(temp);
//fprintf(logFile,"At line no. %d factor : CONST_FLOAT \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| variable INCOP {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName()+"++");
	
	$$->setType($1->getType());

	char *temp=newTemp();

	string code="";

	symbolInfo *a=st.lookupCurrent($1->getName());

	if(a!=0 && a->getObj()=="var"){
						
		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"\n";
	}
					
	else if(a!=0 && a->getObj()=="array"){

		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"[BX]\n";
	}			

	code=code+"    MOV "+string(temp)+",AX\n";
					
	if(a!=0 && a->getObj()=="var"){

		code=code+"    INC "+$1->get_id_with_scope_id()+"\n";
	}
	else if(a!=0 && a->getObj()=="array"){

		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"[BX]\n";
						
		code=code+"    INC AX\n";
						
		code=code+"    MOV "+$1->get_id_with_scope_id()+"[BX],AX\n";
	}

	all_variable.push_back(temp);
									
	$$->setCode(code); 

	$$->set_id_with_scope_id(temp);
		
//fprintf(logFile,"At line no. %d factor : variable INCOP \n\n%s \n\n",line_count,$$->getName().c_str());
}
	| variable DECOP {
	
	$$=new symbolInfo();
	
	$$->setName($1->getName()+"--");
	
	$$->setType($1->getType());

	char *temp=newTemp();

	string code="";

	symbolInfo *a=st.lookupCurrent($1->getName());

	if(a!=0 && a->getObj()=="var"){
						
		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"\n";
	}
					
	else if(a!=0 && a->getObj()=="array"){

		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"[BX]\n";
	}			

	code=code+"    MOV "+string(temp)+",AX\n";
					
	if(a!=0 && a->getObj()=="var"){

		code=code+"    DEC "+$1->get_id_with_scope_id()+"\n";
	}
	else if(a!=0 && a->getObj()=="array"){

		code=code+"    MOV AX,"+$1->get_id_with_scope_id()+"[BX]\n";
						
		code=code+"    DEC AX\n";
						
		code=code+"    MOV "+$1->get_id_with_scope_id()+"[BX],AX\n";
	}
	all_variable.push_back(temp);
									
	$$->setCode(code); 

	$$->set_id_with_scope_id(temp);
		
//fprintf(logFile,"At line no. %d factor : variable DECOP \n\n%s \n\n",line_count,$$->getName().c_str());
}
	;
	
argument_list : arguments{

	$$=new symbolInfo();
	
	$$->setName($1->getName());

	$$->setCode($1->getCode());
		
//fprintf(logFile,"At line no. %d argument_list : arguments \n\n%s\n\n",line_count,$$->getName().c_str());
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

//fprintf(logFile,"At line no. %d argument_list :  \n\n",line_count);
}
			  ;
	
arguments : arguments COMMA logic_expression{

	$$=new symbolInfo();
	
	$$->setName($1->getName()+","+$3->getName());
	
	$$->setCode($1->getCode()+$3->getCode());
	
	symbolInfo *a= new symbolInfo();
	
	a->setName($3->getName());
	
	a->setType($3->getType());
	
	a->setObj($3->getObj());

	a->set_id_with_scope_id($3->get_id_with_scope_id());	
//fprintf(logFile,"At line no. %d arguments : arguments COMMA logic_expression \n\n%s\n\n",line_count,$$->getName().c_str());

	//fcall.push_back(a);fprintf(logFile,"%d \n\n",curr);

	nArg[curr].push_back(a);
}
	      | 
logic_expression{

	$$=new symbolInfo();
	
	$$->setName($1->getName());
	
	$$->setCode($1->getCode());
	
	symbolInfo *a= new symbolInfo();
	
	a->setName($1->getName());
	
	a->setType($1->getType());
	
	a->setObj($1->getObj());

	a->set_id_with_scope_id($1->get_id_with_scope_id());
	
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
		
//fprintf(logFile,"At line no. %d arguments : logic_expression \n\n%s\n\n",line_count,$$->getName().c_str());
	
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
	//errorFile=fopen("1605057_error.txt","w");

	asm_code=fopen("1605057_code.asm","w");
	op_asm=fopen("1605057_optimized_code.asm","w");

	//yyin=fp;
	yyparse();
	fclose(yyin);
	fclose(logFile);
	//fclose(errorFile);

	return 0;
}

