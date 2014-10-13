#!/usr/bin/env python
# coins.py - solutions to 12 coins balance problem.
#
# Given 12 coins, one of which is a non-standard weight
# determine the non-standard coin in no more than 3
# uses of a balance.


def main():
    for case in range(12):
        for size in [0, 2]:
            coins = [1] * 12
            coins[case] = size
            p = find_coin(coins)
            print "%r at %d - %s" % (coins, p, p == case and "correct" or "wrong")


def find_coin(coins):
    b1 = balance(coins[0:4], coins[4:8])

    # Coin in 8:12 (4?)
    if b1 == 0:
        b2 = balance(coins[8:10], coins[0:2])

        # Coin in 10:12 (2?)
        if b2 == 0:
            b3 = balance(coins[10:11], coins[0:1])
            if b3 == 0:
                return 11
            return 10

        # Light coin in 8:10
        if b2 < 0:
            b3 = balance(coins[8:9], coins[0:1])
            if b3 < 0:
                return 8
            return 9

        # Heavy coin in 8:10
        b3 = balance(coins[8:9], coins[0:1])
        if b3 > 0:
            return 8
        return 9

    # 0:4 < 4:8 (4L + 4H)
    if b1 < 0:

    # 0:4 > 4:8 (4L + 4H)
    return 0


def balance(left, right):
    result = sum(left) - sum(right)
    print "%r vs %r is %d" % (left, right, result)
    return result


if __name__ == '__main__':
    main()
