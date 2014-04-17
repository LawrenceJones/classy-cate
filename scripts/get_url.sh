#!/bin/sh

source ./get_token.sh

echo 'Enter general url:'
read url
url=`echo $url | sed 's/^\/*//g'`

# Scrape url
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/$url"

