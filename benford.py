#!/usr/bin/env python


def main():
    x = 1
    digits = [0] * 9
    for _i in range(1000):
        x = x * 2
        first_digit = ord(str(x)[0]) - ord('1')
        digits[first_digit] += 1
    print digits

if __name__ == '__main__':
    main()
