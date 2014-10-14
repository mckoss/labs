#!/usr/bin/env python
# gox_transactions - read csv transaction history from MtGox dumps

import argparse
import csv
import glob
from datetime import datetime
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
    transactions = []

    for file_name in args.files:
        if 'USD' in file_name:
            file_type = 'USD'
        else:
            file_type = 'BTC'
        print "Reading {name} as type: {type}".format(name=file_name, type=file_type)
        with open(file_name, 'r') as f:
            add_transactions(transactions, f, file_type)

    print len(transactions)
    for t in transactions:
        pprint(t)


def add_transactions(transactions, f, file_type):
    reader = csv.reader(f)
    for row in reader:
        if row[0] == 'Index':
            continue
        transactions.append(parse_transaction(row, file_type))


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
        'date': datetime.strptime(row[DATE], date_format),
        'tid': tid,
        'usd': 0.0,
        'btc': 0.0,
        'notes': row[INFO].decode('ascii', errors='ignore').encode('ascii'),
        }

    result[file_type.lower()] = SIGNS[row[TYPE]] * float(row[VALUE])
    return result

if __name__ == '__main__':
    main()
