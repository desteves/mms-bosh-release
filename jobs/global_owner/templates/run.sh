#!/bin/bash
set -e

USER=<%= properties.mms.user %>
PASS=<%= properties.mms.pwd %>
FQDN=<%= properties.mms.fqdn %>
PORT=<%= properties.mms.port %>
MMSG=<%= properties.mms.org %>

echo "Waiting up to 2 minutes for HTTP(S) to load..."
## curl 7.35.0 doesnt have the --retry-connrefused option :/, using without it
curl localhost:${PORT} -sf --retry 4 --retry-delay 30
if [ $? -ne 0 ]; then
    echo "Failed to register Global Owner. Check Logs and Try Again"
    exit 1
fi

echo "Registering admin user (username: $USER, password: $PASS)"
###  Your password must be at least eight (8) characters long and contain at least one letter, one digit and one special character.
curl -X POST \
http://localhost:${PORT}/user/registerCall \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\",\"firstName\":\"Global\",\"lastName\":\"Owner\",\"newGroup\":true,\"jobResponsibility\":\"\",\"response\":\"\"}" 

exit 
