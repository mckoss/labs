#!/usr/bin/env python


class Hanoi(object):
    """
    Tower of Hanoi simulator.

    >>> h = Hanoi(2)
    >>> h.solve()
    Move 1 from A to B.
    Move 2 from A to C.
    Move 1 from B to C.
    >>> h = Hanoi(3)
    >>> h.solve()
    Move 1 from A to C.
    Move 2 from A to B.
    Move 1 from C to B.
    Move 3 from A to C.
    Move 1 from B to A.
    Move 2 from B to C.
    Move 1 from A to C.
    """
    peg_names = ('A', 'B', 'C')

    def __init__(self, size, display_steps=False):
        self.pegs = [range(size, 0, -1), [], []]
        self.display_steps = display_steps

    def display(self):
        print self.pegs

    def move(self, from_peg, to_peg):
        disc = self.pegs[from_peg].pop()
        self.pegs[to_peg].append(disc)
        if self.display_steps:
            self.display()
        else:
            print "Move %s from %s to %s." % (disc,
                                              self.peg_names[from_peg],
                                              self.peg_names[to_peg])

    def multi_move(self, num_discs, from_peg, to_peg, via_peg):
        if num_discs == 0:
            return
        self.multi_move(num_discs - 1, from_peg, via_peg, to_peg)
        self.move(from_peg, to_peg)
        self.multi_move(num_discs - 1, via_peg, to_peg, from_peg)

    def solve(self):
        self.multi_move(len(self.pegs[0]), 0, 2, 1)


if __name__ == '__main__':
    h = Hanoi(6, display_steps=True)
    h.solve()
