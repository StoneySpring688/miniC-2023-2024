%{
	/*archivos y librerias*/
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "listaSimbolos.h"
	#include "listaCodigo.h"
	/*metodos y variables de flex*/
	extern int yylex ();
	extern int yylineno;
	extern int num_errores;
	/*registros*/
	int regTemp[10];
	/*funciones y variables*/
	int nSTR = 1;
	int num_etiq = 1;
	Lista TS;
	Tipo tipo;
	void yyerror(const char* msg);
	void insertTsID(char *a);
	void buscID(char* a, int v);
	void insertTsSTR(char *a, int n);
	void imprimDataLS();
	void iniciarRegs();
	void lReg(char *reg);
	void impCod(ListaC c);
	int pertTs(char *a);
	int isConst(char *a);
	int isGood();
	char* concat(char* a, char* b);
	char *concatNum(char* a, int b);
	char *dReg();
	char* etiq();
%}

%code requires{
	#include "listaCodigo.h"
}

/*tipos para valores de simbolos*/
%union{
	char *str;
	ListaC codigo;
}

%token VAR 			"var"
%token <str>CONST 	"const"
%token IF 			"if"
%token ELSE			"else"
%token DO			"do"
%token WHILE		"while"
%token PRINT		"print"
%token READ			"read"
%token PARI			"("
%token PARD			")"
%token LLAI			"{"
%token LLAD			"}"
%token PYCO			";"
%token COMA			","
%token SUMA			"+"
%token REST			"-"
%token MULT			"*"
%token DIV			"/"
%token IGUA			"="
%token <str>ID		"id"
%token <str>NUM		"num"
%token <str>STR		"string"

%type <codigo> expression stament stament_list print_item print_list read_list identifier identifier_list declarations

/*precedencia*/

%left SUMA REST
%left MULT DIV
%precedence UMENOS

/*funcionamiento de Bison*/

%define parse.error verbose
%define parse.trace

%expect 1 //hay un conflicto d/r en if+if-else


%%

program		:	{TS = creaLS(); iniciarRegs();}ID"(" ")" "{" declarations stament_list"}"	{
				/*volcar lista simbolos a salida, generar .data*/
				if(isGood()){
					imprimDataLS();
					concatenaLC($6, $7);
					impCod($6);
				}
				liberaLS(TS);
				liberaLC($6);
				liberaLC($7);
			}
			;

declarations:	declarations VAR {tipo=VARIABLE;} identifier_list ";"{
																		$$ = $1;
																		concatenaLC($$, $4);
																		liberaLC($4);
			}
			| 	declarations CONST {tipo=CONSTANTE;} identifier_list ";"{
																		$$ = $1;
																		concatenaLC($$, $4);
																		liberaLC($4);
			}
			| 	%empty {
							$$ = creaLC();
			}
			;

identifier_list	:	identifier {
									$$ = $1;
			}
			|	identifier_list "," identifier {
												$$ = $1;
												concatenaLC($$, $3);
												liberaLC($3);
			}
			;

identifier	:	ID{	
					insertTsID($1);
					$$ = creaLC();
				}	
			|ID "=" expression {
					insertTsID($1);
					$$ = $3;
					Operacion ope;
					ope.op = "sw";
					ope.res = recuperaResLC($3);
					ope.arg1 = concat("_", $1);
					ope.arg2 = NULL;
					insertaLC($$,finalLC($$),ope);
					lReg(ope.res);
			}
			;

stament_list:	stament_list stament{
									$$ = $1;
				                    concatenaLC($$, $2);
                                    liberaLC($2);
			}
			|	%empty {$$ = creaLC();

			}
			;

stament		:	ID "=" expression ";" {/*comprobar si $1 ha sido declarado o es una redefinicion de constante*/
											buscID($1, 1);
											$$ = $3;
											Operacion ope;
											ope.op = "sw";
											ope.res = recuperaResLC($3);
											ope.arg1 = concat("_", $1);
											ope.arg2 = NULL;
											insertaLC($$,finalLC($$),ope);
											lReg(ope.res);
											
			}
			|	"{" stament_list "}" {
										$$ = $2;
			}
			|	IF "(" expression ")" stament ELSE stament {
																$$ = $3;
																Operacion ope1;
																ope1.op = "beqz";
																ope1.res = recuperaResLC($3);
																ope1.arg1 = etiq();
																ope1.arg2 = NULL;
																insertaLC($$,finalLC($$),ope1);
																concatenaLC($$,$5);
																liberaLC($5);
																
																Operacion ope2;
																ope2.op = "b";
																ope2.res = etiq();
																ope2.arg1 = NULL;
																ope2.arg2 = NULL;
																insertaLC($$,finalLC($$),ope2);

																Operacion ope3;
																ope3.op = "etiqueta:";
																ope3.res = ope1.arg1;
																ope3.arg1 = NULL;
																ope3.arg2 = NULL;
																insertaLC($$,finalLC($$),ope3);
																concatenaLC($$,$7);
																liberaLC($7);

																Operacion ope4;
																ope4.op = "etiqueta:";
																ope4.res = ope2.res;
																ope4.arg1 = NULL;
																ope4.arg2 = NULL;
																insertaLC($$,finalLC($$),ope4);
																lReg(recuperaResLC($3));
			}
			|	IF "(" expression ")" stament {
												$$ = $3;
												Operacion ope1;
												ope1.op = "beqz";
												ope1.res = recuperaResLC($3);
												ope1.arg1 = etiq();
												ope1.arg2 = NULL;
												insertaLC($$,finalLC($$),ope1);

												concatenaLC($$,$5);
												liberaLC($5);

												Operacion ope2;
												ope2.op = "etiqueta:";
												ope2.res = ope1.arg1;
												ope2.arg1 = NULL;
												ope2.arg2 = NULL;
												insertaLC($$,finalLC($$),ope2);
												lReg(recuperaResLC($$));
			}
			| 	DO stament WHILE "(" expression ")" ";"{
													$$ = creaLC();
													Operacion ope1;
													ope1.op = "etiqueta:";
													ope1.res = etiq();
													ope1.arg1 = NULL;
													ope1.arg2 = NULL;
													insertaLC($$,finalLC($$),ope1);

													concatenaLC($$,$2);
													concatenaLC($$,$5);

													Operacion ope2;
													ope2.op = "bnez";
													ope2.res = recuperaResLC($5);
													ope2.arg1 = ope1.res;
													ope2.arg2 = NULL;
													insertaLC($$,finalLC($$),ope2);

													liberaLC($2);
													liberaLC($5);
													lReg(ope2.res);
			}
			|	WHILE "(" expression ")" stament {
													$$ = creaLC();
													Operacion ope1;
													ope1.op = "etiqueta:";
													ope1.res = etiq();
													ope1.arg1 = NULL;
													ope1.arg2 = NULL;
													insertaLC($$,finalLC($$),ope1);

													concatenaLC($$,$3);

													Operacion ope2;
													ope2.op = "beqz";
													ope2.res = recuperaResLC($3);
													ope2.arg1 = etiq();
													ope2.arg2 = NULL;
													insertaLC($$,finalLC($$),ope2);
													liberaLC($3);

													concatenaLC($$,$5);
													liberaLC($5);

													Operacion ope3;
													ope3.op = "b";
													ope3.res = ope1.res;
													ope3.arg1 = NULL;
													ope3.arg2 =NULL;
													insertaLC($$,finalLC($$),ope3);

													Operacion ope4;
													ope4.op = "etiqueta:";
													ope4.res = ope2.arg1;
													ope4.arg1 = NULL;
													ope4.arg2 = NULL;
													insertaLC($$,finalLC($$),ope4);
			}
			|	PRINT "(" print_list ")" ";" {
												$$ = $3;

			}
			|	READ "(" read_list ")" ";" {
												$$ = $3;
			}
			;

print_list	:	print_item {
								$$ = $1;
			}
			|	print_list "," print_item {
											$$ = $1;
											concatenaLC($$,$3);
			}
			;

print_item	:	expression {
								$$ = $1;
								Operacion ope1;
								ope1.op = "li";
								ope1.res = "$v0";
								ope1.arg1 = "1";
								ope1.arg2 = NULL;
								insertaLC($$,finalLC($$),ope1);

								Operacion ope2;
								ope2.op = "move";
								ope2.res = "$a0";
								ope2.arg1 = recuperaResLC($1);
								ope2.arg2 = NULL;
								insertaLC($$,finalLC($$),ope2);

								Operacion ope3;
								ope3.op = "syscall";
								ope3.res = NULL;
								ope3.arg1 = NULL;
								ope3.arg2 = NULL;
								insertaLC($$,finalLC($$),ope3);
								lReg(recuperaResLC($1));
			}
			|	STR {
						insertTsSTR($1, nSTR);
						$$ = creaLC();
						Operacion ope1;
						ope1.op = "li";
						ope1.res = "$v0";
						ope1.arg1 = "4";
						ope1.arg2 = NULL;
						insertaLC($$,finalLC($$),ope1);

						Operacion ope2;
						ope2.op = "la";
						ope2.res = "$a0";
						ope2.arg1 = concatNum("$str",nSTR-1);
						ope2.arg2 = NULL;
						insertaLC($$,finalLC($$),ope2);

						Operacion ope3;
						ope3.op = "syscall";
						ope3.res = NULL;
						ope3.arg1 = NULL;
						ope3.arg2 = NULL;
						insertaLC($$,finalLC($$),ope3);

			}
			;

read_list	:	ID {
						buscID($1, 1);
						$$ = creaLC();
						Operacion ope1;
						ope1.op = "li";
						ope1.res = "$v0";
						ope1.arg1 = "5";
						ope1.arg2 = NULL;
						insertaLC($$,finalLC($$),ope1);

						Operacion ope2;
						ope2.op = "syscall";
						ope2.res = NULL;
						ope2.arg1 = NULL;
						ope2.arg2 = NULL;
						insertaLC($$,finalLC($$),ope2);

						Operacion ope3;
						ope3.op = "sw";
						ope3.res = "$v0";
						ope3.arg1 = concat("_", $1);
						ope3.arg2 = NULL;
						insertaLC($$,finalLC($$),ope3);
			}
			|	read_list "," ID {
									buscID($3, 1);
									$$ = $1;
									Operacion ope1;
									ope1.op = "li";
									ope1.res = "$v0";
									ope1.arg1 = "5";
									ope1.arg2 = NULL;
									insertaLC($$,finalLC($$),ope1);

									Operacion ope2;
									ope2.op = "syscall";
									ope2.res = NULL;
									ope2.arg1 = NULL;
									ope2.arg2 = NULL;
									insertaLC($$,finalLC($$),ope2);

									Operacion ope3;
									ope3.op = "sw";
									ope3.res = "$v0";
									ope3.arg1 = concat("_", $3);
									ope3.arg2 = NULL;
									insertaLC($$,finalLC($$),ope3);
			}
			;

expression	:	expression "+" expression {
												$$ = $1;
												concatenaLC($$,$3);
												Operacion ope;
												ope.op = "add";
												ope.res = recuperaResLC($1);
												ope.arg1 = recuperaResLC($1);
												ope.arg2 = recuperaResLC($3);
												insertaLC($$,finalLC($$),ope);
												guardaResLC($$,ope.res);
												lReg(ope.arg2);
												liberaLC($3);
												
			}
			|	expression "-" expression {
												$$ = $1;
												concatenaLC($$,$3);
												Operacion ope;
												ope.op = "sub";
												ope.res = recuperaResLC($1);
												ope.arg1 = recuperaResLC($1);
												ope.arg2 = recuperaResLC($3);
												insertaLC($$,finalLC($$),ope);
												guardaResLC($$,ope.res);
												lReg(ope.arg2);
												liberaLC($3);
												
			}
			|	expression "*" expression {
												$$ = $1;
												concatenaLC($$,$3);
												Operacion ope;
												ope.op = "mul";
												ope.res = recuperaResLC($1);
												ope.arg1 = recuperaResLC($1);
												ope.arg2 = recuperaResLC($3);
												insertaLC($$,finalLC($$),ope);
												guardaResLC($$,ope.res);
												lReg(ope.arg2);
												liberaLC($3);
												
			}
			|	expression "/" expression {
												$$ = $1;
												concatenaLC($$,$3);
												Operacion ope;
												ope.op = "div";
												ope.res = recuperaResLC($1);
												ope.arg1 = recuperaResLC($1);
												ope.arg2 = recuperaResLC($3);
												insertaLC($$,finalLC($$),ope);
												guardaResLC($$,ope.res);
												lReg(ope.arg2);
												liberaLC($3);
												
			}
			|	"-"expression %prec UMENOS {
												$$ = $2;
												Operacion ope;
												ope.op = "neg";
												ope.res = recuperaResLC($2);
												ope.arg1 = recuperaResLC($2);
												ope.arg2 = NULL;
												insertaLC($$,finalLC($$),ope);
												guardaResLC($$,ope.res);												

			}
			|	"(" expression ")" {
										$$ = $2;
			}
			|	ID {
						buscID($1, 0);
						$$ = creaLC();
						Operacion ope;
						ope.op = "lw";
						ope.res = dReg();
						ope.arg1 = concat("_", $1);
						ope.arg2 = NULL;
						insertaLC($$,finalLC($$),ope);
						guardaResLC($$,ope.res);
			}
			|	NUM {
						$$ = creaLC();
						Operacion ope;
						ope.op = "li";
						ope.res = dReg();
						ope.arg1 = $1;
						ope.arg2 = NULL;
						insertaLC($$,finalLC($$),ope);
						guardaResLC($$,ope.res);
			}
			;

%%

void yyerror(const char* msg) {
	printf("[Error] linea : %d [%s]\n", yylineno, msg);
}

int pertTs(char *nombre){
	if(buscaLS(TS, nombre) != finalLS(TS)) {return 1;}
	else return 0;
}

void insertTsID(char *a){
	if(!pertTs(a)){
		Simbolo aux;
		aux.nombre = a;
		aux.tipo = tipo;
		aux.valor = 0;
		insertaLS(TS,finalLS(TS),aux);
	}else{
		printf("[Error] %s línea : %d [identificador redefinido]\n",a,yylineno);
    	num_errores++;
	}
	
}

int isConst(char *a){
	if(recuperaLS(TS,buscaLS(TS,a)).tipo == CONSTANTE) return 1;
	else return 0;
}

void buscID(char* a, int v){
  if (pertTs(a)) {
	if(v){
		if(isConst(a)){
			printf("[Error] %s línea : %d [identificador constante, no permite redefinicion]\n",a,yylineno);
			num_errores++;
		}
	}
  }
  else {
	printf("[Error] %s línea : %d [identificador no definido previamente]\n",a,yylineno);
	num_errores++;
  }
}

void insertTsSTR(char *a, int n){
	Simbolo aux;
	aux.nombre = a;
	aux.tipo = CADENA;
	aux.valor = n;
	nSTR++;
	insertaLS(TS,finalLS(TS),aux);
}

int isGood(){
	if(num_errores == 0){
		return 1;
	}
	else{
		return 0;
	}
}

void imprimDataLS(){
	printf("\t.data\n");
	PosicionLista posic = inicioLS(TS);
	PosicionLista fin = finalLS(TS); 
	while(posic!= fin){
		Simbolo sim = recuperaLS(TS, posic);
		if(sim.tipo==CADENA) printf("$str%d:\n\t .asciiz %s\n", sim.valor, sim.nombre);
		else printf("_%s:\n\t .word %d\n", sim.nombre, sim.valor);
		posic = siguienteLS(TS, posic);
	}
	printf("\n");
};

void iniciarRegs(){
	for(int i=0;i<10;i++){
		regTemp[i]=0;
	}
}

char *dReg(){
	char reg[16];
	for(int i=0;i<10;i++){
		if(regTemp[i] == 0){
			regTemp[i] = 1;
			//char *reg = (char *)malloc(5*sizeof(char)); //"$" + "t" + i + '\0' provocaba conflictos en memoria por no manejarse bien
			if(reg == NULL){
				printf("[Error] no se pudo asignar registro $t%d\n",i);
				exit(1);
			}
			sprintf(reg, "$t%d", i);
			return strdup(reg);
		}
	}
	printf("[Error] se agotaron los registros\n");
	exit(1);
}

void lReg(char *reg){
	int i=atoi(&(reg[2])); //avanza a la tercera posic
	regTemp[i] = 0;
}

char* etiq(){
	char et[16];
	sprintf(et, "$l%d", num_etiq);
	num_etiq++;
	return strdup(et);
}

char* concat(char* a, char* b){

	int lA = strlen(a);
	int lB = strlen(b);
	int lTotal = lA +lB +1; //a+b+'\0'

	char *res = (char*)malloc(lTotal);
	if(res==NULL){
		printf("[Error] fallo de concatenación [Memory totally lost]\n");
		free(res);
		exit(1);
	}
	strcpy(res, a);
	strcat(res, b);
	return strdup(res);
}
char *concatNum(char* a, int b){
	char cad[32];
	sprintf(cad,"%s%d",a,b);
	return strdup(cad);
}

void impCod(ListaC c){
	printf("\t.text\n");
	printf("\t.globl main\n");
	printf("main:\n");
	PosicionListaC posic = inicioLC(c);
	while(posic != finalLC(c)){
		Operacion ope = recuperaLC(c, posic);
		if(ope.op == "etiqueta:"){
			printf("%s :\n",ope.res);
		}else if(ope.op == "li"|ope.op == "la"|ope.op == "lw"|ope.op == "sw"|ope.op == "neg"|ope.op == "move"|ope.op == "beqz"|ope.op == "bnez"){
			printf("\t%s ",ope.op);
			if(ope.res) printf("%s, ", ope.res);
			if(ope.arg1) printf("%s", ope.arg1);
			if(ope.arg2) printf("%s", ope.arg2);
			printf("\n");
		}else if(ope.op == "add"|ope.op == "sub"|ope.op == "div"|ope.op == "mul"){
			printf("\t%s ",ope.op);
			if(ope.res) printf("%s, ", ope.res);
			if(ope.arg1) printf("%s, ", ope.arg1);
			if(ope.arg2) printf("%s", ope.arg2);
			printf("\n");
		}else if(ope.op == "b"){
			printf("\t%s ",ope.op);
			if(ope.res) printf("%s ", ope.res);
			printf("\n");
		}else{
			printf("\t%s ",ope.op);
			if(ope.res) printf("%s", ope.res);
			if(ope.arg1) printf("%s", ope.arg1);
			if(ope.arg2) printf("%s", ope.arg2);
			printf("\n");
		}
		posic = siguienteLC(c, posic);
	}
	printf("\n");
	printf("\tli $v0, 10\n");
	printf("\tsyscall\n");
}