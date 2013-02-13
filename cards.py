from random import shuffle

CARD_NAMES = ['A'] + map(unicode, range(2, 11)) + ['J', 'Q', 'K']
SUIT_NAMES = [u'\u2660', u'\u2665', u'\u2666', u'\u2663']


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
