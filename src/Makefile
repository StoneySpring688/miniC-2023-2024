littleC : lex.yy.c lex.h
	gcc -g lex.yy.c -lfl -o littleC

lex.yy.c : lex.l lex.h
	flex lex.l

clean :
	rm lex.yy.c littleC

run : littleC entrada.txt
	./littleC < entrada.txt
