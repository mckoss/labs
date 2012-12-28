#include <stdio.h>
#include <math.h>
#include <time.h>
#include <string.h>

typedef enum {false, true} bool;

#define MAX_SET 30
#define MAX_DIFFS (MAX_SET * (MAX_SET - 1) + 1)
#define FOREVER for (;;)
#define PROGRESS 50000000

int primes[MAX_SET];
int pcount = 0;

long trials = 0;
time_t start;

int m;
int s[MAX_SET];
bool diffs[MAX_DIFFS];
int current;
int low;

void sieve(void);
bool find_difference_set(int k);
bool push(int a);
int pop();
void reset_progress();
void progress();

void commas(long, char *);
void insert_string(char *, char *);

int main(int argc, char *argv[]) {
    int start;
    int end;

    sieve();

    start = 2;
    end = MAX_SET;
    if (argc > 1) {
        sscanf(argv[1], "%d", &start);
        end = start;
    }
    if (argc > 2) {
        sscanf(argv[2], "%d", &end);
    }

    for (int i = 0; i < pcount; i++) {
        int k = primes[i] + 1;
        if (k > end) {
            break;
        }
        if (k < start) {
            continue;
        }
        if (find_difference_set(k)) {
            char *sep = "";
            for (int i = 0; i < k; i++) {
                printf("%s%d", sep, s[i]);
                sep = ", ";
            }
            printf("\n");
        }
    }

    return 0;
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
            s[power] = false;
            power *= i;
        }
    }
}

bool find_difference_set(int k) {
    int candidate;

    m = k * (k - 1) + 1;

    printf("\nDifference set (k = %d, m = %d):\n", k, m);

    s[0] = 0;
    current = 1;
    candidate = 1;

    diffs[0] = true;
    for (int i = 1; i <= m / 2; i++) {
        diffs[i] = false;
    }
    low = 0;

    reset_progress();

    FOREVER {
        progress(current, s);

        // if candidate is feasible, push on
        if (push(candidate)) {
            if (current == k) {
                return true;
            }
            candidate += low + 1;
            continue;
        }

        // n is not feasible - try next value
        candidate++;

        // Can't work - backtrack
        if (candidate + (low + 1) * (k - current - 1) >= m - low) {
            if (current == 1) {
                return false;
            }
            candidate = pop() + 1;
        }
    }
}

bool push(int a) {
    int d;

    for (int i = 0; i < current; i++) {
        d = a - s[i];
        if (d > m / 2) {
            d = m - d;
        }
        if (diffs[d]) {
            for (int j = 0; j < i; j++) {
                d = a - s[j];
                if (d > m / 2) {
                    d = m - d;
                }
                diffs[d] = false;
            }
            return false;
        }
        diffs[d] = true;
    }
    s[current] = a;
    current++;

    while (low < m / 2 && diffs[low + 1]) {
        low++;
    }

    return true;
}

int pop() {
    int a = s[--current];
    for (int i = 0; i < current; i++) {
        int d = a - s[i];
        if (d > m / 2) {
            d = m - d;
        }
        diffs[d] = false;
        if (d < low) {
            low = d - 1;
        }
    }
    return a;
}

void reset_progress() {
    start = time(NULL);
    trials = 0;
}

void progress() {
    char buff[20];

    trials++;
    if (trials % PROGRESS != 0) {
        return;
    }

    commas(trials, buff);
    printf("Progress (%s): ", buff);
    char *sep = "";
    for (int i = 0; i < current; i++) {
        printf("%s%d", sep, s[i]);
        sep = ", ";
    }
    time_t now = time(NULL);
    int elapsed = (int) (now - start);
    commas(PROGRESS / elapsed, buff);
    printf(" (%s per sec)\n", buff);
    start = now;
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
