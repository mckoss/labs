#!/usr/bin/env python
# anagram.py - Prints anagrams of word passed in command line.
from __future__ import print_function

import argparse


DICT_FILE = 'dict.txt'


def main():
    parser = argparse.ArgumentParser(description='Print anagrams of word on command line.')
    parser.add_argument("words", type=str, nargs='*', help="Word(s) to anagram.")
    args = parser.parse_args()

    counts = LetterCounts()
    for word in args.words:
        counts.add_word(word)

    words = list()

    total_words = 0
    with open(DICT_FILE) as f:
        for line in f.readlines():
            word = line.strip()
            total_words += 1
            if counts.contains(word):
                words.append(word)

    print("%d candidate words in dictionary (out of %d)" % (len(words), total_words))

    anagrams = find_anagrams(counts, words)

    def anagram_order(a, b):
        return len(a) - len(b)

    anagrams.sort(anagram_order)

    for i, anagram in enumerate(anagrams):
        print("%2d. %s" % (i + 1, ' '.join(anagram)))


def find_anagrams(counts, words, start=0):
    """
    Return array of anagrams that can by made from
    words[start:]
    """
    anagrams = []
    for i in range(start, len(words)):
        if not counts.contains(words[i]):
            continue

        sub_counts = counts.clone()
        sub_counts.subtract_word(words[i])
        if sub_counts.is_zero():
            anagrams.append([words[i]])
            continue

        sub_anagrams = find_anagrams(sub_counts, words, i)
        for sub_anagram in sub_anagrams:
            anagram = [words[i]]
            anagram.extend(sub_anagram)
            anagrams.append(anagram)

    return anagrams


class LetterCounts(object):
    def __init__(self, word=None):
        self.counts = [0] * 26
        if word is not None:
            self.add_word(word)

    def clone(self):
        return LetterCounts().copy(self)

    def copy(self, other):
        self.counts = list(other.counts)
        return self

    def add_word(self, word, sgn=1):
        word = word.lower()
        for ch in word:
            i = ord(ch) - ord('a')
            if i < 0 or i > 25:
                continue
            self.counts[i] += sgn

    def subtract_word(self, word):
        self.add_word(word, -1)

    def contains(self, word):
        word = word.lower()
        counts = list(self.counts)
        for ch in word:
            i = ord(ch) - ord('a')
            if i < 0 or i > 25:
                continue
            counts[i] -= 1
            if counts[i] < 0:
                return False
        return True

    def is_zero(self):
        for c in self.counts:
            if c != 0:
                return False
        return True

    def __repr__(self):
        s = ''
        for i in range(26):
            if self.counts[i] == 0:
                continue
            s += "%s[%d]" % (chr(ord('a') + i), self.counts[i])
        return s


if __name__ == '__main__':
    main()
