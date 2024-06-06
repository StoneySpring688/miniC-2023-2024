%{

/*librerias y archivos*/

#include "lex.h"
#include <stdio.h>

/*constantes*/

#define ID_MAX_LEN 32
#define MAX_INT_TAM 2147483648

/*variables*/

 int init_commentary;
 int num_errores;

/*funciones*/

void error_lexico();

%}

/*macros de expresiones regulares*/

digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+

/*opciones de flex*/

%option yylineno
/*condicion contexto comentarios multilinea*/
%x comentario 

%%

 /*espacios en blanco y comentarios*/

[ \n\r\t]+                          ;  /*cualquier espacio en blanco*/
"//"(.*)[\n]                        ;  /*comentarios de una linea*/
"/*"                                BEGIN(comentario); init_commentary = yylineno; /*pasa al subautomata del comentario multilínea*/
<comentario>(.|\n)                  ;
<comentario>"*/"                    BEGIN(0); /*vuelve al automata principal*/
<comentario><<EOF>>                 error_lexico("comentario sin cerrar",init_commentary); num_errores++; return 0;

 /*palabras reservadas*/

"main"                              return MAIN;
"print"															return PRINT;
"var"                               return VAR;
"const"                             return CONST;
"if"                                return IF;
"else"                              return ELSE;
"while"                             return WHILE;
"read"                              return READ;

 /*identificadores*/

({letra}|_)({letra}|_|{digito})*    {if(yyleng<ID_MAX_LEN)return ID;
                                    else error_lexico("length exceeded",yylineno); num_errores++; return ID;} /*se devuelve ID para no hacer daño al sintactico*/

 /*constantes*/

{entero}                            {if(atol(yytext) < MAX_INT_TAM)return NUM;
                                    else error_lexico("int length exceeded",yylineno); num_errores++; return NUM;}
\"([^"\n]|\\\\|\\\")*\"             return CADENA;
\"([^"\n]|\\\\|\\\")*               error_lexico("comentario sin cerrar",yylineno); num_errores++;

 /*caracteres especiales*/

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


 /*tratamiento de errores*/
.                                   error_lexico("unrecognised character",yylineno); num_errores++;
%%

 /*seccion de funciones auxiliares*/

void error_lexico(char* a, int line)
{
  printf("[Error] %s line : %d [%s]\n", yytext, line, a);
}

void main() {
    int i;
    while (i=yylex())
        printf("Token : <%d , %s>\n", i, yytext);
    if(num_errores>0){
      printf("[Error_Count] se han producido %d errores\n",num_errores);
    }
    printf("FIN DE ANALISIS LEXICO\n");
}