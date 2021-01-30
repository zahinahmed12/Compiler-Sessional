#include<bits/stdc++.h>
#include<fstream>
#include<stdio.h>
#include<iostream>

using namespace std;

/*class arr
{
    int idx;
    public arr()
    {
        idx=0;
    }
    void setIdx(int a)
    {
        idx=a;
    }
    int getIdx()
    {
        return idx;
    }
}*/

class func
{
    vector<string>p_list;
    int def;
    vector<string>p_type;
    int nop;

public:

    vector<string> local_var;
    func()
    {
        nop=0;
        def=0;
    }
    /*void setNop()
    {
        nop=p_list.size();
    }*/
    void setDef()
    {
        def=1;
    }
    int getNop( )
    {
        return nop;
    }
    int getDef( )
    {
        return def;
    }
    void setList(string a)
    {
        p_list.push_back(a);
        //setNop();
        
	nop=p_list.size();
    }
    void setType(string a)
    {
        p_type.push_back(a);

    }
    vector<string> getList()
    {
        return p_list;
    }
    vector<string> getType()
    {
        return p_type;
    }
    void remove_param()
    {
	p_type.clear();
	p_list.clear();
	nop=p_list.size();
    }
        
};

class symbolInfo
{
    string nameOfSymbol;
    string typeOfSymbol;
    string obj;
    int idx;
    string code;
    string id_with_scope_id;
public:
    
    func* f;
    //arr* a;
    symbolInfo *next;
    symbolInfo()
    {
	code="";
	id_with_scope_id="";
	typeOfSymbol="";
        obj="";
        //a=0;
        f=0;
        next=0;
        idx=0;
    }
    void setName(string a)
    {
        nameOfSymbol=a;
    }
    void setType(string b)
    {
        typeOfSymbol=b;
    }
    void setObj(string c)
    {
        obj=c;
    }
    string getName()
    {
       return nameOfSymbol;
    }
    string getType()
    {
       return typeOfSymbol;
    }
    string getObj()
    {
        return obj;
    }
    void setIdx(int a)
    {
	idx=a;
    }
    int getIdx()
    {
        return idx;
    }
    void setCode(string a)
    {
	code=a;
    }
    string getCode()
    {
	return code;
    }
    void set_id_with_scope_id(string a)
    {
	id_with_scope_id=a;
    }
    string get_id_with_scope_id()
    {
	return id_with_scope_id;
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

    bool insert1(string s1, string s2, string s3)
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
                p->setObj(s3);
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
                p->setObj(s3);
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
	FILE * d=fopen("1605057_log.txt","a");
        for(int i=0;i<tablesize;i++)
        {
            symbolInfo * temp;
            temp = arr[i];
	    if(temp!=0) fprintf(d," %d --> ",i);
            while(temp!=0)
            {
                //fprintf(d, "< %s : %s >    ",temp->getName().c_str(),temp->getType().c_str());
		fprintf(d, "< %s : ID >    ",temp->getName().c_str());
                temp = temp->next;
            }
	    temp = arr[i];
	    if(temp!=0) fprintf(d,"\n");
        }
	fprintf(d,"\n");
	fclose(d);
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
    {	//FILE * d=fopen("1605057_log.txt","a");
        scopeTable * newScope = new scopeTable(n);
        newScope->parentScope = currentTable;
        counter++;
        newScope->setTableId(counter);
       // fprintf(d," New ScopeTable with id %d created\n\n",counter);
        currentTable = newScope;
	//fclose(d);
    }
    void exitScope()
    {	//printAll();
        if(currentTable==0)
        {
            cout <<"There's no ScopeTable currently."<<endl<<endl;
            return ;
        }
        /*if(currentTable->getTableId()==1)
        {

        }*/
	//FILE * d=fopen("1605057_log.txt","a");
       // fprintf(d,"\n ScopeTable with id %d removed\n\n",currentTable->getTableId());
        currentTable=currentTable->parentScope;
        //counter--;fclose(d);
	//fclose(d);
    }
    bool insertCurrent(string a, string b, string c)
    {
        if(currentTable==0)
        {
            cout <<"You need to create a ScopeTable first."<<endl<<endl;
            return false;
        }
        bool x= currentTable->insert1(a,b,c);
        return x;
    }
    bool deleteCurrent(string a)
    {
        if(currentTable==0)
        {
            cout <<"There's no ScopeTable currently to delete this entry from."<<endl<<endl;
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
            cout <<"There's no ScopeTable currently."<<endl<<endl;
            return ;
        }
        printf(" ScopeTable # %d\n\n",currentTable->getTableId());
        currentTable->print1();
        cout<<endl;
    }
    void printAll()
    {
        if(currentTable==0)
        {
	    //fclose(d);
            //cout <<"There's no ScopeTable currently."<<endl<<endl;
            return ;
        }
        scopeTable *y=currentTable;
        while(y!=0)
        {
	    FILE * d=fopen("1605057_log.txt","a");
            fprintf(d," ScopeTable # %d\n\n",y->getTableId());
	    fclose(d);
            y->print1();
            //cout << endl;
	    
            y=y->parentScope;

        }//fclose(d);
   }

   int find_scope_id(string s){

	if(currentTable==0)
        {
            //cout <<"There's no ScopeTable currently to search this entry from."<<endl<<endl;
            return -1;
        }
        symbolInfo* x=currentTable->lookup1(s);
        if(x==0)
        {
            scopeTable *y=currentTable;
            while(y->parentScope !=0)
            {
                y = y->parentScope;
                symbolInfo* x=y->lookup1(s);
                if(x!=0) return y->getTableId();
            }
            if(y->parentScope==0) return -1;
        }
        else return currentTable->getTableId();
   }
};
/*
int main()
{
    freopen("inputSymbolTable.txt", "r", stdin);
    freopen("myOutput1.txt", "w", stdout);

    symbolTable st;

    int n;
    char ch;
    string s1,s2;
    cin >> n;
    st.enterScope(n);

    while(cin>>ch)
    {
        if(ch=='I')
        {
            cin >> s1 >> s2;
            cout << ch <<" "<< s1<< " "<<s2<< endl<<endl;
            bool x = st.insertCurrent(s1,s2);
            cout << endl;
        }
        else if(ch=='L')
        {
            cin >>s1;
            cout << ch <<" "<< s1<< endl<<endl;
            symbolInfo *x=st.lookupCurrent(s1);
            cout << endl;

        }
        else if(ch=='D')
        {
            cin >>s1;
            cout << ch <<" "<< s1<< endl<<endl;
            bool x=st.deleteCurrent(s1);
            cout << endl;
        }
        else if(ch=='P')
        {
            char s;
            cin >>s;
            cout << ch <<" "<< s << endl<<endl;
            if(s =='A')
            {
                st.printAll();

            }
            else if(s =='C')
            {
                st.printCurrent();
            }
            else
            {
                cout <<"You must either enter 'A' to print all scopes or 'C' to print the current scope."<<endl<<endl;
                break;
            }
        }
        else if(ch=='S')
        {
            cout << ch <<endl<<endl;
            st.enterScope(n);

        }
        else if(ch=='E')
        {
            cout << ch <<endl<<endl;
            st.exitScope();
        }
        else
        {
            cout<<"You must enter 'I' / 'L' / 'D' / 'S' / 'E' / 'P' to continue."<<endl<<endl;
            break;
        }
    }
    fclose (stdout);
}
*/
