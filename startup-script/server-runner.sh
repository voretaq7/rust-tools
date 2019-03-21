#!/bin/sh
#
# A script to start, restart, and handle wipes of
# your Rust dedicated server
#
# Requires the realpath(1) command
#
# Copyright 2019 - Michael Graziano (mikeg@bsd-box.net)
#

########################################
# Server Runner Configuration Settings #
#   !CHANGE THESE TO SOMETHING SANE!   #
########################################
IDENTITY="my_server_identity"
RCON_PASS="myPassword"
SERVER_LEVEL="Procedural Map"
SERVER_WORLDSIZE="3000"
SERVER_SEED="7589235"
SERVER_SALT="2789251"

# You probably don't need to change these settings.
SERVER_IP="0.0.0.0"
SERVER_PORT="28015"
RCON_IP="0.0.0.0"
RCON_PORT="28016"

# If you're running multiple servers on one host
# set UPDATE to "NO" and update them manually.
UPDATE="YES"

# If you're not storing these server-runner scripts
# in the rust_server steam directory change this.
RUST_DIR=`realpath ~/.steam/steamcmd/rust_server`

#########################################
# You shouldn't have to change anything #
# below this line. All the configurable #
# bits are set above.                   #
#########################################

SERVER_DIR="${RUST_DIR}/server/${IDENTITY}"
WIPE_TRIGGER="${SERVER_DIR}/WIPE"
WIPE_KEEP_BP="${SERVER_DIR}/KEEP_BP"
LOGFILE="${SERVER_DIR}/server.log"
MAXLOGS=5

BLUEPRINT_FILE="./player.blueprints.3.db"
BACKUP_FILE="${SERVER_DIR}/BACKUP/wipe_backup.tbz"
SERVER_CMD="${RUST_DIR}/RustDedicated"

while true ; do
  # Check to see if we're doing a wipe
  if [ -f ${WIPE_TRIGGER} ]; then
    echo "Wipe Trigger Present. Wiping the server."
    rm -f ${WIPE_TRIGGER}
    if [ -e ${WIPE_KEEP_BP} ]; then
      KEEP_BP=1
    else
      KEEP_BP=0
    fi
    rm -f ${BACKUP_FILE}
    echo "Creating a wipe backup at ${BACKUP_FILE}"
    mkdir -p `dirname ${BACKUP_FILE}`
    ( cd ${SERVER_DIR} ; tar cjf ${BACKUP_FILE} --exclude ./BACKUP . )
    rm ${SERVER_DIR}/*
    if [ ${KEEP_BP} -eq 1 ]; then
	    echo "    Restoring Blueprints"
	    (cd ${SERVER_DIR} ; tar xvf ${BACKUP_FILE} ${BLUEPRINT_FILE} ; touch KEEP_BP)
    fi
  fi

  # Update the server & start it.
  if [ "${UPDATE}" = "YES" ]; then
    cat <<EOF | steamcmd
login anonymous
force_install_dir rust_server
app_update 258550 verify
quit
EOF
  fi

  # Rotate log files, but only if there's an unrotated one waiting.
  # Don't stomp on all the logs if the server isn't starting up.
  if [ -e ${LOGFILE} ]; then
      for i in `seq $((MAXLOGS-1)) -1 1`; do
        if [ -e ${LOGFILE}.${i} ]; then
          mv ${LOGFILE}.${i} ${LOGFILE}.$((i+1))
        fi
      done
      mv ${LOGFILE} ${LOGFILE}.1
  fi

  # Actually start the Rust server.
  # Note that the server assumes we're in the same directory as the
  # binary (it assumes RustDedicated_Data is in the current directory)
  # so we cd there in a subshell and exec the server where it expects
  # to be started from.
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${RUST_DIR}/RustDedicated_Data/Plugins/x86_64
  (
    cd ${RUST_DIR}
    exec ${SERVER_CMD} -batchmode -logfile ${LOGFILE}    \
	+rcon.ip ${RCON_IP}                       \
	+rcon.port ${RCON_PORT}                   \
	+rcon.password "${RCON_PASS}"             \
	+rcon.web 1                               \
	+server.ip ${SERVER_IP}                   \
	+server.port ${SERVER_PORT}               \
	+server.identity "${IDENTITY}"            \
	+server.level "${SERVER_LEVEL}"           \
	+server.worldsize ${SERVER_WORLDSIZZE}    \
	+server.seed ${SERVER_SEED}               \
	+server.salt ${SERVER_SALT}               \
	-readcfg
  )

  echo ""
  echo "########## SERVER RESTART IN 5 SECONDS ##########"
  echo ""
  sleep 5
done

