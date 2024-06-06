#include <stdio.h>
#include <stdlib.h>

extern char* yytext;
extern int num_errores;
extern int yylex();
extern FILE *yyin;

int main(int argc, char* argv[]) {

    if(argc != 2){ //comprueba que el archivo se pasa como argumento
        printf("[warning] uso %s fichero\n",argv[0]);
        exit(1);
    }

    yyin = fopen(argv[1],"r"); //abre el archivo en modo lectura

    if(yyin == NULL){ //comprueba si el archivo se no se ha podido abrir
        printf("[warning] no se puede abrir el archivo %s\n",argv[1]);
        exit(2);
    }

    int i;
    while (i=yylex())
        printf("Token : <%d , %s>\n", i, yytext);
    if(num_errores>0){
      printf("[Error_Count] se han producido %d errores\n",num_errores);
    }
    printf("FIN DE ANALISIS LEXICO\n");
}