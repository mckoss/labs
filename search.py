from progress import Progress


class RestartSearch(object):
    """
    Abstract class defining a solution-space search.  When an invalid configuration is found
    it restarts the search providing the next sequence of choices.

    Simplifiies implementation by:

    - Organizing searching with backtracking.
    - Starting searches from known starting points.
    - Limiting searches to specified ending points.
    - Organizing workers to cooperatively search a space w/o overlap.

    All choices must be modeled as sequence of integers (from 0 to some maximum).
    """
    def __init__(self):
        self.depth = 0
        self.choices = []
        self.limits = []

    def choose(self, limit):
        if self.depth == len(self.choices):
            self.limits.append(limit)
            value = 0
            self.choices.append(value)
        else:
            value = self.choices[self.depth]
        self.depth += 1
        return value

    def next_choice(self):
        while self.depth >= 0:
            self.depth -= 1
            if self.depth == -1:
                return
            self.choices[self.depth] += 1
            if self.choices[self.depth] < self.limits[self.depth]:
                break

        del self.choices[self.depth + 1:]
        del self.limits[self.depth + 1:]

    def search(self):
        pass

    def complete(self):
        pass

    def run(self):
        while self.depth >= 0:
            self.depth = 0
            self.step()
            result = self.search()
            if result is not None:
                self.complete()
                return result
            self.next_choice()
        self.complete()


class SearchProgress(object):
    def __init__(self, name='Search', report_rate=5):
        super(SearchProgress, self).__init__()
        self.progress = Progress(name=name, report_rate=report_rate)

    def step(self):
        self.progress.report(self.choices)

    def complete(self):
        super(SearchProgress, self).complete()
        self.progress.report(self.choices, final=True)


class BacktrackSearch(object):
    """
    Abstract class defining a solution-space search (with backtracking).

    Simplifiies implementation by:

    - Organizing searching with backtracking.
    - Starting searches from known starting points.
    - Limiting searches to specified ending points.
    - Organizing workers to cooperatively search a space w/o overlap.

    All choices must be modeled as sequence of integers (from 0 to some maximum).
    """
    def __init__(self):
        self.choices = []
        self.limits = []
        self.restart()

    def restart(self):
        self.depth = 0

    def run(self):
        while not self.is_finished():
            result = self.step()
            if result is not None:
                self.complete()
                return result
        self.complete()

    def is_finished(self):
        # TODO: Add start a limit sequences.
        return self.depth < 0

    def choose(self, limit):
        if self.depth == len(self.choices):
            self.limits.append(limit)
            value = 0
            self.choices.append(value)
        else:
            value = self.choices[self.depth]
        self.depth += 1
        return value

    def reject(self):
        """ Revert the last choice and prepare the next one. """
        latest = self.depth - 1
        while self.depth >= 0:
            self.depth -= 1
            if self.depth == -1:
                break
            if self.depth < latest:
                self.backtrack(self.choices[self.depth])
            self.choices[self.depth] += 1
            if self.choices[self.depth] < self.limits[self.depth]:
                break

        del self.choices[self.depth + 1:]
        del self.limits[self.depth + 1:]

    def complete(self):
        pass

    def backtrack(self, choice):
        """ If backtracking is not supported - a restart from the beginning works. """
        self.restart()
