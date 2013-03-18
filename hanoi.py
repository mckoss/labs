#!/usr/bin/env python
from math import ceil, log
from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description="Solve n-disc Tower of Hanoi problem.")
    parser.add_argument('discs', type=int, default=6, nargs='?',
                        help="Number of discs")
    parser.add_argument('--moves', action='store_true', default=False,
                        help="Display disc moves.")
    parser.add_argument('--graph', action='store_true', default=False,
                        help="Display graphical discs.")
    args = parser.parse_args()
    if not args.graph:
        args.moves = True
    h = Hanoi(args.discs, show_moves=args.moves, show_graph=args.graph)
    h.solve()


class Hanoi(object):
    """
    Tower of Hanoi simulator.

    >>> h = Hanoi(2)
    >>> h.digits
    1
    >>> h.solve()
    1. Move 1 from A to B.
    2. Move 2 from A to C.
    3. Move 1 from B to C.
    >>> h = Hanoi(3, show_graph=True)
    >>> h.solve()
    1. Move 1 from A to C. 3-2||1
    2. Move 2 from A to B. 3|2|1
    3. Move 1 from C to B. 3|2-1|
    4. Move 3 from A to C. |2-1|3
    5. Move 1 from B to A. 1|2|3
    6. Move 2 from B to C. 1||3-2
    7. Move 1 from A to C. ||3-2-1
    """
    peg_names = ('A', 'B', 'C')

    def __init__(self, size, show_moves=True, show_graph=False):
        self.pegs = [range(size, 0, -1), [], []]
        self.show_moves = show_moves
        self.show_graph = show_graph
        self.moves = 0
        self.digits = int(ceil(log(2 ** size, 10)))

    def __str__(self):
        return ' | '.join(['-'.join(str(d) for d in peg) for peg in self.pegs])

    def move(self, from_peg, to_peg):
        self.moves += 1
        disc = self.pegs[from_peg].pop()
        self.pegs[to_peg].append(disc)

        line = '%*d.' % (self.digits, self.moves)
        if self.show_moves:
            line += " Move %s from %s to %s." % (disc,
                                                 self.peg_names[from_peg],
                                                 self.peg_names[to_peg])
        if self.show_graph:
            line += ' ' + str(self)

        print line

    def multi_move(self, num_discs, from_peg, to_peg, via_peg):
        if num_discs == 0:
            return
        self.multi_move(num_discs - 1, from_peg, via_peg, to_peg)
        self.move(from_peg, to_peg)
        self.multi_move(num_discs - 1, via_peg, to_peg, from_peg)

    def solve(self):
        self.multi_move(len(self.pegs[0]), 0, 2, 1)


if __name__ == '__main__':
    main()
