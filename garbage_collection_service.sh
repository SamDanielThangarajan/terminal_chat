#!/bin/bash

## xpected variables
## GARBAGE_COLLECTION_SERVICE_DIRECTORY
## STATUS_REPORT_FILE

## Now a single counter is used for all services,
## this can be enhanced to have seperate counters for seperate services.

## Registration format
## ServiceName:toleranceminutes:path

internal_memory_file=${GARBAGE_COLLECTION_SERVICE_DIRECTORY}/gcs.db


#Default interval is 5 seconds, but can be customized
interval=5
[[ $# -eq 1 ]] && interval=$1


function report_status
{

   [[ -z ${STATUS_REPORT_FILE} ]] && return 

   if [[ ! -w ${STATUS_REPORT_FILE} ]]; then
      echo "No write permission on Status report file." 
      exit 1 
   fi

   echo "garbage collection service : $1" >> ${STATUS_REPORT_FILE}

}

function handle_registrations
{
   for path in `ls -1 ${GARBAGE_COLLECTION_SERVICE_DIRECTORY}/notify_* 2>/dev/null`; do
      local content=`cat ${path}`
      grep ${content} ${internal_memory_file} 2>/dev/null
      if [[ $? -eq 0 ]]; then
         sed -i '/${content}/d' ${internal_memory_file}
      fi
      local total_fields=`echo ${content} | awk -F':' '{print NF'}`

      if [[ ${total_fields} -ne 3 ]];then
         report_status "Invalid format, file : ${path}"
         rm -rf ${path}
         continue
      fi

      echo ${content} >> ${internal_memory_file}

      service_name=`echo ${content} | awk -F':' '{print $1}'`
      rm -rf ${path}
      report_status "Garbage collection registered for ${service_name}"
   done
}


function collect_garbages
{
   #servicename:tolerancemin:path
   for entry in `cat ${internal_memory_file}`; 
   do
      IFS=':' read -r -a tokens <<< "$entry"

      [[ ${#tokens[@]} -ne 3 ]] && continue
      report_status "Scanning : ${tokens[0]}"

      for file in `ls -1 ${tokens[2]}`;
      do
         if test `find ${tokens[2]}/${file} -mmin +${tokens[1]}`
         then
            report_status "$file is leaking, cleaing up"
            rm -rf ${tokens[2]}/${file}
         fi
      done
   done
}

###############################################
## Main
###


report_status "started..."

if [[ -z ${GARBAGE_COLLECTION_SERVICE_DIRECTORY} ]]; then
   echo "GARBAGE_COLLECTION_SERVICE_DIRECTORY not defined, exiting..."
   report_status "GARBAGE_COLLECTION_SERVICE_DIRECTORY not defined, exiting..."
   exit 1
fi

touch ${internal_memory_file}

while :
do

   handle_registrations

   collect_garbages

   sleep ${interval}

done

