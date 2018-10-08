#!/bin/bash

DATA_DIR=/var/vcap/store/database
DB_DIR=/var/vcap/packages/mongodb-4.0.1

${DB_DIR}/bin/mongod --shutdown
${DB_DIR}/bin/mongo admin --quiet --eval "db.adminCommand({shutdown : 1, force : true})"
rm -f ${DATA_DIR}/mongod.lock
rm -f /tmp/mongodb-27017.sock

exit 0