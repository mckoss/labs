/* ================================================================
   difference.c - Difference Set generator.

   Calculate difference sets of various sizes - using threading library
   to maximize CPU cores in the search.

   This program implements exhaustive search and ensures finding the
   difference set with smallest topological value.

   Copyright 2013, Mike Koss

   Todo:

   - Option to continue search from a pause point (not a required prefix)
   - Option to return all solutions (not just first found).
`================================================================== */
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
#include <unistd.h>

typedef enum {false, true} bool;
typedef unsigned char byte;

#define MAX_SET 120
#define MAX_DIFFS (MAX_SET * (MAX_SET - 1) + 1)
#define FOREVER for (;;)
#define NUM_THREADS 4

long all_trials;
time_t last_time;
long last_trials;

typedef struct {
    int prime;
    int prime_power;
} PRIME_POWER;

PRIME_POWER prime_powers[MAX_SET];
int pcount = 0;

typedef enum {thread_idle, thread_running, thread_complete} thread_status;

typedef struct {
    int thread_num;
    thread_status status;
    int k;
    int v;
    long trials;
    int prefix_size;
    int target_depth;
    int current;
    int low;
    int s[MAX_SET];
    byte diffs[MAX_DIFFS];
} DIFF_VARS;

DIFF_VARS *diff_vars = NULL;

void expect(int value, int expected, char *message);
void usage();
void sieve(void);
int cmp_prime_powers(const void *a, const void *b);
void *find_difference_set(void *ptr);
void *search_next(DIFF_VARS *pdv, int candidate);
bool push(int a, DIFF_VARS *pdv);
int pop(DIFF_VARS *pdv);
void shift(int delta, DIFF_VARS *pdv);
void reset_status();
void print_status();

void singer_theorem(int root, DIFF_VARS *pdv);

void print_trace(DIFF_VARS *pdv);
void print_ints(FILE *pfile, int count, int nums[]);

char *commas(long, char *);
void right_justify(char *s, int width);
void insert_string(char *, char *);

int main(int argc, char *argv[]) {
    int start;
    int end;
    pthread_t threads[NUM_THREADS];
    bool continue_flag = false;
    bool singer_flag = false;

    int iarg = 1;
    while (iarg < argc && argv[iarg][0] == '-') {
        expect(strlen(argv[iarg]), 2,
               "Invalid flag.");
        switch (argv[iarg][1]) {
        case 'h':
            usage();
            break;
        case 'c':
            continue_flag = true;
            break;
        case 's':
            singer_flag = true;
            break;
        default:
            fprintf(stderr, "Unknown flag -%c.\n", argv[iarg][1]);
            usage();
            break;
        }
        iarg++;
    }

    start = 2;
    end = MAX_SET;

    // difference <start k>
    if (argc > iarg) {
        expect(sscanf(argv[iarg], "%d", &start), 1,
               "Invalid value for k.");
        end = start;
        iarg++;
    }

    // difference <start k> <end k>
    if (argc == iarg + 1) {
        expect(sscanf(argv[iarg], "%d", &end), 1,
               "Invalid value for [end].");
        iarg++;
    }

    // differece <k> <prefix-1> <prefix-2> ...
    int prefix_size = 0;
    int prefix[MAX_SET];
    if (argc > iarg) {
        expect(singer_flag, false, "Cannot use Singer theorem with a provided prefix.");
        prefix_size = argc - iarg;
        for (int i = 0; i < prefix_size; i++) {
            sscanf(argv[iarg + i], "%d", &prefix[i]);
        }
    } else {
        prefix_size = 2;
        prefix[0] = 0;
        prefix[1] = 1;
    }

    sieve();

    signal(SIGINT, print_status);

    fprintf(stderr, "Calculating difference sets from k = %d to k = %d.\n", start, end);
    fprintf(stderr, "Prefix: ");
    print_ints(stderr, prefix_size, prefix);
    fputc('\n', stderr);

    for (int i = 0; i < pcount; i++) {
        int k = prime_powers[i].prime_power + 1;
        int prime = prime_powers[i].prime;
        int v = k * (k - 1) + 1;
        DIFF_VARS parent_diff;

        if (k < start) {
            continue;
        }

        if (k > end) {
            break;
        }

        fprintf(stderr, "\nDifference set (k = %d, v = %d, lambda = 1):\n", k, v);

        memset(&parent_diff, 0, sizeof(parent_diff));

        parent_diff.thread_num = -1;
        parent_diff.k = k;
        parent_diff.v = v;
        parent_diff.prefix_size = prefix_size;
        parent_diff.target_depth = prefix_size + 2;
        memcpy(parent_diff.s, prefix, sizeof(int) * prefix_size);

        if (singer_flag) {
            singer_theorem(prime, &parent_diff);
            parent_diff.prefix_size = parent_diff.current;
            parent_diff.target_depth = parent_diff.prefix_size + 1;
        }

        find_difference_set(&parent_diff);
        if (continue_flag) {
            parent_diff.prefix_size = 0;
        }

        if (parent_diff.current == parent_diff.k) {
            printf("%3d: ", parent_diff.k);
            print_ints(stdout, parent_diff.current, parent_diff.s);
            fputc('\n', stdout);
            continue;
        }

        diff_vars = calloc(NUM_THREADS, sizeof(DIFF_VARS));

        reset_status();
        int num_solved = 0;
        FOREVER {
            bool num_ready = 0;

            for (int i = 0; i < NUM_THREADS; i++) {
                switch (diff_vars[i].status) {
                case thread_complete:
                    pthread_join(threads[i], NULL);
                    diff_vars[i].status = thread_idle;

                    all_trials += diff_vars[i].trials;
                    if (diff_vars[i].current == diff_vars[i].k) {
                        printf("%3d: ", diff_vars[i].k);
                        print_ints(stdout, diff_vars[i].current, diff_vars[i].s);
                        fputc('\n', stdout);
                        num_solved++;
                    } else {
                        print_trace(&diff_vars[i]);
                    }
                    // Fall through
                case thread_idle:
                    if (!num_solved && parent_diff.current == parent_diff.target_depth) {
                        memcpy(&diff_vars[i], &parent_diff, sizeof(DIFF_VARS));
                        diff_vars[i].thread_num = i;
                        diff_vars[i].prefix_size = parent_diff.current;
                        diff_vars[i].target_depth = 0;
                        diff_vars[i].status = thread_running;

                        pthread_create(&threads[i],
                                       NULL,
                                       find_difference_set,
                                       (void *) &diff_vars[i]);
                        search_next(&parent_diff, pop(&parent_diff) + 1);
                    } else {
                        num_ready++;
                    }
                    break;
                case thread_running:
                    break;
                }
            }

            usleep(1000);
            print_status(0);
            if (num_ready == NUM_THREADS) {
                break;
            }
        }

        free(diff_vars);
        diff_vars = NULL;
    }

    return 0;
}

void expect(int value, int expected, char *message) {
    if (value == expected) {
        return;
    }
    fputs(message, stderr);
    fputc('\n', stderr);
    usage();
}

void usage() {
    fprintf(stderr, "Usage: difference [-s] [k-start] [k-end]]\n");
    fprintf(stderr, "       difference [-c] [k] [prefix1 prefix 2 ...]\n");
    fprintf(stderr, "Find difference sets of order k.\n");
    fputc('\n', stderr);
    fprintf(stderr, "    -h: Help - print this usage statement.\n");
    fprintf(stderr, "    -c: Continue beyond point where prefix is exhausted.\n");
    fprintf(stderr, "    -s: Use Singer theorem to construct prime-power order v-1 sets.\n");
    exit(1);
}

void reset_status() {
    all_trials = 0;
    last_time = time(NULL);
    last_trials = 0;
}

void print_status(int sig_num) {
    long cum_trials = all_trials;
    time_t now = time(NULL);
    time_t elapsed = now - last_time;

    if (sig_num == 0 && elapsed < 1.0) {
        return;
    }

    if (sig_num != 0) {
        fprintf(stderr, "Program terminated (%d).\n", sig_num);
    }

    for (int i = 0; i < NUM_THREADS; i++) {
        print_trace(&diff_vars[i]);
        cum_trials += diff_vars[i].trials;
    }
    if (elapsed > 0) {
        char cum_trials_string[20];
        char rate_string[20];

        commas(cum_trials, cum_trials_string);
        fprintf(stderr, "Cumulative trials: %s (%s/sec)\n",
                cum_trials_string,
                commas((long) ((cum_trials - last_trials) / elapsed), rate_string));
    }
    last_trials = cum_trials;
    last_time = now;

    if (sig_num != 0) {
        exit(sig_num);
    }
}

void *find_difference_set(void *ptr) {
    int candidate;
    DIFF_VARS *pdv = (DIFF_VARS *) ptr;

    pdv->status = thread_running;
    pdv->trials = 0;
    pdv->low = 0;
    pdv->diffs[0] = true;
    for (int i = 1; i <= pdv->v / 2; i++) {
        pdv->diffs[i] = false;
    }

    pdv->current = 0;
    for (int i = 0; i < pdv->prefix_size; i++) {
        push(pdv->s[i], pdv);
    }

    return search_next(pdv, pdv->s[pdv->current - 1] + pdv->low + 1);
}

void *search_next(DIFF_VARS *pdv, int candidate) {
    FOREVER {
        pdv->trials++;

        // if candidate is feasible, push on
        if (push(candidate, pdv)) {
            if (pdv->current == pdv->k) {
                pdv->status = thread_complete;
                return NULL;
            } else if (pdv->current == pdv->target_depth) {
                pdv->status = thread_complete;
                return NULL;
            }
            candidate += pdv->low + 1;
            continue;
        }

        // n is not feasible - try next value
        candidate++;

        // Can't work - backtrack
        if (candidate + (pdv->low + 1) * (pdv->k - pdv->current - 1) >= pdv->v - pdv->low) {
            if (pdv->current <= pdv->prefix_size) {
                pdv->status = thread_complete;
                return NULL;
            }
            candidate = pop(pdv) + 1;
        }
    }
}

// Try powers of prime power (k - 1).
void singer_theorem(int prime, DIFF_VARS *pdv) {
    pdv->trials = 0;
    pdv->low = 0;
    pdv->diffs[0] = true;
    for (int i = 1; i <= pdv->v / 2; i++) {
        pdv->diffs[i] = false;
    }

    pdv->current = 0;

    int pp = prime;
    while (push(pp, pdv)) {
        pp *= prime;
        pp %= pdv->v;
    }

    fprintf(stderr, "Powers of %3d: ", prime);
    print_trace(pdv);

    shift(-pdv->s[pdv->current - 1], pdv);
    fprintf(stderr, "Shifted      : ");
    print_trace(pdv);
}

bool push(int a, DIFF_VARS *pdv) {
    int d;

    if (a >= pdv->v) {
        return false;
    }

    for (int i = 0; i < pdv->current; i++) {
        d = a - pdv->s[i];
        if (d > pdv->v / 2) {
            d = pdv->v - d;
        }
        if (pdv->diffs[d]) {
            for (int j = 0; j < i; j++) {
                d = a - pdv->s[j];
                if (d > pdv->v / 2) {
                    d = pdv->v - d;
                }
                pdv->diffs[d] = false;
            }
            return false;
        }
        pdv->diffs[d] = true;
    }
    pdv->s[pdv->current++] = a;

    while (pdv->low < pdv->v / 2 && pdv->diffs[pdv->low + 1]) {
        pdv->low++;
    }

    return true;
}

int pop(DIFF_VARS *pdv) {
    int a = pdv->s[--pdv->current];
    for (int i = 0; i < pdv->current; i++) {
        int d = a - pdv->s[i];
        if (d > pdv->v / 2) {
            d = pdv->v - d;
        }
        pdv->diffs[d] = false;
        if (d <= pdv->low) {
            pdv->low = d - 1;
        }
    }
    return a;
}

void shift(int delta, DIFF_VARS *pdv) {
    if (delta < 0) {
        delta += pdv->v;
    }
    for (int i = 0; i < pdv->current; i++) {
        pdv->s[i] = (pdv->s[i] + delta) % pdv->v;
    }
}

void print_trace(DIFF_VARS *pdv) {
    char trials_string[20];
    char *complete = pdv->status == thread_complete ? "*" : "";
    char *solved = pdv->current == pdv->k ? " SOLVED" : "";

    commas(pdv->trials, trials_string);
    right_justify(trials_string, 15);

    fprintf(stderr, "%d%s: (%d, %d) @%s: ", pdv->thread_num, complete, pdv->k, pdv->v, trials_string);
    print_ints(stderr, pdv->current, pdv->s);
    fprintf(stderr, " (low = %d)%s\n", pdv->low, solved);
}

// Return all prime powers less than or equal to n in prime_powers[]
void sieve() {
    int s[MAX_SET];
    for (int i = 0; i < MAX_SET; i++) {
        s[i] = 0;
    }

    int sq = (int) sqrt((float) MAX_SET);

    prime_powers[pcount].prime = 1;
    prime_powers[pcount++].prime_power = 1;
    for (int i = 2; i < MAX_SET; i++) {
        if (s[i]) continue;
        prime_powers[pcount].prime = i;
        prime_powers[pcount++].prime_power = i;
        if (i > sq) continue;
        for (int j = i * i; j < MAX_SET; j += i) {
            s[j] = true;
        }
        int power = i * i;
        while (power < MAX_SET) {
            prime_powers[pcount].prime = i;
            prime_powers[pcount++].prime_power = power;
            power *= i;
        }
    }
    qsort(prime_powers, pcount, sizeof(PRIME_POWER), cmp_prime_powers);
}

int cmp_prime_powers(const void *a, const void *b) {
    return ((PRIME_POWER *) a)->prime_power - ((PRIME_POWER *) b)->prime_power;
}

void print_ints(FILE *pfile, int count, int nums[]) {
    char *sep = "";
    while (count--) {
        fprintf(pfile, "%s%3d", sep, *nums++);
        sep = ", ";
    }
}

char *commas(long l, char *buff) {
    sprintf(buff, "%ld", l);
    char *end = buff + strlen(buff) - 3;
    while (end > buff) {
        insert_string(end, ",");
        end -= 3;
    }
    return buff;
}

void right_justify(char *s, int width) {
    int cch = strlen(s);
    char spaces[128];
    char *pch;

    if (cch >= width) {
        return;
    }
    for (pch = spaces; pch < spaces + width - cch; pch++) {
        *pch = ' ';
    }
    *pch = '\0';
    insert_string(s, spaces);
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
