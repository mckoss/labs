#include <stdio.h>

typedef enum {false, true} bool;

#define MAX_SET 20

bool find_difference_set(int k, int s[]) {
    int m = k * (k - 1) + 1;
    int next = 1;

    s[0] = 0; s[1] = 1;
    return true;

    /*
    stack = [set()]
    next = 1

    progress = Progress()

    def test_number(n):
        progress.report((k, s[:next + 1]))

        d = stack[-1].copy()
        for i in range(next):
            if (n - s[i]) % m in d or (s[i] - n) % m in d:
                return None
            d.add((n - s[i]) % m)
            d.add((s[i] - n) % m)
        return d

    while True:
        d = test_number(s[next])
        if d is not None:
            if next == k - 1:
                progress.report(final=True)
                return s
            stack.append(d)
            s[next + 1] = s[next] + 2
            next += 1
            continue
        s[next] += 1
        if s[next] + 2 * (k - next - 1) >= m:
            s[next - 1] += 1
            stack.pop()
            next -= 1
            if next == 1:
                progress.report(final=True)
                return ()

    */
}

int main(int argc, char *argv[]) {
    int s[MAX_SET];

    for (int k = 2; k < MAX_SET; k++) {
        if (find_difference_set(k, s)) {
            printf("Found difference set k=%d\n", k);
        }
    }

    return 0;
}
