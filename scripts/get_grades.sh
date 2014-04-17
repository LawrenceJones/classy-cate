#!/bin/sh

source ./get_token.sh

echo "Enter year:"
read year
echo "Enter class:"
read class
echo "Enter login:"
read login

# Scrape dashboard
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/grades?year=$year&class=$class&user=$login"

