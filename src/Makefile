littleC : main.c lex.yy.c minC.tab.c minC.tab.h listaSimbolos.h listaSimbolos.c listaCodigo.h listaCodigo.c
	gcc -g main.c lex.yy.c minC.tab.c listaSimbolos.c listaCodigo.c -lfl -o littleC

lex.yy.c : lex.l
	flex lex.l

minC.tab.h minC.tab.c : minC.y
	bison -d -v minC.y

clean :
	rm lex.yy.c littleC minC.tab.* minC.output

run : littleC prueba.txt
	./littleC prueba.txt
