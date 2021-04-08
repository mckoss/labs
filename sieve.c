#include <time.h>       // clock, CLOCKS_PER_SEC
#include <stdio.h>      // printf
#include <stdlib.h>     // calloc
#include <assert.h>     // assert
#include <math.h>       // sqrt

#define MEASUREMENT_SECS (5)
#define TRUE (1)
#define FALSE (0)

// Primes to one million.
#define MAX_NUMBER 1000000L
#define EXPECTED_PRIMES 78498L

//
// Simple prime number sieve.
//
// maxNumber - find all primes strictly LESS than this number.
//
// A bitmap where:
//
//   0: Prime
//   1: Composite
//
// Only odd values are represented.
// bit[i] => represents number 2*i + 1
// lsb first number
//
// Bits in lsb order:
// 1, 3, 5, 7, 9, ... 
//
// Use 64-bit WORDS
// (n - 1) / 128 => word address in buffer
// ((n - 1) / 2) % 64 => bit address in byte
//
#define WORD unsigned long
#define BITS_PER_WORD (sizeof(WORD) * 8)

// 1-based - only odd numbers
#define indexOf(n) (n - 1) / 2 / BITS_PER_WORD
#define maskOf(n) (WORD) 1 << ((n - 1) / 2) % BITS_PER_WORD
#define allocOf(n) indexOf(n) + 1

int countPrimes(int maxNumber) {
   // Starts off zero-initialized.
   WORD *buffer = (WORD *) calloc(allocOf(maxNumber), sizeof(WORD));
   unsigned int maxFactor = sqrt(maxNumber) + 1;

   // We get 2 for "free".
   int count = 1;
   unsigned int p;

   // Look for next prime
   for (p = 3; p <= maxFactor; p += 2) {
      // A 1 bit means it's composite - keep searching.
      if (buffer[indexOf(p)] & maskOf(p)) {
         continue;
      }
      count++;
      // printf("%d, ", p);

      // No need to start less than p^2 since all those
      // multiples have already been marked.
      for (unsigned int m = p * p; m < maxNumber; m += 2 * p) {
         buffer[indexOf(m)] |= maskOf(m);
      }
   }

   // Add all the remaining primes above sqrt(maxNumber)
   for (unsigned int q = p; q < maxNumber; q += 2) {
      if (buffer[indexOf(q)] & maskOf(q)) {
         continue;
      }
      count++;
      // printf("%d, ", q);
   }

   return count;
}

int main () {
   clock_t startTicks;
   clock_t currentTicks;
   int passes = 0;

   printf("Timer resolution: %d ticks per second.\n", CLOCKS_PER_SEC);
   printf("Allocating %d %d-bit words.\n", allocOf(MAX_NUMBER), BITS_PER_WORD);

   // Test of idea to pre-compute cycle of bit masks.
   int p = 547;
   int m = p * p;
   for (int i = 1; i <= BITS_PER_WORD; i += 2, m += 2 * p) {
      printf("%6d - %08llx\n", m, maskOf(m));
   }

   startTicks = clock();

   long limitTicks = MEASUREMENT_SECS * CLOCKS_PER_SEC + startTicks;

   while (TRUE) {
      currentTicks = clock();
      if (currentTicks >= limitTicks) {
         break;
      }
      passes++;
      int primeCount = countPrimes(MAX_NUMBER);
      if (primeCount != EXPECTED_PRIMES) {
         printf("Expected %ld primes - but found %ld of them.\n", EXPECTED_PRIMES, primeCount);
         assert(FALSE);
      }
   }

   printf("%d passes completed in %d seconds.\n", passes, MEASUREMENT_SECS);

   return(0);
}