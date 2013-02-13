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

        # Simulated mini-game using DealerStrategy to play the Dealer's cards
        self.dealer_game._play_game()
        dealer_sum = self.sum(self._dealer_cards)

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
        # Hit on soft 17
        if self.game.sum(cards) < (18 if 1 in Deck.card_values(cards) else 17):
            return self.game.hit()
        return self.game.stand()


if __name__ == '__main__':
    main()
