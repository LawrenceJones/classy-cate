#!/bin/sh

source ./get_token.sh

echo "Enter user:"
read user
echo 'Enter class:'
read class
echo "Enter period code:"
read period
echo "Enter year:"
read year

# Scrape notes
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/exercises?year=$year&class=$class&period=$period&user=$user"

