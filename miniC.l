%{
#include "miniC.h"
void error_lexico();
%}
/*Macros*/
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+

%option yylineno

%%
[ \n\t]+                            ;
"--"(.*)[\n]                        ;
//Palabras reservadas
var                                 {return VAR;}
const                               {return CONST;}
if                                  {return IF;}
else                                {return ELSE;}
while                               {return WHILE;}
print                               {return PRINT;}
read                                {return READ;}

({letra}|_)({letra}|{digito}|_)*    {if(yyleng<32) return ID;else error_lexico("int length exceeded")}

{entero}                            return INTLITERAL;
"("                                 return LPAREN;		
")"                                 return RPAREN;
";"                                 return SEMICOLON;
","                                 return COMMA;
":="                                return ASSIGNOP;
"+"                                 return PLUSOP;
"-"                                 return MINUSOP;
{entero}[.]{entero}                 return REALLIT;
.                                   error_lexico();
%%

void error_lexico(char *err)
{
  printf("\n[ERROR] %s line: %d [%s]\n",yytext,yylineno,err);
}

void main() {
    int i;
    while (i=yylex())
        printf("%d %s\n",i,yytext);
    printf("FIN DE ANALISIS LEXICO\n");
}
