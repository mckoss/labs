import os
from multiprocessing import cpu_count, Pool

from progress import Progress


class SearchSpace(object):
    """
    Abstract class defining a solution-space search (with backtracking).  This class
    searches a solution space that looks like a tree of integer valued options at each
    node.

    Simplifiies implementation by:

    - Organizing searching with backtracking.
    - Starting searches from known starting points.
    - Limiting searches to specified ending points.

    All choices must be modeled as sequence of integers (from 0 to some maximum).

    Usage:

        class MySearch(SearchSpace) # or class MySearch(SearchProgress, SearchSpace)
            def step(self):
                choice = self.choose(max_value)
                if self.is_feasible(choice):
                    self.accept()
                    if is_solved():
                        return self.choices

            def backtrack(self, choice):
                ...

         ss = MySearch()
         print ss.search()

    The step function will be called repeatedle with successive choices.  When accept is not called,
    the search continues at the next level of depth.

    When all the values at a given depth are exhausted, the search decreases the depth, and calls
    the backtrack function (if provided) to undo the effect of an earlier choice.  If no backtrack
    function is given, search will call your restart function, and restart the search from the root
    of the search tree (similar to use of the McCarthy's ambiguous function).
    """
    def __init__(self, start=None, stop=None):
        if start is None:
            start = []
        self.choices = list(start)
        if stop is None:
            self.guard = len(start) - 1
            if self.guard >= 0:
                self.guard_value = start[self.guard] + 1
        else:
            self.guard = len(stop) - 1
            if self.guard >= 0:
                self.guard_value = stop[self.guard]
        self.steps = []
        self.limits = []

        self.restart()

    def restart(self):
        self.depth = 0

    def search(self):
        while not self.is_finished():
            result = self.step()
            if result is not None:
                self.complete()
                return result
            self.next()

        self.complete()

    def advance_to_depth(self, target_depth):
        """ Advance to next feasible prefix of a given length. """
        if self.is_finished():
            return None

        while self.depth > target_depth:
            self.advance()

        if self.depth == target_depth:
            self.depth -= 1
            if hasattr(self, 'backtrack'):
                self.backtrack(self.choices[self.depth])
            self.advance()

        while not self.is_finished() and self.depth < target_depth:
            self.step()
            self.next()

        if not self.is_finished():
            return self.choices[:self.depth]

    def step(self):
        pass

    def is_finished(self):
        if self.depth == -1:
            return True
        if self.guard < 0:
            return False
        return len(self.choices) > self.guard and self.choices[self.guard] >= self.guard_value

    def choose(self, limit, min=0, step=1):
        self.accepted = False
        if self.depth == len(self.choices):
            self.choices.append(min)
            self.limits.append(limit)
            self.steps.append(step)
        elif self.depth == len(self.limits):
            self.limits.append(limit)
            self.steps.append(step)
        if min >= limit:
            return None
        return self.choices[self.depth]

    def accept(self):
        self.accepted = True
        self.depth += 1

    def next(self):
        if self.accepted:
            self.accepted = False
            return

        self.advance()

    def advance(self):
        provisional = self.depth
        depth = self.depth
        while depth >= 0:
            if depth < provisional and hasattr(self, 'backtrack'):
                self.backtrack(self.choices[depth])
            self.choices[depth] += self.steps[depth]
            if self.choices[depth] < self.limits[depth]:
                break
            depth -= 1

        if depth < provisional:
            self.depth = depth
            del self.choices[depth + 1:]
            del self.steps[depth + 1:]
            del self.limits[depth + 1:]

        if not hasattr(self, 'backtrack') and not self.is_finished():
            self.restart()

    def complete(self):
        pass


class SearchProgress(object):
    def __init__(self, name='Search', report_rate=5, **kwargs):
        super(SearchProgress, self).__init__(**kwargs)
        self.progress = Progress(name=name, report_rate=report_rate)

    def step(self):
        super(SearchProgress, self).step()
        self.progress.report(self.choices)

    def complete(self):
        super(SearchProgress, self).complete()
        self.progress.report(self.choices, final=True)


class MultiSearch(object):
    """ Employ mulitple worker processes to carry out a coordinated search. """
    def __init__(self, searcher=None, start=None, preorder=False, max_solutions=1, **kwargs):
        self.searcher = searcher
        self.max_solutions = max_solutions
        self.start = start
        self.kwargs = kwargs
        self.child_length = len(start) + 1 if start is not None else 1
        self.parent = self.searcher(**self.kwargs)
        self.worker_count = cpu_count()
        self.pool = Pool(self.worker_count)
        self.searchers = []

    def search(self, callback):
        self.callback = callback

        while True:
            prefix = self.parent.advance_to_depth(self.child_length)
            if prefix is None:
                break
            self.pool.apply_async(search_wrapper,
                                  args=(self.searcher, prefix),
                                  kwds=self.kwargs,
                                  callback=self.search_results)

    def search_results(self, result):
        print "search_results(%r)" % result
        self.max_solutions -= 1
        self.callback(result)

    def join(self):
        """ Wait until all workers stopped. """
        if self.max_solutions <= 0:
            self.pool.terminate()
        else:
            self.pool.close()
        self.pool.join()


def search_wrapper(Searcher, prefix, **kwargs):
    print "search_wrapper(%r)" % kwargs
    s = Searcher(start=prefix, **kwargs)
    return s.search()


if __name__ == '__main__':
    print "Root"
