#include <time.h>       // clock, CLOCKS_PER_SEC
#include <stdio.h>      // printf
#include <stdlib.h>     // calloc
#include <assert.h>     // assert
#include <math.h>       // sqrt

#define MEASUREMENT_SECS (1)
#define TRUE (1)
#define FALSE (0)

#define WORD unsigned long
#define BITS_PER_WORD (sizeof(WORD) * 8)

// Primes to one million.
#define MAX_NUMBER 1000000L
#define EXPECTED_PRIMES 78498L

//
// Simple prime number sieve - bitmapped.
//
// This is 20% FASTER than the mod-2 version below that allocates half
// the memory (presumably because of inner loop code calculating bit
// masks a little more complicated that the naive version!)
//
// maxNumber - find all primes strictly LESS than this number.
//
// A bitmap where:
//
//   0: Prime
//   1: Composite
//
// Both odd and even bits are in the buffer - we just
// ignore the even ones.
//
// Bits in lsb order:
// 0, 1, 2, 3, 4, ...
//
#define indexOf(n) n / BITS_PER_WORD
#define maskOf(n) (WORD) 1 << n % BITS_PER_WORD
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

      // The following loop the hotspot for this algorithm
      // executing about 800,000 times for a scan up to 1 million.
      // I tried pre-calculating masks - but that just slowed
      // it down.

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

   free(buffer);
   
   return count;
}

//
// Only odd (mod 2) prime number sieve.
//
// maxNumber - find all primes strictly LESS than this number.
//
// A bitmap where:
//
//   0: Prime
//   1: Composite
//
// Bits in lsb order:
// 1, 3, 5, 7, 9, ... 
//
// 1-based - only odd numbers
// HACK - Remove -1 since integer division ROUNDS DOWN ANYWAY.
// SPEEDUP BY 5%!
#define indexOf2(n) (n) / 2 / BITS_PER_WORD
#define maskOf2(n) (WORD) 1 << ((n) / 2) % BITS_PER_WORD
#define allocOf2(n) indexOf2(n) + 1
int countPrimesMod2(int maxNumber) {
   // Starts off zero-initialized.
   WORD *buffer = (WORD *) calloc(allocOf2(maxNumber), sizeof(WORD));
   unsigned int maxFactor = sqrt(maxNumber) + 1;

   // We get 2 for "free".
   int count = 1;
   unsigned int p;

   // Look for next prime
   for (p = 3; p <= maxFactor; p += 2) {
      // A 1 bit means it's composite - keep searching.
      if (buffer[indexOf2(p)] & maskOf2(p)) {
         continue;
      }
      count++;
      // printf("%d, ", p);

      // The following loop the hotspot for this algorithm
      // executing about 800,000 times for a scan up to 1 million.
      // I tried pre-calculating masks - but that just slowed
      // it down.

      // No need to start less than p^2 since all those
      // multiples have already been marked.
      for (unsigned int m = p * p; m < maxNumber; m += 2 * p) {
         buffer[indexOf2(m)] |= maskOf2(m);
      }
   }

   // Add all the remaining primes above sqrt(maxNumber)
   for (unsigned int q = p; q < maxNumber; q += 2) {
      if (buffer[indexOf2(q)] & maskOf2(q)) {
         continue;
      }
      count++;
      // printf("%d, ", q);
   }

   free(buffer);

   return count;
}

//
// Only numbers congruent to 1 or 5 (mod 6) are stored.
//
// maxNumber - find all primes strictly LESS than this number.
//
// A bitmap where:
//
//   0: Prime
//   1: Composite
//
//
// Bits in lsb order:
// 1, 5, 7, 11, 13, 17, 19, 23, 
// (2 numbers in every 6, i.e., 1/3 of the numbers stored)
//
// Using 32-bit WORDS
// (n - 1) / 3 / 32 => word address in buffer
// ((n - 1) / 3) % 32 => bit address in byte
//
#define indexOf6(n) (n/3) / BITS_PER_WORD
#define maskOf6(n) (WORD) 1 << (n/3) % BITS_PER_WORD
#define allocOf6(n) indexOf6(n) + 1
int countPrimesMod6(int maxNumber) {
   // Starts off zero-initialized.
   WORD *buffer = (WORD *) calloc(allocOf6(maxNumber), sizeof(WORD));
   unsigned int maxFactor = sqrt(maxNumber) + 1;

   // We get 2 and 3 for "free".
   int count = 2;
   unsigned int p;
   unsigned int step;

   // Alternate steps by 2 and 4.
   for (p = 5, step = 2; p <= maxFactor; p += step, step = 6 - step) {
      // A 1 bit means it's composite - keep searching.
      if (buffer[indexOf6(p)] & maskOf6(p)) {
         continue;
      }
      count++;
      // printf("%d, ", p);

      // The following loop the hotspot for this algorithm
      // executing about 800,000 times for a scan up to 1 million.
      // I tried pre-calculating masks - but that just slowed
      // it down.

      // No need to start less than p^2 since all those
      // multiples have already been marked.
      for (unsigned int m = p * p; m < maxNumber; m += 2 * p) {
         unsigned int mod = m % 6;
         if (mod == 1 || mod == 5) {
            buffer[indexOf6(m)] |= maskOf6(m);
         }
      }
   }

   // Add all the remaining primes above sqrt(maxNumber)
   for (unsigned int q = p; q < maxNumber; q += step, step = 6 - step) {
      if (buffer[indexOf6(q)] & maskOf6(q)) {
         continue;
      }
      count++;
      // printf("%d, ", q);
   }

   free(buffer);

   return count;
}

void timedTest(int primeFinder(int), char *title) {
   clock_t startTicks;
   clock_t currentTicks;
   int passes = 0;

   startTicks = clock();

   long limitTicks = MEASUREMENT_SECS * CLOCKS_PER_SEC + startTicks;

   while (TRUE) {
      currentTicks = clock();
      if (currentTicks >= limitTicks) {
         break;
      }
      passes++;
      int primeCount = primeFinder(MAX_NUMBER);
      if (primeCount != EXPECTED_PRIMES) {
         printf("%s Expected %ld primes - but found %ld!\n",
                title, EXPECTED_PRIMES, primeCount);
         assert(FALSE);
      }
   }

   printf("%s %d passes completed in %d seconds (%0.3f ms per pass).\n",
          title, passes, MEASUREMENT_SECS, (float) MEASUREMENT_SECS / passes * 1000);
}

int main() {
   printf("Timer resolution: %d ticks per second.\n", CLOCKS_PER_SEC);
   printf("Word size: %d bits.\n\n", BITS_PER_WORD);

   timedTest(countPrimes, "Full bitmap.");
   timedTest(countPrimesMod2, "Only odd bits.");
   timedTest(countPrimesMod6, "Only 2 out of 6 bits.");

   return(0);
}

