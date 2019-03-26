#include <stdio.h>
#include <emscripten.h>

EMSCRIPTEN_KEEPALIVE
int computePrimesWasm() {
   int lastPrime, i, j, isPrime;
   for (i = 2; i < 80000; i = i+1) {
      isPrime = 1;
      for (j = i-1; j >= 2; j--) {
         if (i % j == 0) {
            isPrime = -1;
            break;
         }
      }
      if (isPrime == 1) {
         lastPrime = i;
      }
   }
   return lastPrime;
}
