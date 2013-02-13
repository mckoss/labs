from math import sqrt
from types import MethodType
from collections import deque
from functools import partial


class Game(object):
    def __init__(self, *Players):
        self._num_players = len(Players)
        self._players = [Players[i](GameProxy(self, i)) for i in xrange(self._num_players)]
        self._trials = 0
        self._scores = [0] * self._num_players
        self._sums = [0] * self._num_players
        self._sum_squares = [0] * self._num_players
        self._min = [0] * self._num_players
        self._max = [0] * self._num_players
        self.silent = False
        self.history = deque(maxlen=100)

    def simulate(self, total_games=100, trials=1000):
        self._games_per_trial = total_games
        for _trial in xrange(trials):
            for i in xrange(1, total_games + 1):
                self.record(game=i)
                self._play_game()
            if trials > 1 and _trial == 0:
                print "..."
                self.silent = True

            self.accumulate_stats()
        self.print_stats()

    def _play_game(self):
        try:
            self._play_game_inner()
        except KeyboardInterrupt:
            if self.silent:
                print "Aborting - recent history:"
                print '\n'.join(self.history)
            exit(1)

    def _play_game_inner(self):
        self._game_over = False
        while not self.is_game_over():
            for player in self._players:
                player.play()
                if self.is_game_over():
                    return

    def accumulate_stats(self):
        self._trials += 1
        for i in xrange(self._num_players):
            self._sums[i] += self._scores[i]
            self._sum_squares[i] += self._scores[i] ** 2
            self._min[i] = min(self._min[i], self._scores[i])
            self._max[i] = max(self._max[i], self._scores[i])
        self._scores = [0] * self._num_players

    def print_stats(self):
        self._record("Trials: %d (%d games per trial)." % (self._trials, self._games_per_trial),
                     force=True)
        averages = [self._sums[i] / self._trials for i in xrange(self._num_players)]
        errors = [sqrt(self._sum_squares[i] / self._trials - averages[i] ** 2) / sqrt(self._trials)
                  for i in xrange(self._num_players)]
        fmt_string = "{:d}:{:s}: {:0.2f} +/- {:0.2f} (min={:0.2f}, max={:0.2f} ({:0.2f} per game))"
        scores = '\n'.join([fmt_string.format(i,
                                              self._players[i].__class__.__name__,
                                              averages[i],
                                              errors[i],
                                              self._min[i],
                                              self._max[i],
                                              averages[i] / self._games_per_trial)
                            for i in xrange(self._num_players)])
        self._record("Trial Scores:\n" + scores, force=True)

    def is_game_over(self):
        return self._game_over

    def get_score_player(self, i):
        return self._scores[i]

    def set_score_player(self, i, new_score):
        self._scores[i] = new_score

    def add_score_player(self, i, delta):
        self._scores[i] += delta

    def set_game_over(self):
        self._game_over = True
        if self.silent:
            return
        scores = ', '.join(["{:d}:{:s} = {:0.2f}".format(i,
                                                         self._players[i].__class__.__name__,
                                                         self._scores[i])
                            for i in xrange(self._num_players)])
        self._record('    ' + scores)

    def record(self, **kwargs):
        line = u', '.join(['%s=%s' % (key, value) for (key, value) in kwargs.items()])
        self._record(line)

    def _record(self, s, force=False):
        self.history.append(s)
        if not force and self.silent:
            return
        print s


class GameProxy(object):
    def __init__(self, game, i):
        self.game = game
        self.i = i

    def __getattr__(self, name):
        if name.startswith('_'):
            raise AttributeError("Cannot access protected game attribute: %s" % name)
        if hasattr(self.game, name + '_player'):
            value = getattr(self.game, name + '_player')
        elif hasattr(self.game, name):
            value = getattr(self.game, name)
        else:
            raise AttributeError("No such attribute: %s" % name)
        if type(value) != MethodType:
            raise AttributeError("Cannot access %r type game attributes." % type(value))
        if name.endswith('_player'):
            return partial(value, self.i)
        return value
