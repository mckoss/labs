import sys

DEBUG = False

exchanges = 0


def debug(*a):
    if DEBUG:
        sys.stderr.write(str(a) + '\n')


def quicksort(a):
    """
    simple quicksort implementation on array

    >>> quicksort([1, 2, 3])
    [1, 2, 3]
    >>> quicksort([3, 2, 1])
    [1, 2, 3]
    >>> quicksort([])
    []
    >>> quicksort([1, 1, 1, 2, 1, 1])
    [1, 1, 1, 1, 1, 2]
    """
    global exchanges

    exchanges = 0
    debug("quicksort")
    qs(a, 0, len(a))
    return a


def qs(a, start, end):
    # Tail recurse on smaller partition to avoid stack overflow.
    while True:
        debug(a, start, end)
        if end - start <= 1:
            return
        m = (start + end) / 2
        med(a, start, m, end - 1)
        s = partition(a, start, end)
        if s - start < end - s:
            qs(a, start, s)
            start = s
        else:
            qs(a, s, end)
            end = s


def partition(a, start, end):
    # partition elements s.t. a[i] <= a[0] for all i < s
    global exchanges

    pivot = a[start]
    s = start + 1
    for i in xrange(start + 1, end):
        if a[i] <= pivot:
            exchanges += 1
            a[s], a[i] = a[i], a[s]
            s += 1
    # all <= pivot - make at least 1 unit of progress
    if s == end:
        exchanges += 1
        a[start], a[end - 1] = a[end - 1], a[start]
        return end - 1
    return s


def med(a, start, mid, last):
    """ put median of 3 elts in a[start] using minimal compares and 1 swap

    There are 6 cases of orderings, (using 1, 2, 3 for low, med, high values):

       s  m  l
       -------
    1. 1, 2, 3
    2. 1, 3, 2
    3. 2, 1, 3
    4. 2, 3, 1
    5. 3, 1, 2
    6. 3, 2, 1

    Truth table for possible orderings based on these comparisons:

    s < m  s < l  m < l  Possible orderings
    -------------------------------------------
      F      F      F    356 & 456 & 246 = 6
      F      F      T    356 & 456 & 135 = 5
      F      T      F    356 & 123 & 246 = None
      F      T      T    356 & 123 & 135 = 3
      T      F      F    124 & 456 & 246 = 4
      T      F      T    124 & 456 & 135 = None
      T      T      F    124 & 123 & 246 = 2
      T      T      T    124 & 123 & 135 = 1

    >>> x = [1, 2, 3]; med(x, 0, 1, 2); x
    [2, 1, 3]
    >>> x = [1, 3, 2]; med(x, 0, 1, 2); x
    [2, 3, 1]
    >>> x = [2, 1, 3]; med(x, 0, 1, 2); x
    [2, 1, 3]
    >>> x = [2, 3, 1]; med(x, 0, 1, 2); x
    [2, 3, 1]
    >>> x = [3, 1, 2]; med(x, 0, 1, 2); x
    [2, 1, 3]
    >>> x = [3, 2, 1]; med(x, 0, 1, 2); x
    [2, 3, 1]
    """
    global exchanges

    SM = a[start] < a[mid]
    SL = a[start] < a[last]
    if SM != SL:
        return
    ML = a[mid] < a[last]
    m = mid if SM == ML else last
    a[start], a[m] = a[m], a[start]
    exchanges += 1


def is_sorted(a):
    for i in xrange(1, len(a)):
        if a[i] < a[i - 1]:
            return False
    return True


if __name__ == '__main__':
    import random
    from math import pow

    for p in xrange(7):
        size = int(pow(10, p))
        t = [random.randint(1, 1000000) for x in xrange(size)]
        quicksort(t)
        print size, is_sorted(t), exchanges, exchanges / size
