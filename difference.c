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

void sieve(void);
bool find_difference_set(int k, int s[]);
void remove_diffs(int d[], int *dFirst, int *dMax);
void commas(long, char *);
void insert_string(char *, char *);

int main(int argc, char *argv[]) {
    int s[MAX_SET];
    int start;

    sieve();

    start = 2;
    if (argc > 1) {
        sscanf(argv[1], "%d", &start);
    }

    for (int i = 0; i < pcount; i++) {
        int k = primes[i] + 1;
        if (k < start) {
            continue;
        }
        printf("\nDifference set (k = %d, m = %d):\n", k, k * (k - 1) + 1);
        if (find_difference_set(k, s)) {
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

bool find_difference_set(int k, int s[]) {
    int m = k * (k - 1) + 1;
    int d[MAX_DIFFS];
    int hist[MAX_DIFFS];
    int stack[MAX_SET];
    int next = 1;
    int n;
    int i;
    long trials = 0;
    time_t start = time(NULL);
    char buff[16];

    start = time(NULL);

    s[0] = 0; s[1] = 1;
    stack[0] = 0;

    for (i = 0; i < m; i++) {
        d[i] = false;
    }

    FOREVER {
        trials++;
        if (trials % PROGRESS == 0) {
            commas(trials, buff);
            printf("Progress (%s): ", buff);
            char *sep = "";
            for (i = 0; i < next; i++) {
                printf("%s%d", sep, s[i]);
                sep = ", ";
            }
            time_t now = time(NULL);
            int elapsed = (int) (now - start);
            commas(PROGRESS / elapsed, buff);
            printf(" (%s per sec)\n", buff);
            start = now;
        }
        n = s[next];
        stack[next] = stack[next - 1];
        // Test s[next] against previous elements.
        for (i = 0; i < next; i++) {
            int a = (m + n - s[i]) % m;
            int b = (m + s[i] - n) % m;
            if (d[a] || d[b]) {
                remove_diffs(d, &hist[stack[next - 1]], &hist[stack[next]]);
                break;
            }
            d[a] = d[b] = 1;
            hist[stack[next]++] = a;
            hist[stack[next]++] = b;
        }
        // s[next] is feasible
        if (i == next) {
            if (next == k - 1) {
                return true;
            }
            s[++next] = n + 2;
            continue;
        }
        // s[next] is not feasible - try next value
        s[next]++;
        // Can't work - backtrack
        if (s[next] + 2 * (k - next - 1) >= m) {
            s[--next]++;
            if (next == 1) {
                return false;
            }
            remove_diffs(d, &hist[stack[next - 1]], &hist[stack[next]]);
        }
    }
}

void remove_diffs(int d[], int *dFirst, int *dMax) {
    while (dFirst < dMax) {
        d[*dFirst++] = 0;
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
