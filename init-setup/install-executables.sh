#!/bin/bash

export "SERVER_SETUP_DIR=/home/${USER}/serversetup"
export "BIN_DIRECTORY=/home/${USER}/.local/bin"
mkdir -p ${BIN_DIRECTORY}


COMMAND_FILE=fplayer
if [[ ! -f "${BIN_DIRECTORY}/${COMMAND_FILE}" ]]; then 
    ln -s "${BIN_DIRECTORY}/${COMMAND_FILE}" "${SERVER_SETUP_DIR}/tasker/${COMMAND_FILE}.sh"
fi

COMMAND_FILE=connectbt
if [[ ! -f "${BIN_DIRECTORY}/${COMMAND_FILE}" ]]; then 
    ln -s "${BIN_DIRECTORY}/${COMMAND_FILE}" "${SERVER_SETUP_DIR}/bin/${COMMAND_FILE}.sh"
fi

