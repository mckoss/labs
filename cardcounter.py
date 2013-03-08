#!/usr/bin/env python
"""
   cardcounter.py - Test card counting strategies against simulated card deals.
"""
from gamesimulator import Game
from cards import BlackjackDeck


def main():
    bj = Blackjack(DealerStrategy, BasicStrategy)
    bj.simulate()


class Blackjack(Game):
    silent_methods = ('get_my_cards', 'can_double', 'can_split')

    def __init__(self, *Strategy):
        # Put the dealer at the end of the player list.
        Strategy += (DealerStrategy,)
        super(Blackjack, self).__init__(*Strategy)
        self._deck = BlackjackDeck(num_decks=1)

    def _play_game(self):
        self.hands = [[Hand()] for _i in range(self._num_players)]
        self.dealer_index = self._num_players - 1
        self.current_hand = 0
        super(Blackjack, self)._play_game()

    def get_my_cards_player(self, i):
        return self.hands[i][self.current_hand].cards

    def get_dealer_card(self):
        return self.hands[self.dealer_index][0].cards[0]

    def get_player_hand(self, i):
        return self.hands[i][self.current_hand]

    def bet_player(self, i, amount):
        hand = self.get_player_hand(i)
        if hand.num_cards() != 0:
            raise ValueError("Cannot bet during play.")
        if amount <= 0:
            raise ValueError("Illegal bet: %d" % amount)
        hand.wager = amount
        hand.add_cards(self._deck.deal_cards(2))

    def hit_player(self, i):
        hand = self.get_player_hand(i)
        if hand.wager == 0:
            raise ValueError("No bet.")
        if hand.double and hand.num_cards() != 2:
            raise ValueError("Cannot hit more than once.")
        hand.add_cards(self._deck.deal_cards(1))

    def can_double_player(self, i):
        hand = self.get_player_hand(i)
        return hand.num_cards() == 2 and not hand.double

    def double_player(self, i):
        hand = self.get_player_hand(i)
        if hand.num_cards() != 2:
            raise ValueError("Can only double on first two cards.")
        if hand.double:
            raise ValueError("Cannot re-double.")
        hand.wager *= 2
        hand.double = True
        self.hit_player(i)

    def can_split_player(self, i):
        if len(self.hands[i]) != 1:
            return False
        hand = self.get_player_hand(i)
        values = BlackjackDeck.card_values(hand.cards)
        return hand.num_cards() == 2 and values[0] == values[1]

    def split_player(self, i):
        if not self.can_split_player(i):
            raise ValueError("Can't split.")
        hand = self.get_player_hand(i)
        self.hands[i].append(Hand())
        self.hands[i][1].add_cards([hand.cards[1]])
        self.hands[i][1].wager = self.hands[i][0].wager
        del hand.cards[1]
        for h in self.hands[i]:
            h.split = True
        self.hands[i][0].add_cards(self._deck.deal_cards(1))
        self.hands[i][1].add_cards(self._deck.deal_cards(1))

    def advance_player(self):
        if len(self.hands[self._current_player]) == 2 and self.current_hand == 0:
            self.current_hand = 1
            return
        self.current_hand = 0
        super(Blackjack, self).advance_player()

    def on_turn_player(self, i):
        hand = self.get_player_hand(i)
        if hand.num_cards() == 0:
            return
        if self.is_game_over_player(i):
            raise ValueError("Game is already over (player %d)." % i)
        if hand.wager == 0:
            raise ValueError("No bet.")
        if hand.num_cards() == 0:
            raise ValueError("No cards.")
        self.record('status',
                    player=i,
                    total=hand.sum(),
                    wager=hand.wager,
                    cards=u' '.join(BlackjackDeck.card_names(hand.cards)))

    def on_turn_over(self):
        # Do nothing after first round of betting and initial cards dealt.
        if self.turn == 0:
            return

        dealer_sum = self.hands[self.dealer_index][0].sum()

        for i in range(self._num_players - 1):
            for hand in self.hands[i]:
                player_sum = hand.sum()
                if player_sum > 21:
                    self._record_game_over_player(i, -hand.wager, message="Player busts.",)
                    continue

                if player_sum == 21 and hand.num_cards() == 2 and dealer_sum != 21:
                    mult = 1.5 if not hand.split else 1.0
                    self._record_game_over_player(i, mult * hand.wager, message="Blackjack!")
                    continue

                if dealer_sum > 21:
                    self._record_game_over_player(i, hand.wager, message="Dealer busts.")
                    continue

                if player_sum == dealer_sum:
                    self._record_game_over_player(i, 0, message="Push.")
                    continue

                if player_sum > dealer_sum:
                    self._record_game_over_player(i, hand.wager)
                    continue

                self._record_game_over_player(i, -hand.wager)

            self.set_game_over_player(i)
            if len(self.hands[i]) == 2:
                del self.hands[1]

        # Dealer game over when all players are over
        self.set_game_over_player(self.dealer_index)

    def _record_game_over_player(self, i, delta, **kwargs):
        if self.is_game_over_player(i):
            raise ValueError("Game is already over (player %d)." % i)
        self.add_score_player(i, delta)
        kwargs['deck_depth'] = self._deck.depth()
        if delta == 0:
            self.record('draw', player=i, **kwargs)
        elif delta > 0:
            self.record('win', player=i, amount=delta, **kwargs)
        else:
            self.record('lose', player=i, amount=-delta, **kwargs)


class Hand(object):
    def __init__(self):
        self.cards = []
        self.wager = 0
        self.double = False
        self.split = False

    def add_cards(self, cards):
        self.cards.extend(cards)

    def sum(self):
        return BlackjackDeck.sum(self.cards)

    def num_cards(self):
        return len(self.cards)


class DealerStrategy(object):
    """
    Dealer (house) strategy.
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
            if BlackjackDeck.sum(cards) < (18 if 1 in BlackjackDeck.card_values(cards) else 17):
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

            total = BlackjackDeck.sum(cards)
            values = BlackjackDeck.card_values(cards)
            dealer_card = BlackjackDeck.card_value(self.game.get_dealer_card())

            if self.game.can_split():
                if values[0] == 1 or values[0] == 8:
                    self.game.split()
                    return
                if values[0] in (2, 3, 7) and dealer_card in (2, 3, 4, 5, 6, 7) or \
                        values[0] == 4 and dealer_card in (5, 6) or \
                        values[0] == 6 and dealer_card in (2, 3, 4, 5, 6) or \
                        values[0] == 9 and dealer_card not in (1, 7):
                    self.game.split()
                    return

            if 1 in BlackjackDeck.card_values(cards):
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
