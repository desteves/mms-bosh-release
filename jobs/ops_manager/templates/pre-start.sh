#!/bin/bash

RUN_DIR="/var/vcap/sys/run/ops_manager"
LOG_DIR="/var/vcap/sys/log/ops_manager"
OPS_DIR="/var/vcap/store/ops_manager"
PIDFILE="${RUN_DIR}/pid"

DATA_DIR="/var/vcap/store/database"
DB_DIR="/var/vcap/packages/mongodb-4.0.8"

APP_DIR="/var/vcap/packages/mms-4.0.9"
APP_NAME="mms-app"
APP_ENV="hosted"
APP_ID="mms"

MMS_USER=vcap
BASE_PORT=8080
BASE_SSL_PORT=8443
FQDN=localhost

JAVA_HOME="${APP_DIR}/jdk"
SYSCONFIG="${APP_DIR}/conf/mms.conf"
ENC_KEY_PATH="${APP_DIR}/gen.key"
MONGOVERSIONS_DIR="${APP_DIR}/automation_versions_directory"

ENC_KEY="EJmS9BJxqCdPrV8P4tZtfpGY2xqcvNfs"
URI_STR="mongodb://localhost:27017/"
email="noreply@localhost.com"

PATH=${PATH}:${RUN_DIR}:${APP_DIR}/bin:${DATA_DIR}/bin

mkdir -p ${RUN_DIR} ${LOG_DIR} ${OPS_DIR} ${MONGOVERSIONS_DIR}  ${DATA_DIR}
touch ${ENC_KEY_PATH}
chown -R vcap:vcap ${RUN_DIR} ${LOG_DIR} ${OPS_DIR} ${APP_DIR}/conf/ ${ENC_KEY_PATH} ${MONGOVERSIONS_DIR}  ${DATA_DIR}
echo ${ENC_KEY} | base64 -d >  ${ENC_KEY_PATH}
chmod 600 ${ENC_KEY_PATH}
sed -e "s|^\(LOG_PATH=\).*|\1${LOG_DIR}|" \
  -e "s|^\(MMS_USER=\).*|\1${MMS_USER}|" \
  -e "s|^\(JAVA_HOME=\).*|\1${JAVA_HOME}|" \
  -e "s|^\(ENC_KEY_PATH=\).*|\1${ENC_KEY_PATH}|" \
  -i.bak ${SYSCONFIG}
cat <<EOF > ${APP_DIR}/conf/conf-mms.properties
mongo.ssl=false
mongo.mongoUri=${URI_STR}
# mms.centralUrl=http://${FQDN}:${BASE_PORT} # check if this can be removed, issue downloading agents
mms.backupCentralUrl=http://${FQDN}:8081
mms.fromEmailAddr=$email
mms.replyToEmailAddr=$email
mms.adminEmailAddr=$email
mms.emailDaoClass=com.xgen.svc.core.dao.email.JavaEmailDao
mms.backup.minimumOplogWindowHours=0.01
mms.https.ClientCertificateMode=None
mms.mail.port=25
mms.mail.transport=smtp
mms.mail.hostname=localhost
mms.ignoreInitialUiSetup=true
automation.versions.directory=${MONGOVERSIONS_DIR}
mms.user.invitationOnly=false
EOF

[[ -f "${SYSCONFIG}" ]] && . "${SYSCONFIG}"


${DB_DIR}/bin/mongod --port 27017 --dbpath ${DATA_DIR} --fork --logpath ${LOG_DIR}/pre-start-database.stdout.log
if [[ $? != 0 ]]; then
  exit 1
fi

${JAVA_HOME}/bin/${APP_NAME} \
  -Dmms.migrate=all \
  -Dcore.preflight.class=com.xgen.svc.mms.MmsPreFlightCheck \
  -Dlog_path=${LOG_DIR}/pre-start.stdout \
  -Duser.timezone=GMT    \
  -Dfile.encoding=UTF-8 \
  -Dserver-env=${APP_ENV} \
  -Dapp-id=${APP_ID} \
  -Dmms.keyfile=${ENC_KEY_PATH} \
  -Xmx256m -XX:-OmitStackTraceInFastThrow \
  -classpath ${APP_DIR}/classes/mms.jar:${APP_DIR}/conf:${APP_DIR}/lib/* \
  com.xgen.svc.common.migration.MigrationRunner \
  >>  ${LOG_DIR}/pre-start.stdout.log \
  2>> ${LOG_DIR}/pre-start.stderr.log
if [[ $? != 0 ]]; then
  exit 1
fi
exit 0
