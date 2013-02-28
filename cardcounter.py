#!/usr/bin/env python
"""
   cardcounter.py - Test card counting strategies against simulated card deals.
"""
from gamesimulator import Game
from cards import Deck


def main():
    bj = BlackJack(DealerStrategy, DealerStrategy)
    bj.simulate()


class BlackJack(Game):
    class DealerGame(Game):
        """ Mini-game to encapsulate DealerStrategy to play the house's hand. """
        def __init__(self, game):
            super(BlackJack.DealerGame, self).__init__(DealerStrategy)
            self.game = game
            self.silent = True

        def get_my_cards(self):
            return self.game._dealer_cards

        def bet(self, amount):
            pass

        def sum(self, cards):
            return self.game.sum(cards)

        def stand(self):
            self.set_game_over()

        def hit(self):
            self.game._dealer_cards.extend(self.game._deck.deal_cards(1))
            dealer_sum = self.sum(self.game._dealer_cards)
            self.game.record(dealer_hits=u', '.join(Deck.card_names(self.game._dealer_cards)),
                             dealer_total=dealer_sum)

    def __init__(self, *Strategy):
        super(BlackJack, self).__init__(*Strategy)
        self._deck = Deck(num_decks=1)
        self.dealer_game = BlackJack.DealerGame(self)

    def _play_game(self):
        self._player_cards = [[] for _i in range(self._num_players)]
        self._dealer_cards = []
        self._wagers = [0 for _i in range(self._num_players)]
        super(BlackJack, self)._play_game()

    @classmethod
    def sum(cls, cards):
        total = Deck.sum(cards)
        if 1 in Deck.card_values(cards) and total + 10 <= 21:
            return total + 10
        return total

    def get_my_cards_player(self, i):
        return self._player_cards[i]

    def get_dealer_card(self):
        return self._dealer_cards[0]

    def bet_player(self, i, amount):
        if len(self._player_cards[i]) != 0:
            raise ValueError("Cannot bet during play.")
        if amount <= 0:
            raise ValueError("Illegal bet: %d" % amount)
        self._wagers[i] = amount
        self._player_cards[i] = self._deck.deal_cards(2)
        self.record_player(i, bet=amount,
                           player_has=u', '.join(Deck.card_names(self._player_cards[i])))
        if i == self._num_players - 1:
            self._dealer_cards = self._deck.deal_cards(2)
            self.record(dealer_shows=Deck.card_name(self.get_dealer_card()))

    def hit_player(self, i):
        if self._wagers[i] == 0:
            raise ValueError("No bet.")
        self._player_cards[i].extend(self._deck.deal_cards(1))
        self.record_player(i, player_hits=u', '.join(Deck.card_names(self._player_cards[i])),
                           player_total=self.sum(self._player_cards[i]))

    def stand_player(self, i):
        if self.is_game_over_player(i):
            raise ValueError("Game is already over (player %d)." % i)
        if self._wagers[i] == 0:
            raise ValueError("No bet.")
        if len(self._player_cards[i]) == 0:
            raise ValueError("No cards.")
        player_sum = self.sum(self._player_cards[i])
        if player_sum > 21:
            self._record_game_over_player(i, -self._wagers[i], message="Player busts.",)
            return

        if i < self._num_players - 1:
            return

        # Simulated mini-game using DealerStrategy to play the Dealer's cards
        self.dealer_game._play_game()
        dealer_sum = self.sum(self._dealer_cards)

        for i in range(self._num_players):
            if self.is_game_over_player(i):
                continue

            if player_sum == 21 and len(self._player_cards[i]) == 2 and dealer_sum != 21:
                self._record_game_over_player(i, 1.5 * self._wagers[i], message="Blackjack!")
                continue

            if dealer_sum > 21:
                self._record_game_over_player(i, self._wagers[i], message="Dealer busts.")
                continue

            if player_sum == dealer_sum:
                self._record_game_over_player(i, 0, message="Push.")
                continue

            if player_sum > dealer_sum:
                self._record_game_over_player(i, self._wagers[i])
                continue

            self._record_game_over_player(i, -self._wagers[i])

    def _record_game_over_player(self, i, delta, **kwargs):
        if self.is_game_over_player(i):
            raise ValueError("Game is already over.")
        self.add_score_player(0, delta)
        kwargs['deck_depth'] = self._deck.depth()
        if delta == 0:
            self.record_player(i, **kwargs)
        elif delta > 0:
            self.record_player(i, win=delta, **kwargs)
        else:
            self.record_player(i, lose=-delta, **kwargs)
        self.set_game_over_player(i)


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
        while True:
            cards = self.game.get_my_cards()
            if len(cards) == 0:
                self.game.bet(1)
                continue
            # Hit on soft 17
            if self.game.sum(cards) < (18 if 1 in Deck.card_values(cards) else 17):
                self.game.hit()
                continue
            return self.game.stand()


if __name__ == '__main__':
    main()
