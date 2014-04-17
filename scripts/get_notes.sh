#!/bin/sh

source ./get_token.sh

echo 'Enter notes url:'
read note_link

# Scrape notes
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/notes?link=$note_link"

