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
    def __init__(self, increment=10000, name='Progress', report_rate=5):
        self.name = name
        self.increment = increment
        self.report_rate = report_rate
        self.count = 0
        self.total_count = 0
        self.reset()

    def reset(self):
        self.total_count += self.count
        self.count = 0
        self.start_time = time.time()

    def report(self, status=None, final=False):
        self.count += 1
        if not final and self.count < self.increment:
            return
        dt = time.time() - self.start_time
        rate = float(self.increment) / dt
        if not final:
            self.increment = int(self.count * self.report_rate / dt)
        for unit in self.units:
            rate /= unit[1]
            if rate >= 1:
                break

        sys.stderr.write("{:s}: {:0,.2f}/{:s} ...\n".format(self.name, rate, unit[0]))
        if status is not None:
            sys.stderr.write("%r\n" % (status,))
        self.reset()
        if final:
            sys.stdout.write("Total progress count: {:0,d}\n".format(self.total_count))
