%{
#include "lex.h"
#include <stdio.h>
#define ID_MAX_LEN 32
void error_lexico();
%}

/*macros de expresiones regulares*/

digito              [0-9]
letra               [a-zA-Z$_]
entero              {digito}+

/*opciones de flex*/

%option yylineno

/*condicion contexto comentarios multilinea*/

%x comentario

%%

 /*espacios en blanco y comentarios*/

[ \n\r\t]+                          ;  /*cualquier espacio en blanco*/
"//"(.*)[\n]                        ;  /*comentarios de una linea*/
"/*"                                BEGIN(comentario); /*pasa al subautomata del comentario multilínea*/
<comentario>(.|\n)                  ;
<comentario>"*/"                    BEGIN(0); /*vuelve al automata principal*/

 /*reglas de tokens*/

"main"                              return MAIN;
"print"															return PRINT;
{letra}({letra}|{digito})*          {if(yyleng<ID_MAX_LEN)return ID;
                                    else error_lexico("length exceeded");}
{entero}                            return NUM;
"+"																	return SUMA;
"*"																	return MULT;
"/"																	return DIV;
"-"																	return REST;
"="																	return IGUA;
";"																	return PYCO;
"("                                 return PARI;
")"                                 return PARD;
"{"                                 return LLAI;
"}"                                 return LLAD;
","                                 return COMA;
\"([^"\n]|\\\\|\\\")*\"             return CADENA;
\"([^"\n]|\\\\|\\\")*               error_lexico("comentario sin cerrar");

 /*tratamiento de errores*/
.                                   error_lexico("unrecognised character");  
%%

 /*seccion de funciones auxiliares*/

void error_lexico(char* a)
{
  printf("[Error] %s line : %d [%s]\n", yytext, yylineno,a);
}

void main() {
    int i;
    while (i=yylex())
        printf("Token : <%d , %s>\n", i, yytext);
    printf("FIN DE ANALISIS LEXICO\n");
}