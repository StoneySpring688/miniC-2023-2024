#include <stdio.h>
#include <stdlib.h>
#include "miniC.h"

extern char *yytext;
extern int  yyleng;
extern FILE *yyin;
extern int yylex();
FILE *fich;
int main()
{
    int i;
    char nombre[80];
    printf("INTRODUCE NOMBRE DE FICHERO FUENTE:");
    scanf("%s",nombre);
	printf("\n");
    if ((fich=fopen(nombre,"r"))==NULL) {
        printf("***ERROR, no puedo abrir el fichero\n");
        exit(1);		}
    yyin=fich;
    while (i=yylex()) {
        printf("TOKEN %d ",i);
        if(i==ID||i==INTLITERAL||i==REALLIT) printf("LEXEMA %s  LONGITUD %d\n",yytext,yyleng);
        else printf("\n");}
    fclose(fich);
    return 0;
}
