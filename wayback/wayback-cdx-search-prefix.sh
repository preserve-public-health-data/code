#!/usr/bin/env bash
# Dump latest valid URLs from archive.org given a URL prefix
#
# Usage:
#
#     ./wayback-cdx-search-prefix.sh [PREFIX]
#     bash wayback-cdx-search-prefix.sh [PREFIX]

# https://askubuntu.com/a/295312
urlencode() {
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

url="http://web.archive.org/cdx/search/cdx?matchType=prefix&url=$(urlencode "$1")"

echo "curl $url"

results=$(
	curl $url |
		grep -E "[23][0-9][0-9] [^\s]+ [0-9]+$" | # Filter to status codes 2XX and 3XX
		tac | # Sorted by date by default; reverse the order so we can run uniq
		awk -F " " '!_[$1]++' | # https://stackoverflow.com/a/1916188; 1st field is urlkey
		tac
)

echo "$results" |
	while IFS=" " read urlkey timestamp original mimetype statuscode digest length
	do
		if [ ${statuscode:0:1} != 2 ] && [ ${statuscode:0:1} != 3 ]
		then
			continue
		fi
		echo "https://web.archive.org/web/${timestamp}/${original}"
	done
