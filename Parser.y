%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineCounter;
%}

// Symbols.

%token BLOCK ENDBLOCK PROGRAM NUMBER WORD TEXT NEWLINE LPAR RPAR COMMA 
%token FUNCTION RETURN END_FUNCTION DOT EAR STRING
// Loops.

%token IF THEN ELSEIF ELSE ENDIF
%token FOR TO STEP ENDFOR
%token WHILE ENDWHILE 
%token SWITCH CASE DEFAULT ENDSWITCH BREAK 

%token STARTMAIN ENDMAIN

%token STRUCT ENDSTRUCT TYPEDEF

// String funcs.

%token AND OR EQUALS NOT_EQUAL LESS MORE UP_AND_DOWN_DOT  SEMICOLON

//VARIABLES
%token VARS INTEGER CHAR LBRCK RBRCK

//Comments
%token COMMENTS_START COMMENTS_END LINE_COMMENT

//Praxis
%token SET 
%left ADD MIN
%left DIV MUL POW

// IO
%token PRINT
// Types.
%type <num> NUMBER
%type <sval> WORD
%type <text> TEXT
%type <str>  STRING
%type <sval> ToBeSet

%code requires{
        struct List{
          char * type;
          char * data;
          char *val;
          int idata;
          int N;
          struct List * next;
        };
        
        struct Structs{
          char *name;
          char *Instance_name;
          struct List * arguments;
          struct Structs *next;
        };
       
        struct Functions{
            char * name;
            struct ArgList *arguments;
            int count;
            struct Functions *next;
        };
        struct ArgList{
            char * varName;
            int  count ;
            struct ArgList * next;
        };
        
        struct ArgList *arghead ;
        struct List *Vshead ;
        struct Structs *_isSDeclared(char *name);    
        struct Functions * _isDeclared(char * name);
        struct List *isSVDeclared(char * word,char * _instance);
        struct List * isDeclared( char *word) ;
        struct List *FindSVars(struct List * arr,char *word);
        struct Structs * _instance_IsDeclared(char * word);
        char * type ;
        int count;
}

%union
{
  int num;
	char *sval;
	char *text;
  char *str;
};

%start Program
%%

Program:
  PROGRAM       
  WORD BLOCK NEWLINE 
  Commands      
  MainFunction  
  Comments    
  ENDBLOCK { if(nerror() ==0){ nerror(12); printf(" \033[0;36m The program compiled Successfully!\033[0;37m");}
              else nerror(12);}
  ;

String:
 EAR InsideString EAR
;
InsideString:
 WORD InsideString
 |TEXT InsideString
 |NUMBER InsideString
 |/*empty*/
;
ArrStr:
  WORD LBRCK NUMBER RBRCK {ArrAssign($1,$3,NULL,NULL,"CHAR",1);}
  ;

Assignment:
  IntAssign SEMICOLON 
 ;

Array:
  WORD LBRCK NUMBER RBRCK {ArrAssign($1,$3,NULL,NULL,"INTEGER",1);}
  ; 

Commands:
  Comments Commands
  |WORD LPAR CPar RPAR SEMICOLON Commands {if(_isDeclared($1)!=NULL) nerror(7,NULL,NULL); else {nerror(8,$1,NULL); nerror(7,NULL,NULL);}}
  |ProgramVariables Commands
  |Structs  Commands
  |Functions Commands  
  |LINE_COMMENT Commands
  |/* empty */
;
Case: 
   CASE UP_AND_DOWN_DOT WORD IntoTheLoops
 | CASE UP_AND_DOWN_DOT WORD IntoTheLoops Case 
 | CASE UP_AND_DOWN_DOT NUMBER IntoTheLoops 
 | CASE UP_AND_DOWN_DOT NUMBER IntoTheLoops Case 
 | CASE UP_AND_DOWN_DOT String IntoTheLoops 
 | CASE UP_AND_DOWN_DOT String IntoTheLoops Case 
 ;


Condition: 
    LPAR Comparisons RPAR 
    ;

Comparisons:
   WORD EQUALS WORD
   | WORD NOT_EQUAL WORD
   | WORD LESS WORD
   | WORD MORE WORD
   | WORD AND WORD
   | WORD OR WORD
   | WORD EQUALS NUMBER
   | WORD NOT_EQUAL NUMBER
   | WORD LESS NUMBER
   | WORD MORE NUMBER
   | WORD AND NUMBER
   | WORD OR NUMBER
   | NUMBER EQUALS WORD
   | NUMBER NOT_EQUAL WORD
   | NUMBER LESS WORD
   | NUMBER MORE WORD
   | NUMBER AND WORD
   | NUMBER OR WORD
   ;

Comments:
  COMMENTS_START IntoTheComments COMMENTS_END 
  |/*empty*/
;
IntoTheComments:
  WORD IntoTheComments
  |TEXT IntoTheComments
  |NEWLINE IntoTheComments
  |NUMBER IntoTheComments
  |CHAR IntoTheComments
  |VARS IntoTheComments
  |PROGRAM IntoTheComments
  |INTEGER IntoTheComments
  |FUNCTION IntoTheComments
  |STRUCT IntoTheComments
  |ENDSTRUCT IntoTheComments
  |PRINT IntoTheComments
  |ENDBLOCK IntoTheComments
  |SEMICOLON IntoTheComments
  |Print IntoTheComments
  |LPAR IntoTheComments
  |RPAR IntoTheComments
  |BLOCK IntoTheComments
  |TYPEDEF IntoTheComments
  |Loops IntoTheComments
  |Variables IntoTheComments
  |/* empty */
;
CPar:
  /*empty*/
  |COMMA CPar 
  |NUMBER CPar {count++;}
  |WORD CPar { count++; }
  |WORD LBRCK RBRCK CPar {count++;}
;
CreateStruct:
  STRUCT WORD NEWLINE WORD SET BLOCK CreatStructParams ENDBLOCK SEMICOLON  {struct Structs *sptr = _isSDeclared($2); 
                                                 if(sptr ==NULL ) nerror(2,$2);

                                                else { sptr->Instance_name = malloc(10*sizeof($4));
                                                      strncpy(sptr->Instance_name,$4,10*sizeof($4));}}

 |STRUCT WORD NEWLINE WORD SEMICOLON {struct Structs *sptr = _isSDeclared($2); if(sptr ==NULL ) nerror(2,$2);  
                                                      else { sptr->Instance_name = malloc(10*sizeof($4));
                                                      strncpy(sptr->Instance_name,$4,10*sizeof($4));}}
 |WORD DOT WORD SET ToBeSet SEMICOLON {
                                        struct List *ptr = isSVDeclared($3,$1); if (ptr==NULL) nerror(3,$1,$3);
                                        if(strcmp(ptr->type,$5)!=0) nerror(5,ptr->type,$5);
 }                
 |WORD DOT WORD LBRCK NUMBER RBRCK SET ToBeSet SEMICOLON { if( isSVDeclared($3,$1)==NULL) nerror(3,$1,$3);
                                         struct List *ptr = isSVDeclared($3,$1); 
                                        if(ptr!=NULL){if(ptr->N < $5) nerror(9,NULL,NULL);
                                        if(strcmp(ptr->type,$8)!=0) nerror(5,ptr->type,$8);
                                        }
                                        else nerror(3,$1,$3); 
                                      }                                      
;

ToBeSet:
   WORD  {struct List * ptr =isDeclared($1); if(ptr==NULL)nerror(10,$1); else $$ = ptr->type;}
   | NUMBER {$$="INTEGER";}
   | String  {$$ = "CHAR";}
   |WORD DOT WORD { struct List *ptr=  isSVDeclared($3,$1); if(ptr==NULL) nerror(3,$1,$3); else $$=ptr->type;}
   |WORD DOT WORD LBRCK NUMBER RBRCK { struct List *ptr ;
                                        ptr = isSVDeclared($3,$1); 
                                        if(ptr!=NULL){if(ptr->N < $5) nerror(9,NULL,NULL); else $$=ptr->type;}
                                        else nerror(3,$1,$3);}
   
;

CreatStructParams:
   WORD CreatStructParams
   |WORD LBRCK NUMBER RBRCK CreatStructParams
   | NUMBER CreatStructParams
   | COMMA CreatStructParams
   | String CreatStructParams
   | /* empty  */ 
;
Declaration: 
   VARS INTEGER IDec SEMICOLON 
  |VARS CHAR StrDec SEMICOLON  
  ;
Expression:
  Paragontas Operator Paragontas Expression 
  |Operator Paragontas 
  |Operator Expression
  |LPAR Expression RPAR
  |/*empty*/ 
;
Paragontas:
   NUMBER 
   |WORD
   ;
Operator:
   ADD
   |MIN
   |MUL
   |POW
   |AND
   |OR
   |DIV
   ;
For:
  FOR WORD UP_AND_DOWN_DOT SET NUMBER TO NUMBER STEP NUMBER {ArrAssign($2,NULL,$5,NULL,NULL,2);}                                                         
  IntoTheLoops ENDFOR 
;
Functions:
  FUNCTION  WORD {arghead=NULL;}  LPAR Parenthesis RPAR { _FuncAssign($2); } NEWLINE 
  ProgramInstructions  
  RETURN 
  ReturnTypes  
  SEMICOLON
  END_FUNCTION  
  ;

FunctionCall:
  WORD {count = 0;}
   LPAR CPar RPAR  { 
                    struct Functions *ptr=_isDeclared($1);
                    if(ptr ==NULL) nerror(6,$1,NULL);
                    if(ptr->arguments->count !=count) nerror(1,$1,NULL);
                    else ;
  } 
;
IDec:
  |WORD IDec {ArrAssign($1,NULL,NULL,NULL,"INTEGER",1);}
  |Array IDec
  |COMMA IDec
;

IntAssign:
  WORD SET NUMBER   { ArrAssign($1,NULL,$3,NULL,INTEGER,2);}
  | WORD SET WORD   {if(_isSetted($1,$3)==1)ArrAssign($1,NULL,NULL,$3,INTEGER,2); else ;}
  | WORD LBRCK NUMBER RBRCK SET NUMBER {
                                        ArrAssign($1,$3,$6,NULL,INTEGER,2);
                                        struct List *ptr ;
                                        ptr = isDeclared($1); 
                                        if(ptr!=NULL){if(ptr->N < $3) nerror(9,NULL,NULL);}
                                        }
  | WORD LBRCK NUMBER RBRCK SET WORD  {if(_isSetted($1,$6)==1) ArrAssign($1,$3,NULL,$6,INTEGER,2);else;
                                         struct List *ptr ;
                                        ptr = isDeclared($1); 
                                        if(ptr!=NULL){if(ptr->N < $3) nerror(9,NULL,NULL);}}
  | WORD SET Expression   {struct List *ptr ;
                                        ptr = isDeclared($1); 
                                        if(ptr==NULL)nerror(10,$1);}
  | WORD SET FunctionCall {struct List *ptr ;
                                        ptr = isDeclared($1); 
                                        if(ptr==NULL)nerror(10,$1);}
  | FunctionCall
  | WORD SET String  
;

IntoTheLoops:
  Variables IntoTheLoops  
  |Loops IntoTheLoops 
  |Print IntoTheLoops
  |BREAK SEMICOLON IntoTheLoops
  | /* empty */  
  |LINE_COMMENT IntoTheLoops 
  ;

If: 
  IF  Condition THEN IntoTheLoops ENDIF 
  |IF Condition THEN IntoTheLoops MoreThanOneElseIf ELSE IntoTheLoops ENDIF
  |IF Condition THEN IntoTheLoops ELSE IntoTheLoops ENDIF 
;

Loops:
   If | While | Switch | For  
  ;


 MainFunction:
  STARTMAIN 
  ProgramInstructions 
  ENDMAIN  
   ;

MoreThanOneElseIf:
   ELSEIF Condition THEN IntoTheLoops 
  |ELSEIF Condition THEN IntoTheLoops  MoreThanOneElseIf  
;

ProgramInstructions:
  ProgramVariables ProgramInstructions
  |CreateStruct ProgramInstructions
  |Loops ProgramInstructions   
  |LINE_COMMENT ProgramInstructions
  |Print ProgramInstructions
  |/* empty */
;

Print:
  PRINT LPAR Inside_Print RPAR SEMICOLON
;

Inside_Print:
  |String Inside_Print
  |WORD Inside_Print  {                 struct List *ptr ;
                                        ptr = isDeclared($1); 
                                        if(ptr==NULL)nerror(10,$1);
                                        }
  |NUMBER Inside_Print
  |COMMA Inside_Print
;

Parenthesis:
  /* empty */
  |COMMA Parenthesis 
  |WORD{insertArgList($1);} Parenthesis 
  |WORD LBRCK RBRCK Parenthesis {insertArgList($1);}
  ;

ProgramVariables:
  Variables ProgramVariables
  | /* empty */ 
;

ReturnTypes:
WORD    {         struct List *ptr ;
                        ptr = isDeclared($1);
                        if(ptr==NULL)nerror(10,$1);
                       }
|NUMBER
|String 
;



Structs:
 
  AStruct {Vshead = NULL;}
  |TStruct {Vshead = NULL;}
  ;
  
  AStruct:

  STRUCT  WORD NEWLINE StructVariables  ENDSTRUCT {StructAssign($2);}
  
  ;
  
  TStruct:
  
  TYPEDEF  STRUCT WORD NEWLINE StructVariables WORD ENDSTRUCT{ 
    
    if(strcmp($3,$6)==0) StructAssign($3); else nerror(11);
   }
  ;
  
StructVariables:
   StructDecsI StructVariables
   |StructDecsC StructVariables
   | /* empty */   
;
StructDecsC:
  VARS {type = malloc(10*sizeof(1));}
  CHAR {strncpy(type, "CHAR",sizeof("CHAR"));}
  Types SEMICOLON

;
StructDecsI:
  VARS    {type = malloc(10*sizeof(1));}
  INTEGER {strncpy(type, "INTEGER",sizeof("INTEGER"));}
  Types SEMICOLON
;

Types:
  WORD Types {StructVars($1,NULL,NULL,NULL,type);}
  |WORD LBRCK NUMBER RBRCK Types {StructVars($1,$3,NULL,NULL,type);}
  |COMMA Types
  |/*EMPTY*/
;

StrDec:
  ArrStr
  |ArrStr COMMA StrDec
  |WORD {ArrAssign( $1,NULL,NULL,NULL,"CHAR",1);}
  |WORD COMMA StrDec  {ArrAssign($1,NULL,NULL,NULL,"CHAR",1);}
  |StrDec COMMA StrDec
;

Switch: 
   SWITCH LPAR WORD RPAR Case DEFAULT UP_AND_DOWN_DOT IntoTheLoops ENDSWITCH
  ;

Variables:
  Declaration 
  |Assignment 
;

While:
   WHILE Condition IntoTheLoops ENDWHILE 
   ;


%%


struct List *head =NULL;
struct Functions *fhead = NULL;
struct Structs *shead = NULL;
int counter =0;
int count=0;


void  StructVars(char var[],int N,int idata,char *data,char *type){
  struct List *li=(struct List *)malloc (sizeof(struct List));
                      li->val = malloc(sizeof(var));
                    strncpy(li->val,var,sizeof(var));
                    
                    li->N   = N;
                    li->idata = idata;
                    li->data  = &data;
                    li->type = type;
                   
                    li->next = Vshead;
                    Vshead = li;
                    
                  }

void insertArgList(char * name){
    struct ArgList *argli =(struct ArgList*)malloc(sizeof(struct ArgList));
    argli->varName= name;
    count++;
    argli->count = count ;
    argli->next = arghead;
    arghead = argli;
}

void _FuncAssign(char *name){
  struct Functions *func = (struct Functions*)malloc(sizeof(struct Functions));
  func->name=name;
  func->count = count;
  func->arguments = arghead;
  
  func->next=fhead;
  fhead= func;

}
struct Structs * _isSDeclared( char *word) {
    
   struct Structs* scurrent = shead;
 
   while(scurrent!=NULL && strcmp(scurrent->name, word)!=0) 
         scurrent = scurrent->next;
      
   return scurrent;
}


void StructAssign(char * name){
  struct Structs *sstructs = (struct Structs*)malloc(sizeof(struct Structs));
  sstructs->name = name;
  sstructs->arguments = Vshead;
  sstructs->next = shead;
  shead = sstructs;
  
}

struct Functions * _isDeclared(char * name){
  struct Functions* current = fhead;


   while(current!=NULL && strcmp(current->name, name)!=0) 
         current = current->next;
      
   return current;

}



void PrintFunc(){
  int temp=1;
  struct Functions *current = fhead;
 printf("\n----------------------------FUNCS------------------------\n");
   
	
   //start from the beginning
   while(current != NULL) {
      printf("\033[0;31m FUNCTION => \033[0;37m%s \n ",current->name);

      while(current->arguments!=NULL){
        printf("\033[0;31mArguments=>\033[0;37m %s\n",current->arguments->varName);
        current->arguments = current->arguments->next;
      }
      
        

      current = current->next;
   }
	
}



void  ArrAssign(char var[],int N,int idata,char *data,char *type, int temp){
          struct List *li=(struct List *)malloc (sizeof(struct List));
    int j =0;
          switch(temp){
            case 1:
                    if (strcmp(type,"INTEGER")==0){
                      li->val = malloc(sizeof(var));
                    strncpy(li->val,var,sizeof(var));
                    
                    li->N   = N;
                    li->idata = idata;
                    li->data  = &data;
                    li->type = type;
                   
                    li->next = head;
                    head = li;
                            
                  }
                  else{
                    li->val = malloc(sizeof(var));
                    strncpy(li->val,var,sizeof(var));
                    li->N   = N;
                    li->idata = idata;
                    li->data  = data;
                    li->type = type;
                  
                    li->next = head;
                    head = li;
                  }
                  break;
  
                    
          case 3:
                PrintVars();
                break;
          }
}
int _isSetted(char *name,char * name2){
        struct List *current;
        struct List *current2;
       
            current = isDeclared(name);
            current2= isDeclared(name2);
            if(current!=NULL && current2 !=NULL) {
                if(strcmp(current->type,current2->type)==0){
                  return 1;
                }
                else {nerror(5,current->type,current2->type); return 0;} 
            }
            else {nerror(4,name,NULL); return 0;}
      
}

void PrintVars(){
  struct List *ptr = head;
printf("\n----------------------------VARS------------------------\n");
	int count=0;
   //start from the beginning
   while(ptr != NULL) {
     if(count%2 == 0) printf("\n");
     printf("\033[0;31mVariable =>\033[0;37m %s\t",ptr->val);
     printf("\t");
     printf("\033[0;31mType => \033[0;37m%s\n",ptr->type);
     count++;
      ptr = ptr->next;
   }
   printf("\n--------------------------------------------------------\n");

}

void PrintStructs(){
  struct Structs *current = shead;
printf("\n----------------------------STRUCTS------------------------\n");
	
   //start from the beginning
   while(current != NULL) {
     printf("\n");
     printf("\033[0;31mStruct =>\033[0;37m %s,\t_INSTANCE:  %s \n",current->name,current->Instance_name);
      printf("\n");
       printf("\n");
     structArguments(current);
     current = current->next;
   }
   printf("\n--------------------------------------------------------\n");

}

void structArguments(struct Structs *current){
  while(current->arguments!=NULL){
      
       printf("\033[0;31mVariable =>\033[0;37m %s\n",current->arguments->val);
       current->arguments = current->arguments->next;
  }
}

struct List *  isSVDeclared( char *word,char *_instance) {
    struct Structs *lptr = shead;
    int i_count = 0;
  while(lptr!=NULL){
      if(lptr->Instance_name!=NULL && strcmp(lptr->Instance_name,_instance)==0){
        i_count++;
       return FindSVars(lptr->arguments,word);
      }
      lptr = lptr->next;
    }
    if(i_count==0)
    nerror(13,_instance);
}

struct List *FindSVars(struct List * arr,char *word){
while(arr!=NULL){
          if(arr->val && strcmp(arr->val ,word)==0){
            
             return arr;
          }
           arr = arr->next;
        }
}

struct List * isDeclared( char *word) {
    
   struct List* current = head;
 
   while(current!=NULL && strcmp(current->val, word)!=0) 
         current = current->next;
      
   return current;
}


void yyerror(){
  fprintf(stderr,"\nAt line: %d\033[0;31merror0: Unrecognized reserved word or character sequence\033[0;37m \n",lineCounter);
  counter ++;
}

int nerror(int type,char * word1,char * word2) {
  switch(type){
     case 1:
        printf("\nAt Line: %d \033[0;31merror1: In function \033[0;32m%s \033[0;31m arguments out of scope. \n",lineCounter,word1);
         printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
         counter ++;
         break;
      case 2:
        printf("\nAt Line: %d \033[0;31merror2: The Struct \033[0;32m%s \033[0;31m is not declared. \n",lineCounter,word1);
         printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
         counter ++;
        break;
      case 3:
       printf("\nAt Line: %d \033[0;31merror3: Struct \033[0;32m%s \033[0;31m has no member: %s. \n",lineCounter,word1,word2);
         printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
         counter ++;
        break;
      case 4:
        printf("\033[0;31merror4:At Line: %d The value of assignment \033[0;32m %s \033[0;31mis not declared\033[0;37m\n",lineCounter,word1);
        counter ++;
        break;
      case 5:
        printf("\nAt line: %d\033[0;31merror5: Ivalid type assignment. You have  \033[0;32m%s \033[0;31m<= \033[0;32m%s \033[0;37m \n",lineCounter,word1,word2);
        printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
        counter ++;
        break;
      case 6:
        printf("\nAt line: %d\033[0;31merror6: The function \033[0;32m%s \033[0;31mdoes not exist\033[0;37m \n",lineCounter,word1);
        printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
        counter ++;
        break;
      case 7:
        printf("\nAt line: %d\033[0;31merror7: You can not call a function in global field. \n",lineCounter);
        printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
       counter ++;
        break;
      case 8:
        printf("\nAt Line: %d \033[0;31merror8: The function \033[0;32m%s \033[0;31m is undeclared. \n",lineCounter,word1);
        printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
        counter ++;
        break;
      case 9:
        printf("\nAt Line: %d \033[0;31merror9: Array out of scope. \n",lineCounter);
        printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
        counter ++;
        break;
      case 10:
        printf("\nAt Line: %d \033[0;31merror10: The variable \033[0;32m%s \033[0;31m is undeclared. \n",lineCounter,word1);
         printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
        counter ++;
        break;
      case 11:
        printf("\nAt Line: %d \033[0;31merror11: Struct names should much \033[0;32m \033[0;31m is undeclared. \n",lineCounter);
         printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
      counter ++;
      break;
      case 12:
      printf("\n  \033[0;31mThe Program Produced\033[0;32m %d \033[0;31m Errors. \033[0;37m \n",counter);
      break;
      case 13:
        printf("\nAt line: %d\033[0;31merror13:Struct _Instance \033[0;32m%s \033[0;31m has no previous declaration.\033[0;37m \n",lineCounter,word1);
        printf("\033[0;35m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0;37m\n");
        counter ++;
        break;
        

  }
    return counter;
  }

	
int main(void) {
  
  yyparse();
  if(counter==0){
  //printf("\n\n\n\nPROGRAM ENDED \n THE VARIABLES ARE:\n");
  //ArrAssign(NULL,NULL,NULL,NULL,NULL,3);
  PrintVars();
   
  //printf("\n The Functions are:\n");
 PrintFunc();
 PrintStructs();
  }
  else ;
}