#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
#include <unistd.h>

typedef enum {false, true} bool;

#define MAX_SET 33
#define MAX_DIFFS (MAX_SET * (MAX_SET - 1) + 1)
#define FOREVER for (;;)
#define NUM_THREADS 4

int primes[MAX_SET];
int pcount = 0;

time_t start;

typedef struct {
    int thread_num;
    bool complete;
    int k;
    int m;
    long trials;
    int prefix_size;
    int target_depth;
    int current;
    int low;
    int s[MAX_SET];
    bool diffs[MAX_DIFFS];
} DIFF_VARS;

DIFF_VARS *diff_vars = NULL;

void sieve(void);
int cmp_int(const void *a, const void *b);
void *find_difference_set(void *ptr);
bool push(int a, DIFF_VARS *pdv);
int pop(DIFF_VARS *pdv);
void final_status();

void print_trace(DIFF_VARS *pdv);
void print_ints(FILE *pfile, int count, int nums[]);

void commas(long, char *);
void insert_string(char *, char *);

int main(int argc, char *argv[]) {
    int start;
    int end;
    pthread_t threads[NUM_THREADS];

    sieve();
    fprintf(stderr, "Prime powers: ");
    print_ints(stderr, pcount, primes);
    fprintf(stderr, "\n");

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
    int prefix_size = 0;
    int prefix[MAX_SET];
    if (argc > 3) {
        prefix_size = argc - 2;
        for (int i = 0; i < prefix_size; i++) {
            sscanf(argv[i + 2], "%d", &prefix[i]);
        }
    }

    signal(SIGINT, final_status);

    fprintf(stderr, "Calculating difference sets from k = %d to k = %d.\n", start, end);
    if (prefix_size > 0) {
        fprintf(stderr, "Prefix: ");
        print_ints(stderr, prefix_size, prefix);
        fprintf(stderr, "\n");
    }

    for (int i = 0; i < pcount; i++) {
        int k = primes[i] + 1;
        int m = k * (k - 1) + 1;
        if (k > end) {
            break;
        }
        if (k < start) {
            continue;
        }

        fprintf(stderr, "\nDifference set (k = %d, m = %d):\n", k, m);

        diff_vars = calloc(NUM_THREADS, sizeof(DIFF_VARS));

        for (int i = 0; i < NUM_THREADS; i++) {
            diff_vars[i].thread_num = i;
            diff_vars[i].k = k;
            diff_vars[i].m = m;
            diff_vars[i].prefix_size = prefix_size;

            for (int j = 0; j < prefix_size; j++) {
                diff_vars[i].s[j] = prefix[j];
            }
        }

        for (int i = 0; i < NUM_THREADS; i++) {
            pthread_create(&threads[i], NULL, find_difference_set, (void *) &diff_vars[i]);
        }

        FOREVER {
            bool all_complete = true;
            for (int i = 0; i < NUM_THREADS; i++) {
                if (!diff_vars[i].complete) {
                    all_complete = false;
                }
                print_trace(&diff_vars[i]);
            }
            if (all_complete) {
                break;
            }
            sleep(5);
        }

        void *results;
        for (int i = 0; i < NUM_THREADS; i++) {
            pthread_join(threads[i], &results);
            if (results) {
                print_trace(&diff_vars[i]);
            } else {
                fprintf(stderr, "No solution for thread %d.\n", i);
            }
        }

        final_status(0);

        free(diff_vars);
        diff_vars = NULL;
    }

    return 0;
}

void final_status(int sig_num) {
    char buff[20];

    if (sig_num != 0) {
        fprintf(stderr, "Program terminated (%d).\n", sig_num);
    }

    if (diff_vars) {
        for (int i = 0; i < NUM_THREADS; i++) {
            print_trace(&diff_vars[i]);
        }
    }

    if (sig_num != 0) {
        exit(sig_num);
    }
}

int cmp_int(const void *a, const void *b) {
    return *(int *)a - *(int *)b;
}

void *find_difference_set(void *ptr) {
    int candidate;
    DIFF_VARS *pdv = (DIFF_VARS *) ptr;

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

    FOREVER {
        pdv->trials++;

        // if candidate is feasible, push on
        if (push(candidate, pdv)) {
            if (pdv->current == pdv->k) {
                pdv->complete = true;
                return pdv;
            } else if (pdv->current == pdv->target_depth) {
                return pdv;
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
                return NULL;
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

void print_trace(DIFF_VARS *pdv) {
    char buff[20];

    commas(pdv->trials, buff);

    fprintf(stderr, "%d: (%d, %d) @%s: ", pdv->thread_num, pdv->k, pdv->m, buff);
    print_ints(stderr, pdv->current, pdv->s);
    fprintf(stderr, " (low = %d)\n", pdv->low);
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
