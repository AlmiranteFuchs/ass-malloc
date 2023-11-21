#include <stdio.h>
#include "ass_malloc.h"

int main (long int argc, char** argv) {
  void *a,*b,*c,*d,*e;

  iniciaAlocador(); 
  imprimeMapa();
  // 0) estado inicial
  a=(void *) worst_fit(100);
  imprimeMapa();
  b=(void *) worst_fit(130);
  imprimeMapa();
  c=(void *) worst_fit(120);
  imprimeMapa();
  d=(void *) worst_fit(110);
  imprimeMapa();
  // 1) Espero ver quatro segmentos ocupados

  liberaMem(b);
  imprimeMapa(); 
  liberaMem(d);
  imprimeMapa(); 
  // 2) Espero ver quatro segmentos alternando
  //    ocupados e livres

  b=(void *) worst_fit(50);
  imprimeMapa();
  d=(void *) worst_fit(90);
  imprimeMapa();
  e=(void *) worst_fit(40);
  imprimeMapa();
  // 3) Deduzam
	
  liberaMem(c);
  imprimeMapa(); 
  liberaMem(a);
  imprimeMapa();
  liberaMem(b);
  imprimeMapa();
  liberaMem(d);
  imprimeMapa();
  liberaMem(e);
  imprimeMapa();
   // 4) volta ao estado inicial

  finalizaAlocador();
}