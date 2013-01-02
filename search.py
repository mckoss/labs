from progress import Progress


class SearchSpace(object):
    """
    Abstract class defining a solution-space search (with backtracking).

    Simplifiies implementation by:

    - Organizing searching with backtracking.
    - Starting searches from known starting points.
    - Limiting searches to specified ending points.
    - Organizing workers to cooperatively search a space w/o overlap.

    All choices must be modeled as sequence of integers (from 0 to some maximum).
    """
    def __init__(self, start=None, end=None):
        if start is None:
            start = []
        self.choices = start
        if end is None:
            end = list(start)
            if len(end) > 0:
                end[-1] += 1
        self.end = end
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

    def step(self):
        """ Override:
        choice = self.choose()
        if self.is_valid(choice):
            self.accept()
            if is_solved():
                return self.choices
        """
        pass

    def is_finished(self):
        """ Stop when prefix of choice >= end. """
        if len(self.end) == 0:
            return self.depth == -1

        for i in range(min(len(self.choices), len(self.end))):
            if self.choices[i] > self.end[i]:
                return True
            if self.choices[i] < self.end[i]:
                return False

        return len(self.choices) >= len(self.end)

    def choose(self, limit, min=0, step=1):
        self.accepted = False
        if self.depth == len(self.limits):
            self.limits.append(limit)
        if self.depth == len(self.steps):
            self.steps.append(step)
        if self.depth == len(self.choices):
            self.choices.append(min)
        return self.choices[self.depth]

    def accept(self):
        self.accepted = True
        self.depth += 1

    def next(self):
        if self.accepted:
            self.accepted = False
            return

        # Backtrack to prior depth
        latest = self.depth
        depth = self.depth
        while depth >= 0:
            if depth < latest and hasattr(self, 'backtrack'):
                self.backtrack(self.choices[depth])
            self.choices[depth] += self.steps[depth]
            if self.choices[depth] < self.limits[depth]:
                break
            depth -= 1
            if depth == -1:
                break

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
