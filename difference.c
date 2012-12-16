#include <stdio.h>
#include <math.h>
#include <time.h>

typedef enum {false, true} bool;

#define MAX_SET 20
#define MAX_DIFFS (MAX_SET * (MAX_SET - 1) + 1)
#define FOREVER for (;;)

int primes[MAX_DIFFS];
int pcount = 0;

void sieve() {
    /// Return all prime powers less than or equal to n in primes[]
    int s[MAX_SET];
    for (int i = 0; i < MAX_SET; i++) {
        s[i] = 0;
    }

    int sq = (int) sqrt((float) MAX_SET);

    for (int i = 2; i <= MAX_SET; i++) {
        if (s[i]) continue;
        primes[pcount++] = i;
        if (i > sq) continue;
        for (int j = i * i; j <= MAX_SET; j += i) {
            s[j] = true;
        }
        int power = i * i;
        while (power <= MAX_SET) {
            s[power] = false;
            power *= i;
        }
    }
}

void remove_diffs(int d[], int *dFirst, int *dMax) {
    while (dFirst < dMax) {
        d[*dFirst++] = 0;
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

    s[0] = 0; s[1] = 1;
    stack[0] = 0;

    for (i = 0; i < m; i++) {
        d[i] = false;
    }

    FOREVER {
        trials++;
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
                printf("Trials: %ld\n", trials);
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
                printf("Trials: %ld\n", trials);
                return false;
            }
            remove_diffs(d, &hist[stack[next - 1]], &hist[stack[next]]);
        }
    }
}

int main(int argc, char *argv[]) {
    int s[MAX_SET];
    time_t start;

    sieve();
    for (int x = 0; x < pcount; x++) {
        printf("%d ", primes[x]);
    }

    for (int k1 = 0; k1 < pcount; k1++) {
        int k = primes[k1] + 1;
        printf("Difference set (v = %d, k = %d, 1):\n", k * (k - 1) + 1, k);
        start = time(NULL);
        if (find_difference_set(k, s)) {
            printf("[");
            char *sep = "";
            for (int i = 0; i < k; i++) {
                printf("%s%d", sep, s[i]);
                sep = ", ";
            }
            printf("]\n");
        }
        printf("Elapsed time: %ds.\n\n", (int) (time(NULL) - start));
    }

    return 0;
}
