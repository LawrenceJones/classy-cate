#!/bin/sh

source ./get_token.sh

echo "Enter desired user:"
read user
echo "Enter year:"
read year

# Scrape subscribed modules
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/subscribed_modules?year=$year&user=$user"

