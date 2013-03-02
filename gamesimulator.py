from math import sqrt
from types import MethodType
from collections import deque
from functools import partial
import traceback


class Game(object):
    def __init__(self, *Players):
        self._num_players = len(Players)
        self._players = [Players[i](GameProxy(self, i)) for i in xrange(self._num_players)]
        self._player_over = [False] * self._num_players
        self._trials = 0
        self._scores = [0] * self._num_players
        self._sums = [0] * self._num_players
        self._sum_squares = [0] * self._num_players
        self._min = [0] * self._num_players
        self._max = [0] * self._num_players
        self.silent = False
        self.history = deque(maxlen=100)

    def init_game(self):
        self._player_over = [False] * self._num_players
        self.turn = 0

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
        self.init_game()
        try:
            self._play_game_inner()
        except KeyboardInterrupt:
            if self.silent:
                print "Aborting - recent history:"
                traceback.print_exc()
                print '\n'.join(self.history)
            exit(1)

    def _play_game_inner(self):
        while True:
            for i in xrange(self._num_players):
                if self.is_game_over():
                    return
                if self.is_game_over_player(i):
                    continue
                self._players[i].play()
                self.on_turn_player(i)
            self.on_turn_over()
            self.turn += 1

    def on_turn_player(self, i):
        """ Called after each player's turn is over. """
        pass

    def on_turn_over(self):
        """ Called after all players have completed each turn. """
        pass

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
        fmt_string = "{:d}:{:s}: {:0.2f} +/- {:0.2f} (min={:0.2f}, max={:0.2f} ({:0.3f} per game))"
        scores = '\n'.join([fmt_string.format(i,
                                              self._players[i].__class__.__name__,
                                              averages[i],
                                              errors[i],
                                              self._min[i],
                                              self._max[i],
                                              averages[i] / self._games_per_trial)
                            for i in xrange(self._num_players)])
        self._record("Trial Scores:\n" + scores, force=True)

    def get_score_player(self, i):
        return self._scores[i]

    def set_score_player(self, i, new_score):
        self._scores[i] = new_score

    def add_score_player(self, i, delta):
        self._scores[i] += delta

    def is_game_over(self):
        return all(self._player_over)

    def is_game_over_player(self, i):
        return self._player_over[i]

    def set_game_over_player(self, i):
        self._player_over[i] = True
        if self.is_game_over():
            self.set_game_over()

    def set_game_over(self):
        if self.silent:
            return
        scores = ', '.join(["{:d}:{:s} = {:0.2f}".format(i,
                                                         self._players[i].__class__.__name__,
                                                         self._scores[i])
                            for i in xrange(self._num_players)])
        self._record('    ' + scores)

    def record_player(self, i, **kwargs):
        line = u', '.join(['%s=%s' % (key, value) for (key, value) in kwargs.items()])
        self._record(u'%d: %s' % (i, line))

    def record(self, **kwargs):
        line = u', '.join(['%s=%s' % (key, value) for (key, value) in kwargs.items()])
        self._record(line)

    def _record(self, s, force=False):
        s = s.encode('utf-8')
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
            name += '_player'
        if not hasattr(self.game, name):
            raise AttributeError("No such attribute: %s" % name)
        value = getattr(self.game, name)
        if type(value) != MethodType:
            raise AttributeError("Cannot access %r type game attributes." % type(value))
        if name.endswith('_player'):
            return partial(value, self.i)
        return value
