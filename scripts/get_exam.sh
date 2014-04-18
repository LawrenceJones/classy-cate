#!/bin/sh

source ./get_token.sh

echo "Enter exam id:"
read eid

# Scrape exams
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/exams/$eid"

