#!/bin/sh

# Search for ~/.imp file, containing imperial login
# credentials, formatted as "#{user}\n#{pass}"
if [ -a ~/.imp ];
then
  read -a creds <<< $(cat ~/.imp | sed ':a;N;$!ba;s/\n/ /g')
  user=${creds[0]}
  pass=${creds[1]}
else
  echo "Enter college login:"
  read user
  echo "Enter password:"
  read -s pass; echo
fi

# Select domain to use
domain='http://localhost:55000'
# domain='https://doc-exams.herokuapp.com'
export domain

creds="{\"user\":\"$user\",\"pass\":\"$pass\"}"

# Pull JSON { token: <token> }
tokenJson=$(curl -s -X POST -H "Content-Type: application/json" \
     -d $creds \
     -k "$domain/authenticate")

# Extract token
export token=$(coffee -e "console.log JSON.parse('$tokenJson')._meta.token")

echo "Got token! {$token}\n"
