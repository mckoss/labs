#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>

typedef enum {false, true} bool;

#define MAX_SET 33
#define MAX_DIFFS (MAX_SET * (MAX_SET - 1) + 1)
#define FOREVER for (;;)
#define PROGRESS 100000000L

int primes[MAX_SET];
int pcount = 0;

time_t start;

typedef struct {
    bool complete;
    int k;
    int m;
    long trials;
    int prefix_size;
    int s[MAX_SET];
    bool diffs[MAX_DIFFS];
    int current;
    int low;
} DIFF_VARS;

DIFF_VARS *pdv_global;

void sieve(void);
int cmp_int(const void *a, const void *b);
bool find_difference_set(DIFF_VARS *pdv);
bool push(int a, DIFF_VARS *pdv);
int pop(DIFF_VARS *pdv);
void final_status();


void reset_progress(DIFF_VARS *pdv);
void progress(DIFF_VARS *pdv);
void print_trace(DIFF_VARS *pdv);
void print_ints(FILE *pfile, int count, int nums[]);

void commas(long, char *);
void insert_string(char *, char *);

int main(int argc, char *argv[]) {
    int start;
    int end;

    sieve();
    fprintf(stderr, "Primes and prime powers: ");
    print_ints(stderr, pcount, primes);
    fprintf(stderr, "\n");

    DIFF_VARS *pdv = (DIFF_VARS *) calloc(1, sizeof(DIFF_VARS));
    pdv_global = pdv;

    // difference <start k> <end k>
    start = 2;
    end = MAX_SET;
    // difference <start k>
    if (argc > 1) {
        sscanf(argv[1], "%d", &start);
        end = start;
    }

    // difference <start k> <end k>
    if (argc == 3) {
        sscanf(argv[2], "%d", &end);
    }

    // differece <k> <prefix-1> <prefix-2> ...
    if (argc > 3) {
        pdv->prefix_size = argc - 2;
        for (int i = 0; i < pdv->prefix_size; i++) {
            sscanf(argv[i + 2], "%d", &pdv->s[i]);
        }
    }

    signal(SIGINT, final_status);

    fprintf(stderr, "Calculating difference sets from k = %d to k = %d.\n", start, end);
    if (pdv->prefix_size > 0) {
        fprintf(stderr, "Prefix: ");
        print_ints(stderr, pdv->prefix_size, pdv->s);
        fprintf(stderr, "\n");
    }

    for (int i = 0; i < pcount; i++) {
        int k = primes[i] + 1;
        if (k > end) {
            break;
        }
        if (k < start) {
            continue;
        }

        pdv->k = k;

        if (find_difference_set(pdv)) {
            print_trace(pdv);
        } else {
            fprintf(stderr, "No solution.");
        }
        final_status(0);
    }

    return 0;
}

void final_status(int sig_num) {
    char buff[20];

    if (sig_num != 0) {
        fprintf(stderr, "Program terminated (%d).\n", sig_num);
        print_trace(pdv_global);
    }
    commas(pdv_global->trials, buff);
    fprintf(stderr, "\nTotal Trials: %s\n", buff);

    if (sig_num != 0) {
        exit(sig_num);
    }
}

void sieve() {
    /// Return all prime powers less than or equal to n in primes[]
    int s[MAX_SET];
    for (int i = 0; i < MAX_SET; i++) {
        s[i] = 0;
    }

    int sq = (int) sqrt((float) MAX_SET);

    primes[pcount++] = 1;
    for (int i = 2; i < MAX_SET; i++) {
        if (s[i]) continue;
        primes[pcount++] = i;
        if (i > sq) continue;
        for (int j = i * i; j < MAX_SET; j += i) {
            s[j] = true;
        }
        int power = i * i;
        while (power < MAX_SET) {
            primes[pcount++] = power;
            power *= i;
        }
    }
    qsort(primes, pcount, sizeof(int), cmp_int);
}

int cmp_int(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

bool find_difference_set(DIFF_VARS *pdv) {
    int candidate;

    pdv->m = pdv->k * (pdv->k - 1) + 1;

    fprintf(stderr, "\nDifference set (k = %d, m = %d):\n", pdv->k, pdv->m);

    pdv->low = 0;
    pdv->diffs[0] = true;
    for (int i = 1; i <= pdv->m / 2; i++) {
        pdv->diffs[i] = false;
    }

    pdv->current = 0;
    if (pdv->prefix_size == 0) {
        push(0, pdv);
        push(1, pdv);
        pdv->prefix_size = 2;
    } else {
        int i;
        for (i = 0; i < pdv->prefix_size; i++) {
            push(pdv->s[i], pdv);
        }
    }
    candidate = pdv->s[pdv->current - 1] + pdv->low + 1;

    reset_progress(pdv);

    FOREVER {
        progress(pdv);

        // if candidate is feasible, push on
        if (push(candidate, pdv)) {
            if (pdv->current == pdv->k) {
                pdv->complete = true;
                return true;
            }
            candidate += pdv->low + 1;
            continue;
        }

        // n is not feasible - try next value
        candidate++;

        // Can't work - backtrack
        if (candidate + (pdv->low + 1) * (pdv->k - pdv->current - 1) >= pdv->m - pdv->low) {
            if (pdv->current < pdv->prefix_size) {
                pdv->complete = true;
                return false;
            }
            candidate = pop(pdv) + 1;
        }
    }
}

bool push(int a, DIFF_VARS *pdv) {
    int d;

    for (int i = 0; i < pdv->current; i++) {
        d = a - pdv->s[i];
        if (d > pdv->m / 2) {
            d = pdv->m - d;
        }
        if (pdv->diffs[d]) {
            for (int j = 0; j < i; j++) {
                d = a - pdv->s[j];
                if (d > pdv->m / 2) {
                    d = pdv->m - d;
                }
                pdv->diffs[d] = false;
            }
            return false;
        }
        pdv->diffs[d] = true;
    }
    pdv->s[pdv->current++] = a;

    while (pdv->low < pdv->m / 2 && pdv->diffs[pdv->low + 1]) {
        pdv->low++;
    }

    return true;
}

int pop(DIFF_VARS *pdv) {
    int a = pdv->s[--pdv->current];
    for (int i = 0; i < pdv->current; i++) {
        int d = a - pdv->s[i];
        if (d > pdv->m / 2) {
            d = pdv->m - d;
        }
        pdv->diffs[d] = false;
        if (d <= pdv->low) {
            pdv->low = d - 1;
        }
    }
    return a;
}

void reset_progress(DIFF_VARS *pdv) {
    start = time(NULL);
    pdv->trials = 0;
}

void progress(DIFF_VARS *pdv) {
    char buff[20];

    pdv->trials++;
    if (pdv->trials % PROGRESS != 0) {
        return;
    }

    commas(pdv->trials, buff);
    fprintf(stderr, "Trials %s: ", buff);
    print_trace(pdv);
    time_t now = time(NULL);
    int elapsed = (int) (now - start);
    commas(PROGRESS / elapsed, buff);
    fprintf(stderr, " (%s per sec)\n", buff);
    start = now;
}

void print_trace(DIFF_VARS *pdv) {
    print_ints(stderr, pdv->current, pdv->s);
    fprintf(stderr, " (low = %d)", pdv->low);
}

void print_ints(FILE *pfile, int count, int nums[]) {
    char *sep = "";
    while (count--) {
        fprintf(pfile, "%s%d", sep, *nums++);
        sep = ", ";
    }
}

void commas(long l, char *buff) {
    sprintf(buff, "%ld", l);
    char *end = buff + strlen(buff) - 3;
    while (end > buff) {
        insert_string(end, ",");
        end -= 3;
    }
}

void insert_string(char *buff, char *s) {
    int cch = strlen(s);

    char *pchFrom = buff + strlen(buff);
    char *pchTo = pchFrom + cch;
    while (pchFrom >= buff) {
        *pchTo-- = *pchFrom--;
    }
    pchFrom = s + cch - 1;
    while (pchTo >= buff) {
        *pchTo-- = *pchFrom--;
    }
}
