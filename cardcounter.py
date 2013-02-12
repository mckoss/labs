#!/usr/bin/env python
"""
   cardcounter.py - Test card counting strategies against simulated card deals.
"""
from random import shuffle

CARD_NAMES = ['A'] + map(unicode, range(2, 11)) + ['J', 'Q', 'K']
SUIT_NAMES = [u'\u2660', u'\u2665', u'\u2666', u'\u2663']


def main():
    print unicode(Deck())


class Simulation(object):
    def __init__(self):
        self.deck = Deck()


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
        self.cards = []
        for _d in range(num_decks):
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
        def card_name(card):
            return CARD_NAMES[card % 13] + SUIT_NAMES[card / 13]

        return map(card_name, cards)

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


class Strategy(object):
    """
    Dealer strategy is the default player strategy.  Bet $1 per play.
    """
    def bet(self):
        return 1

    def play_hand(self, cards):
        """
        Return one of 'hit', 'stand', 'split', 'double'

        >>> s = Strategy()
        >>> s.play_hand([0, 0])
        'hit'
        >>> s.play_hand([9, 5])
        'hit'
        >>> s.play_hand([9, 6])
        'stand'
        """
        values = Deck.card_values(cards)
        while sum(values) < 17:
            return 'hit'
        return 'stand'


if __name__ == '__main__':
    main()
