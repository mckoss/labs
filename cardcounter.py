#!/usr/bin/env python
"""
   cardcounter.py - Test card counting strategies against simulated card deals.
"""
from math import sqrt
from types import MethodType
from random import shuffle
from functools import partial
from collections import deque

CARD_NAMES = ['A'] + map(unicode, range(2, 11)) + ['J', 'Q', 'K']
SUIT_NAMES = [u'\u2660', u'\u2665', u'\u2666', u'\u2663']


def main():
    bj = BlackJack(DealerStrategy)
    bj.simulate()


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

    def simulate(self, total_games=100, trials=100):
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
        errors = [sqrt(self._sum_squares[i] / self._trials - averages[i] ** 2)
                  for i in xrange(self._num_players)]
        fmt_string = "P{:d}: {:0.2f} +/- {:0.2f} (min={:0.2f}, max={:0.2f} ({:0.2f} per game))"
        scores = ', '.join([fmt_string.format(i,
                                              averages[i],
                                              errors[i],
                                              self._min[i],
                                              self._max[i],
                                              averages[i] / self._games_per_trial)
                            for i in xrange(self._num_players)])
        self._record("Trial Scores:" + scores, force=True)

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
        scores = ', '.join(['P%d = %s' % (i, self._scores[i])
                            for i in xrange(self._num_players)])
        self._record('--- Player Scores: ' + scores)

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


class BlackJack(Game):
    def __init__(self, Strategy, num_decks=1):
        super(BlackJack, self).__init__(Strategy)
        self._deck = Deck(num_decks=num_decks)

    def _play_game(self):
        self._player_cards = []
        self._dealer_cards = []
        self._wager = 0
        super(BlackJack, self)._play_game()

    @classmethod
    def sum(cls, cards):
        total = Deck.sum(cards)
        if 1 in Deck.card_values(cards) and total + 10 <= 21:
            return total + 10
        return total

    def get_my_cards(self):
        return self._player_cards

    def get_dealer_card(self):
        return self._dealer_cards[0]

    def bet(self, amount):
        if len(self._player_cards) != 0:
            raise ValueError("Cannot bet during play.")
        if amount <= 0:
            raise ValueError("Illegal bet: %d" % amount)
        self._wager = amount
        self._dealer_cards = self._deck.deal_cards(2)
        self._player_cards = self._deck.deal_cards(2)
        self.record(bet=amount,
                    dealer_shows=Deck.card_name(self.get_dealer_card()),
                    player_has=u', '.join(Deck.card_names(self._player_cards)))

    def hit(self):
        if self._wager == 0:
            raise ValueError("No bet.")
        self._player_cards.extend(self._deck.deal_cards(1))
        self.record(player_hits=u', '.join(Deck.card_names(self._player_cards)),
                    player_total=self.sum(self._player_cards))

    def stand(self):
        if self.is_game_over():
            raise ValueError("Game is already over.")
        if self._wager == 0:
            raise ValueError("No bet.")
        if len(self._player_cards) == 0:
            raise ValueError("No cards.")
        player_sum = self.sum(self._player_cards)
        if player_sum > 21:
            self._record_game_over(-self._wager, message="Player busts.",)
            return

        dealer_sum = self.sum(self._dealer_cards)

        if player_sum == 21 and len(self._player_cards) == 2 and dealer_sum != 21:
            self._record_game_over(1.5 * self._wager, message="Blackjack!")
            return

        while dealer_sum < 17:
            self._dealer_cards.extend(self._deck.deal_cards(1))
            dealer_sum = self.sum(self._dealer_cards)
            self.record(dealer_hits=u', '.join(Deck.card_names(self._dealer_cards)),
                        dealer_total=dealer_sum)

        if dealer_sum > 21:
            self._record_game_over(self._wager, message="Dealer busts.")
            return

        if player_sum == dealer_sum:
            self._record_game_over(0, message="Push.")
            return

        if player_sum > dealer_sum:
            self._record_game_over(self._wager)
            return

        self._record_game_over(-self._wager)

    def _record_game_over(self, delta, **kwargs):
        if self.is_game_over():
            raise ValueError("Game is already over.")
        self.add_score_player(0, delta)
        kwargs['deck_depth'] = self._deck.depth()
        if delta == 0:
            self.record(**kwargs)
        elif delta > 0:
            self.record(win=delta, **kwargs)
        else:
            self.record(lose=-delta, **kwargs)
        self.set_game_over()


class Deck(object):
    """
    Deck (or shoe) of cards.

    >>> d = Deck()
    >>> d.depth()
    52
    >>> len(d.cards)
    52
    >>> d = Deck(4)
    >>> d.depth()
    208
    """
    def __init__(self, num_decks=1, min_cards=13):
        self.num_decks = num_decks
        self.min_cards = 13
        self.reshuffle()

    def reshuffle(self):
        self.cards = []
        for _d in range(self.num_decks):
            self.cards.extend(range(52))
        shuffle(self.cards)

    def deal_cards(self, num=1):
        if self.depth() - num < self.min_cards:
            self.reshuffle()
        cards = self.cards[:num]
        del self.cards[:num]
        return cards

    def depth(self):
        return len(self.cards)

    @staticmethod
    def card_names(cards):
        return map(Deck.card_name, cards)

    @staticmethod
    def card_name(card):
        return CARD_NAMES[card % 13] + SUIT_NAMES[card / 13]

    @staticmethod
    def sum(cards):
        return sum(Deck.card_values(cards))

    @staticmethod
    def card_values(cards):
        def card_value(card):
            value = card % 13 + 1
            if value >= 10:
                return 10
            return value

        return map(card_value, cards)

    def __unicode__(self):
        return u', '.join(self.card_names(self.cards))


class DealerStrategy(object):
    """
    Default player strategy.  Bet $1 per play.
    """
    def __init__(self, game):
        self.game = game

    def play(self):
        """
        Action: one of 'hit', 'stand', 'split', 'double'.
        """
        cards = self.game.get_my_cards()
        if len(cards) == 0:
            return self.game.bet(1)
        if self.game.sum(cards) < 17:
            return self.game.hit()
        return self.game.stand()


if __name__ == '__main__':
    main()
