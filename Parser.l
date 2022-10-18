
%option yylineno
%{
#include "Parser.h"
int mindTheNewline = 0;
int lineCounter = 1;
%}

digit           [0-9]
number          [1-9]+{digit}*
letter          [a-zA-Z]
word            [_a-zA-Z0-9]+
text            [{word}@*#*/*]+
str             """[ {word}]*""" 
    
      
%%


"\t"*" "*       {}
"?"*            {}
"\n"            { if(mindTheNewline==1){mindTheNewline--; lineCounter++; return(NEWLINE);} lineCounter++;}
"PROGRAM"       { mindTheNewline++; return (PROGRAM); }
"FUNCTION"    	{ mindTheNewline++; return (FUNCTION); }
"RETURN"        { return (RETURN);}
"END_FUNCTION"	{ return(END_FUNCTION); }
"("				{ return (LPAR); }
","             { return (COMMA); }
")"				{ return (RPAR);  }
"{"             { return (BLOCK); } 
"}"             { return (ENDBLOCK); }
"\""			{ return (EAR);}
"VARS"          { return(VARS);}
"INTEGER"       { return(INTEGER);}
"CHAR"          { return(CHAR); }
"IF"            { return(IF); }
"THEN"          { return(THEN); }
"ELSEIF"        { return(ELSEIF); }
"ELSE"          { return(ELSE); }
"ENDIF"         { return(ENDIF); }
"WHILE"         { return(WHILE); }
"ENDWHILE"      { return(ENDWHILE); }
"FOR"           { return(FOR); } 
"TO"            { return(TO); }
"STEP"          { return(STEP); }
"ENDFOR"        { return(ENDFOR); }
"SWITCH"        { return(SWITCH); }
"CASE"          { return(CASE); }
"DEFAULT"       { return(DEFAULT); }
"ENDSWITCH"     { return(ENDSWITCH); }
"PRINT"         { return(PRINT);}
"BREAK"			{ return (BREAK);}
 
"STARTMAIN"     { return (STARTMAIN);}
"ENDMAIN"       { return (ENDMAIN);}

"="             { return (SET);}
"+"             { return (ADD);}
"-"             { return (MIN);}
"*"             { return (MUL);}
"^"             { return (POW);}
"/"             { return (DIV);}
"<"             { return(LESS); }
">"             { return(MORE); }
"=="            { return(EQUALS); }
"!="            { return(NOT_EQUAL); } 
"["             { return(LBRCK);}
"]"             { return(RBRCK);}
"AND"           { return(AND); } 
"OR"            { return(OR); }

":"             { return(UP_AND_DOWN_DOT); }
";"             { return(SEMICOLON); }

"."             {return(DOT);}

"/*"            { return(COMMENTS_START);} 
"*/"            { return(COMMENTS_END);}
%[^\n]*[\n]     { lineCounter++; return(LINE_COMMENT);}

"STRUCT"        { mindTheNewline++; return(STRUCT); }
"ENDSTRUCT"     { return(ENDSTRUCT); }
"TYPEDEF"       { return(TYPEDEF); }    

{number}        { yylval.num = atoi(yytext); return(NUMBER);}
{word}          { yylval.sval = malloc(strlen(yytext));
				 strncpy(yylval.sval, yytext, strlen(yytext));
				 return(WORD); }
{text}          { yylval.text = malloc(strlen(yytext));
				 strncpy(yylval.text, yytext, strlen(yytext));
				 return(TEXT); }
     

%%