bison -d -y parser.y
g++ -w -c -o y.o y.tab.c
flex lexAnal.l
g++ -w -c -o l.o lex.yy.c
g++ -o a.out y.o l.o -lfl -ly
./a.out input.txt

#include "SymbolInfo.cpp"
