#include <stdio.h>

typedef enum {false, true} bool;

#define MAX_SET 20
#define MAX_DIFFS (MAX_SET * (MAX_SET - 1) + 1)
#define FOREVER for (;;)

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
    int trials = 0;

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
                printf("Trials: %d\n", trials);
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
                printf("Trials: %d\n", trials);
                return false;
            }
            remove_diffs(d, &hist[stack[next - 1]], &hist[stack[next]]);
        }
    }
}

int main(int argc, char *argv[]) {
    int s[MAX_SET];

    for (int k = 2; k < MAX_SET; k++) {
        printf("Search for difference set k = %d\n", k);
        if (find_difference_set(k, s)) {
            printf("[");
            char *sep = "";
            for (int i = 0; i < k; i++) {
                printf("%s%d", sep, s[i]);
                sep = ", ";
            }
            printf("]\n");
        }
    }

    return 0;
}
