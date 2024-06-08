%{

/*librerias y archivos*/

#include "minC.tab.h"
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
numeroNoApto        {entero}([,.]{entero})*

/*opciones de flex*/

%option yylineno
/*condicion contexto comentarios multilinea*/
%x comentario 
/*%option debug*/

%%

 /*espacios en blanco y comentarios*/

[ \n\r\t]+                          ;  /*cualquier espacio en blanco*/
"//"(.*)[\n]                        ;  /*comentarios de una linea*/
"/*"                                BEGIN(comentario); init_commentary = yylineno; /*pasa al subautomata del comentario multilínea*/
<comentario>(.|\n)                  ;
<comentario>"*/"                    BEGIN(0); /*vuelve al automata principal*/
<comentario><<EOF>>                 error_lexico("comentario sin cerrar",init_commentary); num_errores++; return 0;

 /*palabras reservadas*/

 /*"main"                              return MAIN;*/
"print"															return PRINT;
"var"                               return VAR;
"const"                             return CONST;
"if"                                return IF;
"else"                              return ELSE;
"do"                                return DO;
"while"                             return WHILE;
"read"                              return READ;

 /*identificadores*/

\"([^"\n]|\\\\|\\\")*\"             {
                                      yylval.str = strdup(yytext);
                                      return STR;
                                    }
\"([^"\n]|\\\\|\\\")*               {
                                      error_lexico("comentario sin cerrar",yylineno);
                                      num_errores++;
                                      return STR;
                                    }  

({letra}|_)({letra}|{digito}|_)*    {
                                      if(yyleng<ID_MAX_LEN){
                                        yylval.str = strdup(yytext);
                                        return ID;
                                      }
                                      else {
                                        error_lexico("length exceeded",yylineno);
                                        num_errores++;
                                        yylval.str = strdup(yytext);
                                        return ID;
                                      }
                                    } /*se devuelve ID para no hacer daño al sintactico*/

 /*constantes*/

{entero}                            {
                                      if(atol(yytext) < MAX_INT_TAM){
                                        yylval.str = strdup(yytext);
                                        return NUM;
                                      }
                                      else{
                                        error_lexico("int length exceeded",yylineno);
                                        yylval.str = strdup(yytext);
                                        num_errores++;
                                        return NUM;
                                      }   
                                    }
{numeroNoApto}                      {
                                      yylval.str = strdup(yytext);
                                      error_lexico("numero no valido",yylineno);
                                      num_errores++;
                                      return NUM;
                                    }

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
[^ \n\r\ta-zA-Z$_0-9+*/\-=;(){},"]+   error_lexico("unrecognised character",yylineno); num_errores++;
%%

 /*seccion de funciones auxiliares*/

void error_lexico(char* a, int line)
{
  printf("[Error] %s line : %d [%s]\n", yytext, line, a);
}