#!/usr/bin/env python
from progress import Progress


class Runner(object):
    def __init__(self, func):
        self.func = func
        self.options = []
        self.choices = []
        self.progress = Progress(report_rate=1)

    def run(self, *args):
        while True:
            try:
                self.progress.report(self.choices)
                self.call_number = 0
                result = self.func(self.amb, *args)
                break
            except Fail:
                self.next_choice()
                continue
        self.progress.report(final=True)
        return result

    def amb(self, choices=None):
        if self.call_number == len(self.options):
            if choices is None:
                choices = [False, True]
            self.options.append(choices)
            self.choices.append(0)
        self.call_number += 1
        choice = self.choices[self.call_number - 1]
        if isinstance(choices, (int, long)):
            if choices == 0:
                raise Fail
            return choice
        return self.options[self.call_number - 1][choice]

    def next_choice(self):
        self.options = self.options[:self.call_number + 1]
        self.choices = self.choices[:self.call_number + 1]
        self.choices[-1] += 1
        while True:
            if isinstance(self.options[-1], (int, long)):
                if self.choices[-1] < self.options[-1]:
                    break
            elif self.choices[-1] < len(self.options[-1]):
                break

            self.choices.pop()
            self.options.pop()
            self.choices[-1] += 1


class Fail(Exception):
    pass


