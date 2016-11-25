#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SERVICE_DIRECTORIES_ROOT=${SCRIPT_PATH}/tcs_working_dir
SOURCE_DIRECTORY=${SCRIPT_PATH}/tcs-src


# Service Directories
export UNIQUE_ID_SERVICE_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/unique_id_service/
export ROOM_SERVICE_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/room_service/
export REGISTRY_SERVICE_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/registry_service/
export MESSAGING_SERVICE_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/messaging_service/
export GARBAGE_COLLECTOR_SERVICE_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/garbage_collector_service/
export CHAT_CLIENT_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/chat_client/
export BACKUP_SERVICE_DIRECTORY=${SERVICE_DIRECTORIES_ROOT}/backup_service/


# Service Identifiers
export UNIQUE_ID_SRVID=uniq.serv
export BACKUP_SRVID=bkp.serv
export CHAT_CLIENT_ID=cc.serv
export GARBAGE_COLLECTOR_SRVID=grbg.serv
export MESSAGING_SRVID=msgng.srv
export REGISTRY_SRVID=reg.srv
export ROOM_SRVID=rms.srv
export SERVICE_REGISTRY_SRVID=srvreg.srv


# Service Report File
export STATUS_REPORT_FILE=${SERVICE_DIRECTORIES_ROOT}/status.log
touch ${STATUS_REPORT_FILE}

#Alias for services
alias start-back-up="${SOURCE_DIRECTORY}/back_up/backup.sh"
alias start-chat-client="${SOURCE_DIRECTORY}/chat_client/chat_client.sh"
alias start-gc="${SOURCE_DIRECTORY}/garbage_collector/garbage_collector.sh"
alias start-messaging="${SOURCE_DIRECTORY}/messaging/messaging.sh"
alias start-registry="${SOURCE_DIRECTORY}/registry/registry.sh"
alias start-room="${SOURCE_DIRECTORY}/room/room.sh"
alias start-srv-reg="${SOURCE_DIRECTORY}/service_registry/service_registry.sh"
alias start-uniq="${SOURCE_DIRECTORY}/unique_id/unique_id.sh"




