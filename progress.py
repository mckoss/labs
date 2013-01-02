#!/usr/bin/env python
import sys
import time


class Progress(object):
    units = (('sec', 1),
             ('min', 60),
             ('hr', 60),
             ('day', 24),
             ('wk', 7),
             ('month', 4))
    def __init__(self, name='Progress', report_rate=5):
        self.name = name
        self.increment = 5
        self.report_rate = report_rate
        self.count = 0
        self.total_count = 0
        self.start_time = time.time()
        self.reset()

    def reset(self):
        self.total_count += self.count
        self.count = 0
        self.interval_start = time.time()

    def get_count(self):
        return self.total_count + self.count

    def report(self, status=None, final=False):
        if not final:
            self.count += 1
            if self.count < self.increment:
                return

        dt = time.time() - self.interval_start
        rate = float(self.increment) / dt

        if not final:
            self.increment = int(self.count * self.report_rate / dt)

        for unit in self.units:
            rate /= unit[1]
            if rate >= 1:
                break

        self.reset()

        if self.total_count > 0:
            sys.stderr.write("{:,d}. {:s}: {:,.2f}/{:s} @ {:s}\n".format(self.total_count,
                                                                         self.name,
                                                                         rate,
                                                                         unit[0],
                                                                         status if status is not None else ''
                                                                         ))
        if final:
            sys.stdout.write("Total time {:,.2f} secs (count: {:,d})\n".format(time.time() - self.start_time,
                                                                               self.total_count))
