#!/bin/bash

## xpected variables
## REGISTRY_SERVICE_DIRECTORY
## STATUS_REPORT_FILE

# Add function to remove

database_file=${REGISTRY_SERVICE_DIRECTORY}/registry.db
return_msg=""

function report_status
{

   [[ -z ${STATUS_REPORT_FILE} ]] && return 

   if [[ ! -w ${STATUS_REPORT_FILE} ]]; then
      echo "No write permission on Status report file." 
      exit 1 
   fi

   echo "registry identifier service : $1" >> ${STATUS_REPORT_FILE}

}

function check_name
{
   return_msg="NOT EXISTS"
   for matched_line in `grep $1 ${database_file}`; do
      name=`echo "${matched_line}" | awk -F':' '{print $1}'`
      if [[ $1 = $name ]];then
         return_msg="EXISTS"
         break
      fi
   done
}

function register
{


   IFS=':' tokens=( $1 )

   if [[ ${#tokens[@]} -ne 2 ]];then
      return_msg="ERROR : Invalid format"
   fi

   check_name ${tokens[0]}
   if [[ ${return_msg} = "EXISTS" ]]; then
      return_msg="ERROR : user already exists"
      return
   fi

   echo "${tokens[0]}:${tokens[1]}" >> ${database_file}

   return_msg="OK"
}


###############################################
## Main
###

report_status "started..."

if [[ -z ${REGISTRY_SERVICE_DIRECTORY} ]]; then
   echo "REGISTRY_SERVICE_DIRECTORY not defined, exiting..."
   report_status "REGISTRY_SERVICE_DIRECTORY not defined, exiting..."
   exit 1
fi

if [[ -n ${GARBAGE_COLLECTION_SERVICE_DIRECTORY} ]] && [[ -d ${GARBAGE_COLLECTION_SERVICE_DIRECTORY} ]]; then
   report_status "GARBAGE_COLLECTION_SERVICE_DIRECTORY available..."
   echo "RegistryService:3:${REGISTRY_SERVICE_DIRECTORY}" > ${GARBAGE_COLLECTION_SERVICE_DIRECTORY}/notify_registry
fi

if [[ ! -e ${database_file} ]]; then
   report_status "Registry datbase created..."
   touch ${database_file}
fi


while :
do

   for path in `ls -1 ${REGISTRY_SERVICE_DIRECTORY}/request_* 2>/dev/null`; do
      file=$(basename "$path")
      req_id=$(echo $file | sed 's/request_//')

      read -r cmd < ${path}
      contents=`head -2 ${path} | tail -1`

      report_status "Processing $file, command : ${cmd}"

      case "${cmd}" in
         REGISTER)
            register ${contents}
            ;;
         NAME_CHECK)
            check_name ${contents}
            ;;
         *)
            return_msg="ERROR : Invalid command"
      esac

      echo "${return_msg}" > ${REGISTRY_SERVICE_DIRECTORY}/response_${req_id}

      rm -rf ${path}
   done

   sleep 1

done

