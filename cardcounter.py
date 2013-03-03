#!/usr/bin/env python
"""
   cardcounter.py - Test card counting strategies against simulated card deals.
"""
from gamesimulator import Game
from cards import Deck


def main():
    bj = BlackJack(DealerStrategy, BasicStrategy)
    bj.simulate()


class BlackJack(Game):
    def __init__(self, *Strategy):
        # Put the dealer at the end of the player list.
        Strategy += (DealerStrategy,)
        super(BlackJack, self).__init__(*Strategy)
        self._deck = Deck(num_decks=1)

    def _play_game(self):
        self._player_cards = [[] for _i in range(self._num_players)]
        self._wagers = [0 for _i in range(self._num_players)]
        self._double = [False] * self._num_players
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
        return self._player_cards[-1][0]

    def bet_player(self, i, amount):
        if len(self._player_cards[i]) != 0:
            raise ValueError("Cannot bet during play.")
        if amount <= 0:
            raise ValueError("Illegal bet: %d" % amount)
        self._wagers[i] = amount
        self._player_cards[i] = self._deck.deal_cards(2)
        self.record_player(i, bet=amount,
                           player_has=u', '.join(Deck.card_names(self._player_cards[i])))

    def can_double_player(self, i):
        return len(self._player_cards[i]) == 2 and not self._double[i]

    def double_player(self, i):
        if len(self._player_cards[i]) != 2:
            raise ValueError("Can only double on first two cards.")
        if self._double[i]:
            raise ValueError("Cannot re-double.")
        self._wagers[i] *= 2
        self._double[i] = True
        self.record_player(i, double=self._wagers[i],
                           player_has=u', '.join(Deck.card_names(self._player_cards[i])))
        self.hit_player(i)

    def hit_player(self, i):
        if self._wagers[i] == 0:
            raise ValueError("No bet.")
        if self._double[i] and len(self._player_cards[i]) != 2:
            raise ValueError("Cannot hit more than once.")
        self._player_cards[i].extend(self._deck.deal_cards(1))
        self.record_player(i, hit=u', '.join(Deck.card_names(self._player_cards[i])),
                           player_total=self.sum(self._player_cards[i]))

    def on_turn_player(self, i):
        if len(self._player_cards[i]) == 0:
            return
        if self.is_game_over_player(i):
            raise ValueError("Game is already over (player %d)." % i)
        if self._wagers[i] == 0:
            raise ValueError("No bet.")
        if len(self._player_cards[i]) == 0:
            raise ValueError("No cards.")

    def on_turn_over(self):
        # Do nothing after first round of betting and initial cards dealt.
        if self.turn == 0:
            return

        dealer_sum = self.sum(self._player_cards[-1])

        for i in range(self._num_players - 1):
            player_sum = self.sum(self._player_cards[i])
            if player_sum > 21:
                self._record_game_over_player(i, -self._wagers[i], message="Player busts.",)
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

        # Dealer game over when all players are over
        self.set_game_over_player(-1)

    def _record_game_over_player(self, i, delta, **kwargs):
        if self.is_game_over_player(i):
            raise ValueError("Game is already over (player %d)." % i)
        self.add_score_player(i, delta)
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
        while True:
            cards = self.game.get_my_cards()
            if len(cards) == 0:
                self.game.bet(1)
                return

            # Hit on soft 17
            if self.game.sum(cards) < (18 if 1 in Deck.card_values(cards) else 17):
                self.game.hit()
                continue

            return


class BasicStrategy(object):
    def __init__(self, game):
        self.game = game

    def play(self):
        while True:
            cards = self.game.get_my_cards()
            if len(cards) == 0:
                self.game.bet(1)
                return

            total = self.game.sum(cards)
            dealer_card = Deck.card_value(self.game.get_dealer_card())
            if 1 in Deck.card_values(cards):
                if total >= 19:
                    return

                if total <= 17:
                    if self.game.can_double() and (
                        dealer_card in (5, 6) or
                        dealer_card == 4 and total >= 15 or
                        dealer_card == 3 and total == 17):
                        self.game.double()
                        return
                    self.game.hit()
                    continue

                # A-7 == 18
                if self.game.can_double() and dealer_card in (3, 4, 5, 6):
                    self.game.double()
                    return

                if dealer_card in (2, 3, 4, 5, 6, 7, 8):
                    return

                self.game.hit()
                continue

            if total >= 17:
                return

            if total >= 13 and dealer_card in (2, 3, 4, 5, 6):
                return

            if total == 12 and dealer_card in (4, 5, 6):
                return

            if self.game.can_double() and total >= 9 and total <= 11 and (
                dealer_card in (3, 4, 5, 6) or
                total >= 10 and dealer_card in (2, 7, 8, 9) or
                total == 11 and dealer_card == 10
                ):
                self.game.double()
                return

            self.game.hit()


if __name__ == '__main__':
    main()
