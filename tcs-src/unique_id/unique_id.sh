#!/bin/bash

## xpected variables
## UNIQUE_ID_SERVICE_DIRECTORY
## STATUS_REPORT_FILE

## Now a single counter is used for all services,
## this can be enhanced to have seperate counters for seperate services.

running_message_id=0
internal_memory_file=${UNIQUE_ID_SERVICE_DIRECTORY}/my_memory.internal

function report_status
{

   [[ -z ${STATUS_REPORT_FILE} ]] && return 

   if [[ ! -w ${STATUS_REPORT_FILE} ]]; then
      echo "No write permission on Status report file." 
      exit 1 
   fi

   echo "unique identifier service : $1" >> ${STATUS_REPORT_FILE}

}

function initialize
{

   if [[ -e ${internal_memory_file} ]]; then
      running_message_id=$(cat ${internal_memory_file})
      report_status "Restoring to last issued unique id : ${running_message_id}"
   fi

   if [[ -n ${GARBAGE_COLLECTOR_SERVICE_DIRECTORY} ]] && [[ -d ${GARBAGE_COLLECTOR_SERVICE_DIRECTORY} ]]; then
      report_status "GARBAGE_COLLECTOR_SERVICE_DIRECTORY available..."
      echo "UniqueService:3:${UNIQUE_ID_SERVICE_DIRECTORY}" > ${GARBAGE_COLLECTOR_SERVICE_DIRECTORY}/notify_unique
   fi
}

function save_state_and_exit
{
   echo ${running_message_id} > ${internal_memory_file}
   report_status "Unique message service state saved."
   exit 0
}

###############################################
## Main
###


report_status "started..."

if [[ -z ${UNIQUE_ID_SERVICE_DIRECTORY} ]]; then
   echo "UNIQUE_ID_SERVICE_DIRECTORY not defined, exiting..."
   report_status "UNIQUE_ID_SERVICE_DIRECTORY not defined, exiting..."
   exit 1
fi

initialize

trap "save_state_and_exit" SIGINT SIGTERM

while :
do

   for path in `ls -1 ${UNIQUE_ID_SERVICE_DIRECTORY}/request_* 2>/dev/null`; do
      file=$(basename "$path")
      report_status "Processing $file"
      req_id=$(echo $file | sed 's/request_//')
      echo "${running_message_id}" > ${UNIQUE_ID_SERVICE_DIRECTORY}/response_${req_id}
      rm -rf ${path}
      report_status "${running_message_id} issued for request ${req_id}" 
      running_message_id=$(($running_message_id+1))
   done

   sleep 1

done

