#!/bin/sh

source ./get_token.sh

echo 'Enter class:'
read class
echo "Enter givens code:"
read code
echo "Enter year:"
read year

# Scrape notes
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/givens?class=$class&year=$year&code=$code"

