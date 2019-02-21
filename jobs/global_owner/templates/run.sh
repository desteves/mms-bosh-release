#!/bin/bash
set -e

USER=<%= properties.mms.user %>
PASS=<%= properties.mms.pwd %>
FQDN=<%= properties.mms.fqdn %>
PORT=<%= properties.mms.port %>
MMSG=<%= properties.mms.org %>

echo "Waiting up to 4 minutes for HTTP(S) to load..."
## curl 7.35.0 doesnt have the --retry-connrefused option :/, using without it
curl ${FQDN}:${PORT} -sf --retry 8 --retry-delay 30
if [ $? -ne 0 ]; then
    echo "Failed get response from MMS to register Global Owner, trying anyways..."
fi

echo "Registering admin user (username: $USER, password: $PASS)"

###  Your password must be at least eight (8) characters long and contain at least one letter, one digit and one special character.

rp=$( \
curl -X POST   \
http://127.0.0.1:${PORT}/user/registerCall \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\",\"firstName\":\"Global\",\"lastName\":\"Owner\",\"newGroup\":true,\"jobResponsibility\":\"\",\"response\":\"\"}" )


e=$(echo $rp | grep  "\"errorCode\":\"NONE\"")

# for debugging
echo "rp" $rp
echo "e" $e

if [ -z $e ]; then  echo "Cannot get User registered, check logs"; exit 1; else echo "User registered"; exit 0; fi
