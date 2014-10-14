#!/usr/bin/env python
# gox_transactions - read csv transaction history from MtGox dumps

import argparse
import csv
import glob
from datetime import datetime
import time
import re
from pprint import pprint

# CSV Columns
INDEX = 0
DATE = 1
TYPE = 2
INFO = 3
VALUE = 4
BALANCE = 5

def main():
    parser = argparse.ArgumentParser(description="Read MtGox transaction files")
    parser.add_argument('files', nargs='+', help="csv file names")
    args = parser.parse_args()
    transactions = Transactions()

    for file_name in args.files:
        transactions.add_file(file_name)

    print len(transactions.transactions)

    # Remove dups
    transactions.sort()
    transactions.do_print()

class Transactions(object):
    def __init__(self):
        self.transactions = []
        self.dups = {}

    def add(self, trans):
        self.transactions.append(trans)

    def sort(self):
        self.transactions.sort(cmp_by_date)

    def do_print(self):
        for t in self.transactions:
            pprint(t)

    def add_file(self, file_name):
        if 'USD' in file_name:
            file_type = 'USD'
        else:
            file_type = 'BTC'
        print "Reading {name} as type: {type}".format(name=file_name, type=file_type)
        with open(file_name, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                if row[0] == 'Index':
                    continue
                key = row_key(file_type, row)
                if key not in self.dups:
                    self.dups[key] = file_name
                    self.transactions.append(parse_transaction(row, file_type))
                else:
                    print "Dup of {key} in file {file2} with {file1}".\
                        format(key=key, file1=self.dups[key], file2=file_name)


def cmp_by_date(a, b):
    return int((a['date'] - b['date']).total_seconds())


def cmp_by_tid(a, b):
    if a['tid'] == b['tid']:
        return 0
    return -1 if a['tid'] < b['tid'] else 1


date_format = '%Y-%m-%d %H:%M:%S'
re_id = re.compile(r'.*\[tid:([0-9]+)\]')

# Types of transactions
#
# out - BTC sold
# deposit - BTC or USD deposit
# in - BTC purchased
# fee - BTC denominated fee on purchase, USD fee on sale
# withdraw - BTC or USD withdrawl (Dwolla)
# spent - for BTC purchased
# earned - for BTC sold
SIGNS = {
    'out': -1,
    'deposit': +1,
    'in': +1,
    'fee': -1,
    'withdraw': -1,
    'spent': -1,
    'earned': +1,
}

TRANS_TYPES = {
    'BTC.out': 'sell',
    'BTC.in': 'buy',
    'BTC.deposit': 'deposit',
    'BTC.withdraw': 'withdraw',
    'BTC.fee': 'buy',
    'USD.deposit': 'deposit',
    'USD.withdraw': 'withdraw',
    'USD.fee': 'sell',
    'USD.spent': 'buy',
    'USD.earned': 'sell',
}

def parse_transaction(row, file_type):
    match = re_id.match(row[INFO])
    tid = match.group(1) if match else ''
    result = {
        'type': TRANS_TYPES[file_type + '.' + row[TYPE]],
        'source': file_type + '.' + row[INDEX] + '.' + row[TYPE],
        'date': datetime.strptime(row[DATE], date_format),
        'tid': tid,
        'usd': 0.0,
        'btc': 0.0,
        'notes': row[INFO].decode('ascii', errors='ignore').encode('ascii'),
        }

    result[file_type.lower()] = SIGNS[row[TYPE]] * float(row[VALUE])
    return result


def row_key(file_type, row):
    return "{type}.{index}".format(type=file_type, index=row[INDEX])


if __name__ == '__main__':
    main()
