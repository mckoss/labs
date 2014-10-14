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

    transactions.coallesce()
    # transactions.print_raw()
    transactions.print_with_balances()

class Transactions(object):
    def __init__(self):
        self.transactions = []
        self.dups = {}

    def add(self, trans):
        self.transactions.append(trans)

    def add_file(self, file_name):
        if 'USD' in file_name:
            file_type = 'USD'
        else:
            file_type = 'BTC'
        new_rows = 0
        dup_rows = 0
        with open(file_name, 'r') as f:
            reader = csv.reader(f)
            for row in reader:
                if row[0] == 'Index':
                    continue
                key = row_key(file_type, row)
                if key not in self.dups:
                    new_rows += 1
                    self.dups[key] = file_name
                    self.transactions.append(parse_transaction(row, file_type))
                else:
                    dup_rows += 1
                    # print "Dup of {key} in file {file2} with {file1}".\
                    #     format(key=key, file1=self.dups[key], file2=file_name)
        print "%s: Read %d unique rows and discarded %d duplicate rows." % \
            (file_name, new_rows, dup_rows)

    def coallesce(self):
        results = []
        self.transactions.sort(cmp_by_tid)
        prev = None
        for t in self.transactions:
            if prev is None or t['tid'] == '' or t['tid'] != prev['tid']:
                prev = t;
                results.append(t)
                continue
            prev['usd'] += t['usd']
            prev['btc'] += t['btc']
            prev['source'] += ' ' + t['source']
        self.transactions = results
        self.transactions.sort(cmp_by_date)

    def print_raw(self):
        for t in self.transactions:
            pprint(t)

    def print_with_balances(self):
        FORMAT = "{date:16s} {type:9s} {usd:>10s} {btc:>10s} {usd_bal:>10s} {btc_bal:>10s} " \
            "{cum_usd:>10s} {cum_btc:>10s}"
        print FORMAT.format(date="Date", type="Type", usd="USD", btc="BTC",
                            usd_bal="USD Bal", btc_bal="BTC Bal",
                            cum_usd="Cum USD", cum_btc="Cum BTC")
        usd_bal = 0.0
        btc_bal = 0.0
        cum_usd = 0.0
        cum_btc = 0.0
        for t in self.transactions:
            usd_bal += t['usd']
            btc_bal += t['btc']
            if t['type'] == 'deposit' or t['type'] == 'withdraw':
                cum_usd -= t['usd']
                cum_btc -= t['btc']
            print FORMAT.format(
                date=t['date'].strftime(date_format),
                type=t['type'],
                usd="{0:0.2f}".format(t['usd']),
                btc="{0:0.4f}".format(t['btc']),
                usd_bal="{0:0.2f}".format(usd_bal),
                btc_bal="{0:0.4f}".format(btc_bal),
                cum_usd="{0:0.2f}".format(cum_usd),
                cum_btc="{0:0.4f}".format(cum_btc)
                )



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
