import os
from multiprocessing import cpu_count, Process, Queue

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
            return min
        if self.depth == len(self.limits):
            self.limits.append(limit)
            self.steps.append(step)
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
    def __init__(self, searcher=None, start=None, **kwargs):
        self.searcher = searcher
        self.start = start
        self.kwargs = kwargs
        self.child_length = len(start) + 1 if start is not None else 1

    def search(self):
        if cpu_count() == 1:
            s = self.searcher(start=start, **self.kwargs)
            return s.search()

        worker_count = cpu_count() * 2
        parent = self.searcher(**self.kwargs)
        workers = []
        work_queue = Queue()
        results_queue = Queue()
        for worker_number in range(worker_count):
            p = Process(target=SearchWorker, args=(self.searcher, work_queue, results_queue))
            p.start()
            workers.append(p)

        while True:
            prefix = parent.advance_to_depth(self.child_length)
            if prefix is None:
                break
            work_queue.put({'kwargs': self.kwargs,
                            'start': prefix})

        result = results_queue.get()

        for worker in workers:
            worker.terminate()

        return result


def SearchWorker(Searcher, work_queue, results_queue):
    while True:
        work = work_queue.get()
        s = Searcher(start=work['start'], **work['kwargs'])
        while True:
            result = s.search()
            if result is None:
                break
            results_queue.put(result)


if __name__ == '__main__':
    print "Root"
