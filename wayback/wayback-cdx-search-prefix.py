#!/usr/bin/env python3
# Dump latest valid URLs from archive.org given a URL prefix

# Usage:
#
#     ./wayback-cdx-search-prefix.py [PREFIX]
#     python wayback-cdx-search-prefix.py [PREFIX]

import urllib.parse
import sys

import requests

ROOT = 'http://web.archive.org/cdx/search/cdx?matchType=prefix&url='

if __name__ == '__main__':
    url = ROOT + urllib.parse.unquote(sys.argv[1])

    print(f'requests.get(\'{url}\')')
    response = requests.get(url)
    response.raise_for_status()

    results = dict()

    for line in response.content.decode().strip().split('\n'):
        urlkey, timestamp, original, mimetype, statuscode, digest, length = line.split()
        if not statuscode[0] in "23": # Filter to status codes 2XX and 3XX
            continue
        results[urlkey] = f'https://web.archive.org/web/{timestamp}/{original}'

    for result in results.values():
        print(result)
