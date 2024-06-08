#include <stdio.h>
#include <stdlib.h>

extern int yyparse();
extern char* yytext;
extern int yyleng;
extern FILE *yyin;
extern int yydebug;

extern int num_errores;

int main(int argc, char* argv[]) {
    yydebug = 0;

    if(argc != 2){ //comprueba que el archivo se pasa como argumento
        printf("[warning] uso %s fichero\n",argv[0]);
        exit(1);
    }

    yyin = fopen(argv[1],"r"); //abre el archivo en modo lectura

    if(yyin == NULL){ //comprueba si el archivo se no se ha podido abrir
        printf("[warning] no se puede abrir el archivo %s\n",argv[1]);
        exit(2);
    }

    yyparse();

    if(num_errores>0){
        printf("#########################\n");
        printf("[Error_Count] se han producido %d errores\n",num_errores);
    }
}