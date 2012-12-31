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

    def reset(self):
        self.depth = 0

    def complete(self):
        pass

    def run(self):
        while self.depth >= 0:
            self.reset()
            result = self.search()
            if result is not None:
                self.complete()
                return result
            self.next_choice()
        self.complete()


class SearchProgress(SearchSpace):
    def __init__(self, name='Search', report_rate=5):
        super(SearchProgress, self).__init__()
        self.progress = Progress(name=name, report_rate=report_rate)

    def reset(self):
        super(SearchProgress, self).reset()
        self.progress.report(self.choices)

    def complete(self):
        self.progress.report(self.choices, final=True)
