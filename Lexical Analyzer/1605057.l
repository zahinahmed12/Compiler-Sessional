%option noyywrap

%x ML_COMMENT
%x TL_COMMENT
%x SL_STRING

%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include<iostream>
#include<bits/stdc++.h>

using namespace std;

int line_count=1;
int comment=0;
int comment2=0;
int error_count=0;
string cmnt="";
string cmnt2="";
string str1="";
string str2="";
int str=0;


FILE *logout;
FILE *tokenout;

class symbolInfo
{
    string nameOfSymbol;
    string typeOfSymbol;
public:

    symbolInfo *next;
    symbolInfo()
    {
        next=0;
    }
    void setName(string a)
    {
        nameOfSymbol=a;
    }
    void setType(string b)
    {
        typeOfSymbol=b;
    }
    string getName()
    {
       return nameOfSymbol;
    }
    string getType()
    {
       return typeOfSymbol;
    }
};
class scopeTable
{
    int tableId;
    int tablesize;
public:

    scopeTable *parentScope;
    symbolInfo **arr;

    scopeTable(int n)
    {
        tableId=0;
        parentScope=0;
        tablesize=n;
        arr = new symbolInfo*[tablesize];

        for(int i=0;i<tablesize;i++)
        {
            arr[i]=0;
        }
    }

    void setTablesize(int n)
    {
        tablesize=n;
    }
    int getTablesize()
    {
        return tablesize;
    }
    void setTableId(int n)
    {
        tableId=n;
    }
    int getTableId()
    {
        return tableId;
    }

    long long hashFunction(string str)
    {
        const int m= 1e9+9;
        const int p=31;
        long long hashVal=0;
        long long powerOfP=1;
        int len=str.size();

        for(int i=0;i<len;i++)
        {
            hashVal=(hashVal + (str[i]-'a'+1)* powerOfP) % m;
            powerOfP=(powerOfP * p)%m;
        }
        return hashVal;
    }

    bool insert1(string s1, string s2)
    {
        long long int a =hashFunction(s1);
        int index = abs(a % tablesize);

        symbolInfo*l=lookup1(s1);
        if(l==0)
        {
            if(arr[index]==0)
            {
                symbolInfo *p=new symbolInfo();
                p->setName(s1);
                p->setType(s2);
                arr[index]=p;
                p->next=0;
                //cout<<" Inserted in ScopeTable# "<<getTableId()<<" at position "<<index<< ", 0" <<endl;
                return true;
            }
            else
            {
                int c=0;
                symbolInfo *t=arr[index];
                while(t->next!=0)
                {
                    t=t->next;
                    c++;
                }
                symbolInfo *p=new symbolInfo();
                p->setName(s1);
                p->setType(s2);
                t->next=p;
                p->next=0;
                //cout<<" Inserted in ScopeTable# "<<getTableId()<<" at position "<<index<< ", "<<c+1<<endl;
                c=0;
                return true;
            }
        }
        else
        {
                //cout<<" < "<<l->getName()<<" , "<<l->getType()<<" > already exists in current ScopeTable." << endl;
                return false;
        }
    }

    bool delete1(string str)
    {
        long long int a=hashFunction(str);
        int index=abs(a% tablesize);

        symbolInfo *l=lookup1(str);
        if(l!=NULL)
        {
            int c=0;
            symbolInfo* p=arr[index];
            symbolInfo *prev;
            while (p != 0)
            {
                if (p->getName() == str)
                {
                    break ;
                }
                prev = p;
                p = p->next ;
                c++;
            }
            //if (p == 0) return NULL_VALUE ; //item not found to delete
            if (p == arr[index]) //delete the first node
            {
                arr[index] = arr[index]->next ;
                delete p;
            }
            else
            {
                prev->next = p->next ;
                delete p;
            }

            //cout<<endl;
            //cout <<" Deleted entry at "<<index<<" , "<<c<<" from current ScopeTable."<<endl;
            c=0;
            return true;
        }
        //cout <<str<<" not found."<<endl;
        return false;

    }
    symbolInfo* lookup1(string str)
    {
        long long int a=hashFunction(str);
        int index=abs(a% tablesize);

        if(arr[index]==0)
        {
            //cout << " Not Found "<<str<<" in ScopeTable# "<<getTableId()<<endl<<endl;
            return 0;
        }
        else
        {
            int counter=0;
            symbolInfo *p = arr[index];
            while(p!=0)
            {
                if(p->getName()==str)
                {
                    //cout<< " Found "<<str<<" in ScopeTable# "<< getTableId()<<" at posiiton "<<index<<" , "<<counter<<endl<<endl;
                    counter=0;
                    return p;
                }
                p=p->next;
                counter++;
            }
            counter=0;
            //cout << " Not Found "<<str<<" in ScopeTable# "<<getTableId()<<endl<<endl;
            return 0;
        }
    }
    void print1()
    {
        for(int i=0;i<tablesize;i++)
        {
            symbolInfo * temp;
            temp = arr[i];
	    if(temp!=0) fprintf(logout," %d --> ",i);
            while(temp!=0)
            {
                fprintf(logout, "< %s : %s >    ",temp->getName().c_str(),temp->getType().c_str());
                temp = temp->next;
            }
	    temp = arr[i];
	    if(temp!=0) fprintf(logout,"\n");
        }
    }

    ~scopeTable()
    {
        if(arr)
        {
            for(int i=0;i<tablesize;i++)
            {
                delete []arr[i];
            }
            delete[] arr;
            arr=0;

        }
        if(parentScope)
        {
            delete[] parentScope;
            parentScope=0;
        }
    }
};

class symbolTable
{
public:
    int counter;
    scopeTable *currentTable;
    symbolTable(int n)
    {
        counter =0;
        currentTable = 0;
	scopeTable * newScope = new scopeTable(n);
        newScope->parentScope = currentTable;
        counter++;
        newScope->setTableId(counter);
        //printf(" New ScopeTable with id %d created\n\n",counter);
        currentTable = newScope;
    }

    void enterScope(int n)
    {
        scopeTable * newScope = new scopeTable(n);
        newScope->parentScope = currentTable;
        counter++;
        newScope->setTableId(counter);
        //printf(" New ScopeTable with id %d created\n\n",counter);
        currentTable = newScope;

    }
    void exitScope()
    {
        if(currentTable==0)
        {
            //cout <<"There's no ScopeTable currently."<<endl<<endl;
            return ;
        }
        /*if(currentTable->getTableId()==1)
        {

        }*/
        //printf(" ScopeTable with id %d removed\n\n",currentTable->getTableId());
        currentTable=currentTable->parentScope;
        counter--;
    }
    bool insertCurrent(string a, string b)
    {
        if(currentTable==0)
        {
            //cout <<"You need to create a ScopeTable first."<<endl<<endl;
            return false;
        }
        bool x= currentTable->insert1(a,b);
        return x;
    }
    bool deleteCurrent(string a)
    {
        if(currentTable==0)
        {
            //cout <<"There's no ScopeTable currently to delete this entry from."<<endl<<endl;
            return false;
        }
        bool x = currentTable->delete1(a);
        return x;
    }
    symbolInfo* lookupCurrent(string s)
    {
        if(currentTable==0)
        {
            //cout <<"There's no ScopeTable currently to search this entry from."<<endl<<endl;
            return 0;
        }
        symbolInfo* x=currentTable->lookup1(s);
        if(x==0)
        {
            scopeTable *y=currentTable;
            while(y->parentScope !=0)
            {
                y = y->parentScope;
                symbolInfo* x=y->lookup1(s);
                if(x!=0) return x;
            }
            if(y->parentScope==0) return 0;
        }
        else return x;

    }
    void printCurrent()
    {
        if(currentTable==0)
        {
            //cout <<"There's no ScopeTable currently."<<endl<<endl;
            return ;
        }
        fprintf(logout,"\n ScopeTable # %d\n\n",currentTable->getTableId());
        currentTable->print1();
        cout<<endl;
	fprintf(logout,"\n");
    }
    void printAll()
    {
        if(currentTable==0)
        {
            //cout <<"There's no ScopeTable currently."<<endl<<endl;
            return ;
        }
        scopeTable *y=currentTable;
        while(y!=0)
        {
            fprintf(logout,"\n ScopeTable # %d\n\n",y->getTableId());
            y->print1();
            cout << endl;
	    fprintf(logout,"\n");
            y=y->parentScope;

        }
    } 

};

symbolTable st(7);

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n


%%

{WHITESPACE} {}

{NEWLINE} {line_count++;}

"if"	{
			fprintf(tokenout,"<IF> ");
			fprintf(logout,"\nLine no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE> ");
			fprintf(logout,"\nLine no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}
"for"	{
			fprintf(tokenout,"<FOR> ");
			fprintf(logout,"\nLine no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}
"while"	{
			fprintf(tokenout,"<WHILE> ");
			fprintf(logout,"\nLine no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}
"do"	{
			fprintf(tokenout,"<DO> ");
			fprintf(logout,"\nLine no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}
"break"	{
			fprintf(tokenout,"<BREAK> ");
			fprintf(logout,"\nLine no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}
"int"	{
			fprintf(tokenout,"<INT> ");
			fprintf(logout,"\nLine no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}
"char"	{
			fprintf(tokenout,"<CHAR> ");
			fprintf(logout,"\nLine no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}
"float"	{
			fprintf(tokenout,"<FLOAT> ");
			fprintf(logout,"\nLine no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}
"double"	{
			fprintf(tokenout,"<DOUBLE> ");
			fprintf(logout,"\nLine no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}
"void"	{
			fprintf(tokenout,"<VOID> ");
			fprintf(logout,"\nLine no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}
"return"	{
			fprintf(tokenout,"<RETURN> ");
			fprintf(logout,"\nLine no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		}
"switch"	{
			fprintf(tokenout,"<SWITCH> ");
			fprintf(logout,"\nLine no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
		
"case"	{
			fprintf(tokenout,"<CASE> ");
			fprintf(logout,"\nLine no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}
		
"default"	{
			fprintf(tokenout,"<DEFAULT> ");
			fprintf(logout,"\nLine no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
		
"continue"	{
			fprintf(tokenout,"<CONTINUE> ");
			fprintf(logout,"\nLine no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}

"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s> ", yytext);
			fprintf(logout,"\nLine no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
			
		}
"*"		|

"/"		|

"%"		{
			fprintf(tokenout,"<MULOP, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			
		}
"++"		|

"--"		{
			fprintf(tokenout,"<INCOP, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
			
		}
"<" 		|  
"<="		|
">"		|
">="		|
"=="		|
"!="		{
			fprintf(tokenout,"<RELOP, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
			
		}
"="		{
			fprintf(tokenout,"<ASSIGNOP, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			
		}
"&&"		|

"||"		{
			fprintf(tokenout,"<LOGICOP, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
			
		}
"&" 		|  
"|"		|
"^"		|
">>"		|
"<<"		{
			fprintf(tokenout,"<BITOP, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);
			
		}
"!"		{
			fprintf(tokenout,"<NOT, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
			
		}
"("		{
			fprintf(tokenout,"<LPAREN, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
			
		}
")"		{
			fprintf(tokenout,"<RPAREN, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
			
		}
"{"		{
			fprintf(tokenout,"<LCURL, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
			
		}
"}"		{
			fprintf(tokenout,"<RCURL, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
			
		}
"["		{
			fprintf(tokenout,"<LTHIRD, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
			
		}
"]"		{
			fprintf(tokenout,"<RTHIRD, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
			
		}
","		{
			fprintf(tokenout,"<COMMA, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
			
		}
";"		{
			fprintf(tokenout,"<SEMICOLON, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			
		}

\'  		{fprintf(logout,"\nError at line_no %d: ",line_count);
	 	fprintf(logout,"Unterminated character %s\n",yytext);error_count++;}

\'\'   {fprintf(logout,"\nError at line_no %d: ",line_count);
	fprintf(logout,"Empty character constant error %s\n",yytext);
	error_count++;}



[_a-zA-Z][0-9a-zA-Z_]* {
			fprintf(tokenout,"<ID, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
			bool x= st.insertCurrent(string(yytext),"ID");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);

		}
		
{DIGIT}+ 	{
			fprintf(tokenout,"<CONST_INT, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
			bool x= st.insertCurrent(string(yytext),"CONST_INT");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
				
		}

{DIGIT}+[.]{DIGIT}*[eE][-+]{DIGIT}+ |
{DIGIT}+[.]{DIGIT}*[eE]{DIGIT}+ |
{DIGIT}+[.] |
{DIGIT}*[.]{DIGIT}+ |
{DIGIT}*[.]{DIGIT}+[eE]{DIGIT}+ |
{DIGIT}*[.]{DIGIT}+[eE][-+]{DIGIT}+ |
{DIGIT}+[Ee]{DIGIT}+   {
			fprintf(tokenout,"<CONST_FLOAT, %s> ",yytext);
			fprintf(logout,"\nLine no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_FLOAT");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
		}

\'[^\n\\\']\' 	{ char *c= yytext;
			fprintf(tokenout,"<CONST_CHAR, %c> ",c[1]);
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}

\'\\n\'		{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\n');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);
			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\t\'			{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\t');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\a\'			{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\a');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}			
\'\\f\'			{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\f');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\r\'			{
			fprintf(tokenout," CONST_CHAR, %c> ",'\r');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\b\'			{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\b');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\v\'			{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\v');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\0\'			{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\0');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\\\\'		{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\\');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\\"\'		{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\"');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
\'\\\'\'		{
			fprintf(tokenout,"<CONST_CHAR, %c> ",'\'');
			fprintf(logout,"\nLine no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,yytext);

			bool x= st.insertCurrent(string(yytext),"CONST_CHAR");
			if(x) st.printAll();
			else  fprintf(logout,"\nLexeme %s already exists in symbolTable\n",yytext);
			}
"/*"		{ comment=line_count; cmnt=cmnt+string(yytext); BEGIN(ML_COMMENT); }

<ML_COMMENT>"*/" 	{ cmnt=cmnt+string(yytext);
			  fprintf(logout,"\nLine no %d: TOKEN <COMMENT> Lexeme %s found\n",comment,cmnt.c_str()); 
			  cmnt="";
			  BEGIN(INITIAL); 
			}

<ML_COMMENT>[^*\n]+	{cmnt=cmnt+string(yytext);}
	
<ML_COMMENT>"*"		{cmnt=cmnt+string(yytext);}
		
<ML_COMMENT>"\n"	{cmnt=cmnt+string(yytext); line_count += 1; }


<ML_COMMENT><<EOF>>	{ fprintf(logout,"\nError at line_no %d: ",comment);
			  fprintf(logout,"Unterminated comment %s \n",cmnt.c_str());
			  cmnt="";
			  BEGIN(INITIAL);
			  error_count++;
			}
"//"	        {comment2=line_count; cmnt2=cmnt2+string(yytext);BEGIN(TL_COMMENT);}

<TL_COMMENT>(\\){NEWLINE}  {cmnt2=cmnt2+string(yytext); line_count += 1;}

<TL_COMMENT>{NEWLINE} 	{
		 	 fprintf(logout,"\nLine no %d: TOKEN <COMMENT> Lexeme %s found\n",comment2,cmnt2.c_str()); 
			 cmnt2="";line_count += 1; BEGIN(INITIAL);}

<TL_COMMENT>.	  {cmnt2=cmnt2+string(yytext);}

<TL_COMMENT><<EOF>>  {fprintf(logout,"\nError at line_no %d: ",comment2);
		      fprintf(logout,"Unterminated comment %s \n",cmnt2.c_str());
		      cmnt2="";
		      BEGIN(INITIAL);
		      error_count++;
		      }


[0-9]+[a-zA-Z_]+[0-9a-zA-Z_]* {fprintf(logout,"\nError at line_no %d: ",line_count);
			       fprintf(logout,"Invalid prefix on ID %s\n",yytext);
			       error_count++;}

\'((\\)*[^\n\'\\]+)*(\\\\)+\' |

\'[^\'\n][^\'\n]*[^\\\n\']\'  {fprintf(logout,"\nError at line_no %d: ",line_count);
	 	  		fprintf(logout,"Multi character constant error %s\n",yytext);
		                error_count++;}



\'[^\'\n]+  |
\'[^\'\n]*(\\)\'	{fprintf(logout,"\nError at line_no %d: ",line_count);
	 	         fprintf(logout,"Unterminated character %s\n",yytext);error_count++;}




["]		{str=line_count;str1=str1+string(yytext);
		str2=str2+string(yytext);BEGIN(SL_STRING);}

<SL_STRING>["]	{str1=str1+string(yytext);
		 str2=str2+string(yytext);
		 fprintf(tokenout,"<STRING, %s> ",str1.c_str());
	         fprintf(logout,"\nLine no %d: TOKEN <STRING> Lexeme %s found\n",str,str2.c_str()); 
		 str1="";
		 str2="";
		 str=0;
		 BEGIN(INITIAL);}

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
		       fprintf(logout,"\nError at line_no %d: ",str);
		       fprintf(logout,"Unterminated string %s \n",str2.c_str());
		       str1="";
		       str2="";
		       str=0;
		       BEGIN(INITIAL);
		       error_count++;
			 }

<SL_STRING><<EOF>>    {fprintf(logout,"\nError at line_no %d: ",str);
		       fprintf(logout,"Unterminated string %s \n",str2.c_str());
		       str1="";
		       str2="";
		       str=0;
		       BEGIN(INITIAL);
		       error_count++;}


{DIGIT}+[.]{DIGIT}*[.]+[.0-9]* |
[.]+{DIGIT}+[.]+[.0-9]*	     {fprintf(logout,"\nError at line_no %d: ",line_count);
			     fprintf(logout,"Too many decimal point %s \n",yytext);
			     error_count++;}

[.][Ee]{DIGIT}+ |
{DIGIT}+[.]{DIGIT}*[Ee] |
{DIGIT}*[.]{DIGIT}+[Ee] |
{DIGIT}+[Ee][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}*[.]{DIGIT}+[eE][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}*[.]{DIGIT}+[eE][.]*[-+][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}+[.]{DIGIT}*[eE][.]*[-+][.]*{DIGIT}+[.]+[0-9]* |
{DIGIT}+[.]{DIGIT}*[eE][.]*{DIGIT}+[.]+[0-9]*         {fprintf(logout,"\nError at line_no %d: ",line_count);
          fprintf(logout,"Ill formed number %s \n",yytext);
          error_count++;}



.  {fprintf(logout,"\nError at line_no %d: ",line_count);
    fprintf(logout,"Unrecognized character %s \n",yytext);
    error_count++;}

<<EOF>> {st.printAll();
	 line_count--;
	 fprintf(logout,"Total lines: %d\n",line_count);
	 fprintf(logout,"Total errors: %d",error_count);
	 return 0;}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1605057_log.txt","w");
	tokenout= fopen("1605057_token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
