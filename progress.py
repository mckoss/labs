#!/usr/bin/env python
import time

class Progress(object):
    units = (('sec', 1),
             ('min', 60),
             ('hr', 60),
             ('day', 24),
             ('wk', 7),
             ('month', 4))
    def __init__(self, increment=10000, name='Progress', report_rate=5):
        self.name = name
        self.increment = increment
        self.report_rate = report_rate
        self.reset()

    def reset(self):
        self.count = 0
        self.start_time = time.time()

    def report(self):
        self.count += 1
        if self.count < self.increment:
            return
        dt = time.time() - self.start_time
        rate = float(self.increment) / dt
        self.increment = int(self.increment * self.report_rate / dt)
        for unit in self.units:
            rate /= unit[1]
            if rate >= 1:
                break

        print "{:s}: {:0,.2f}/{:s} ...".format(self.name, rate, unit[0])
        self.reset()
