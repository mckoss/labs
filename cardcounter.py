#!/usr/bin/env python
"""
   cardcounter.py - Test card counting strategies against simulated card deals.
"""
from types import FunctionType
from random import shuffle
from functools import partial

CARD_NAMES = ['A'] + map(unicode, range(2, 11)) + ['J', 'Q', 'K']
SUIT_NAMES = [u'\u2660', u'\u2665', u'\u2666', u'\u2663']


def main():
    bj = BlackJack(BasicStrategy)
    bj.simulate()


class Game(object):
    def __init__(self, *Players):
        self.players = [Players[i](GameProxy(self, i)) for i in range(len(Players))]

    def _play_game(self):
        while not self.is_game_over():
            for player in self.players:
                player.play()
                if self.is_game_over():
                    return

    def is_game_over(self):
        return False

    def record(self, **kwargs):
        print '\n'.join(['%s: %s' % (key, value) for (key, value) in kwargs.items])


class GameProxy(object):
    def __init__(self, game, i):
        self.game = game
        self.i = i

    def __getattr__(self, name):
        if name.startswith('_') or not hasattr(self.game, name):
            raise AttributeError("Game has no %s" % name)
        value = getattr(self.game, name)
        if type(value) != FunctionType:
            return value
        return partial(value, self.game.players[self.i])


class BlackJack(Game):
    def __init__(self, Strategy, num_decks=1):
        super(BlackJack, self).__init__(Strategy)
        self._deck = Deck(num_decks=num_decks)
        self._player_winnings = 0

    def simulate(self, total_hands=1):
        for hand in xrange(1, hands + 1):
            self.record(hand=hand)
            self._play_game()

    def _play_game(self):
        self._game_over = False
        if self._deck.depth() < 10:
            self._deck.reshuffle()
        self._player_cards = []
        self._dealer_cards = []
        self._wager = 0
        super(BlackJack, self)._play_game()

    @staticmethod
    def sum(cards):
        total = Deck.sum(cards)
        if 1 in Deck.card_values(cards) and total + 10 <= 21:
            return total + 10
        return total

    def is_game_over(self):
        return self._game_over

    def get_dealer_card(self):
        return self._dealer_cards[0]

    def bet(self, amount):
        if len(self._player_cards) != 0:
            raise ValueError("Cannot bet during play.")
        self._wager = amount
        self._dealer_cards = self._deck.deal_cards(2)
        self._player_cards = self._deck.deal_cards(2)
        self.record(bet=amount,
                    dealer_shows=Deck.card_name(self.get_dealer_card()),
                    player_has=Deck.card_names(self._player_cards))

    def stand(self):
        if self._game_over:
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
        while dealer_sum < 17:
            self._dealer_cards.extend(self._deck.deal_cards(1))
            dealer_sum = self.sum(self._dealer_cards)
            self.record(dealer_hits=Deck.card_name(self._dealer_cards[-1]),
                        dealer_total=dealer_sum)

        if dealer_sum > 21:
            self._record_game_over(self._wager, message="Dealer busts.")
            return

        if player_sum == dealer_sum:
            self._record_game_over(0, message="Push.")
            return

        if player_sum == 21:
            self._record_game_over(1.5 * self._wager, message="Blackjack!")
            return

        if player_sum > dealer_sum:
            self._record_game_over(self._wager)
            return

        self._record_game_over(-self._wager)

    def _record_game_over(self, delta, **kwargs):
        if self._game_over:
            raise ValueError("Game is already over.")
        self._player_winnings += delta
        self._games_over = True
        if delta == 0:
            self.record(balance=self._player_winnings,
                        **kwargs)
        elif delta > 0:
            self.record(win=delta,
                        balance=self._player_winnings,
                        **kwargs)
        else:
            self.record(lose=delta,
                        balance=self._player_winnings,
                        **kwargs)


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
    def __init__(self, num_decks=1):
        self.num_decks = num_decks
        self.reshuffle()

    def reshuffle(self):
        self.cards = []
        for _d in range(self.num_decks):
            self.cards.extend(range(52))
        shuffle(self.cards)

    def deal_cards(self, num=1):
        cards = self.cards[:num]
        del self.cards[:num]
        return cards

    def depth(self):
        return len(self.cards)

    @staticmethod
    def card_names(cards):
        return map(self.card_name, cards)

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


class BasicStrategy(object):
    """
    Default player strategy.  Bet $1 per play.
    """
    def __init__(self, game):
        self.game = game

    def bet(self):
        return 1

    def play(self):
        """
        Action: one of 'hit', 'stand', 'split', 'double'.
        """
        cards = self.game.my_cards()
        if len(cards) == 0:
            return game.bet(1)
        if self.game.sum(cards) < 17:
            return game.hit()
        return game.stand()


if __name__ == '__main__':
    main()
