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
    parser.add_argument('--csv', action='store_true')
    args = parser.parse_args()
    transactions = Transactions()

    for file_name in args.files:
        transactions.add_file(file_name)

    transactions.coallesce()
    # transactions.print_raw()
    transactions.vs_purchase()
    transactions.print_with_balances(csv=args.csv)

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

    def vs_purchase(self):
        vs_bucket = 0
        vs_used = 0.0
        for t in self.transactions:
            if t['type'] != 'sell':
                continue
            vs_bucket, vs_used, t['basis'], t['vs'] = self.find_basis(vs_bucket, vs_used, -t['btc'])

    def find_basis(self, bucket, used, btc):
        t = self.transactions[bucket]
        basis = 0.0
        dates = []
        while btc > 0.0001:
            while t['type'] != 'buy' or t['usd'] > -0.001 or abs(t['btc'] - used) < 0.001:
                bucket += 1
                used = 0.0
                t = self.transactions[bucket]
            use = min(btc, t['btc'] - used)
            btc_usd = -t['usd'] / t['btc']
            basis += use * btc_usd
            dates.append(t['date'].strftime('%Y-%m-%d'))
            btc -= use
            used += use

        return bucket, used, basis, ', '.join(dates)

    def print_raw(self):
        for t in self.transactions:
            pprint(t)

    def print_with_balances(self, csv=False):
        row_format = "{date:19s} {type:8s} {btc:>9s} {usd:>9s} " \
            "{basis:>9s} {gain:>9s} {cum_gain:>9s} {cum_sold:>9s} " \
            "{btc_usd:>7s} {btc_bal:>9s} {usd_bal:>8s} " \
            "{cum_btc:>10s} {cum_usd:>10s} " \
            "{vs}"
        if csv:
            row_format = row_format.replace(' ', ',  ')
        dollar_format = "{0:0.2f}"
        btc_format = "{0:0.1f}"
        print row_format.format(date="Date", type="Type", usd="USD", btc="BTC",
                                btc_usd="BTCUSD",
                                usd_bal="USD Bal", btc_bal="BTC Bal",
                                basis="Basis", gain="Gain", cum_gain="Cum Gain", cum_sold="BTC Sold",
                                cum_usd="Cum USD", cum_btc="Cum BTC",
                                vs="vs purchase")
        usd_bal = 0.0
        btc_bal = 0.0
        cum_usd = 0.0
        cum_btc = 0.0
        cum_gain = 0.0
        cum_sold = 0.0
        for t in self.transactions:
            usd_bal += t['usd']
            btc_bal += t['btc']
            if t['type'] == 'deposit' or t['type'] == 'withdraw':
                cum_usd -= t['usd']
                cum_btc -= t['btc']
            if t['type'] == 'buy' or t['type'] == 'sell' and t['btc'] != 0.0:
                btc_usd = dollar_format.format(-t['usd'] / t['btc'])
            else:
                btc_usd = ''
            gain = t['usd'] - t['basis'] if 'basis' in t else 0.0
            if gain != 0.0:
                cum_gain += gain
                cum_sold += -t['btc']
            print row_format.format(
                date=t['date'].strftime(date_format),
                type=t['type'],
                usd=dollar_format.format(t['usd']),
                btc=btc_format.format(t['btc']),
                btc_usd=btc_usd,
                usd_bal=dollar_format.format(usd_bal),
                btc_bal=btc_format.format(btc_bal),
                cum_usd=dollar_format.format(cum_usd),
                cum_btc=btc_format.format(cum_btc),
                basis=dollar_format.format(t['basis']) if 'basis' in t else '',
                gain=dollar_format.format(gain) if gain != 0.0 else '',
                cum_gain=dollar_format.format(cum_gain),
                cum_sold=btc_format.format(cum_sold),
                vs=t['vs'] if 'vs' in t else ''
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
