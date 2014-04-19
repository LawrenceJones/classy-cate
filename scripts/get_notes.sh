#!/bin/sh

source ./get_token.sh

echo 'Enter notes year:'
read year
echo "Enter notes module code:"
read code
echo "Enter period:"
read period

# Scrape notes
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/notes?year=$year&code=$code&period=$period"

