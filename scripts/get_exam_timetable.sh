#!/bin/sh

source ./get_token.sh

# Scrape exams
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -k "$domain/api/exam_timetable"

