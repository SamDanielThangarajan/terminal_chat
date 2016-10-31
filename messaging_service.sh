#!/bin/bash

## xpected variables
## MESSAGING_SERVICE_DIRECTORY
## STATUS_REPORT_FILE

# Add function to remove

return_msg=""

function report_status
{

   [[ -z ${STATUS_REPORT_FILE} ]] && return 

   if [[ ! -w ${STATUS_REPORT_FILE} ]]; then
      echo "No write permission on Status report file." 
      exit 1 
   fi

   echo "messaging service : $1" >> ${STATUS_REPORT_FILE}

}

function get_unique_id
{
   local req_id="get_id.msgserv"
   touch ${UNIQUE_ID_SERVICE_DIRECTORY}/request_${req_id}

   while :
   do
      if [[ -e ${UNIQUE_ID_SERVICE_DIRECTORY}/response_${req_id} ]]; then
         id=`cat ${UNIQUE_ID_SERVICE_DIRECTORY}/response_${req_id}`
         rm -rf ${UNIQUE_ID_SERVICE_DIRECTORY}/response_${req_id}
         break
      fi
   done

   return $id
}

function check_name
{

   get_unique_id
   uniq_id="$?.msgserv"

   cat >${REGISTRY_SERVICE_DIRECTORY}/request_${uniq_id} <<EOF
NAME_CHECK
$1
EOF

   while :
   do
      if [[ -e ${REGISTRY_SERVICE_DIRECTORY}/response_${uniq_id} ]] ; then
         response=`cat ${REGISTRY_SERVICE_DIRECTORY}/response_${uniq_id}`
         rm -rf ${REGISTRY_SERVICE_DIRECTORY}/response_${uniq_id}
         [[ ${response} = "EXISTS" ]] && return 0
         break
      fi
   done
   return 1

}


###############################################
## Main
###

report_status "started..."

if [[ -z ${MESSAGING_SERVICE_DIRECTORY} ]]; then
   echo "MESSAGING_SERVICE_DIRECTORY not defined, exiting..."
   report_status "MESSAGING_SERVICE_DIRECTORY not defined, exiting..."
   exit 1
fi

#Dependent services
if [[ -z ${UNIQUE_ID_SERVICE_DIRECTORY} ]]; then
   echo "UNIQUE_ID_SERVICE_DIRECTORY not defined, exiting..."
   report_status "UNIQUE_ID_SERVICE_DIRECTORY  not defined, exiting..."
   exit 1
fi
if [[ -z ${REGISTRY_SERVICE_DIRECTORY} ]]; then
   echo "REGISTRY_SERVICE_DIRECTORY not defined, exiting..."
   report_status "REGISTRY_SERVICE_DIRECTORY not defined, exiting..."
   exit 1
fi

if [[ -n ${GARBAGE_COLLECTION_SERVICE_DIRECTORY} ]] && [[ -d ${GARBAGE_COLLECTION_SERVICE_DIRECTORY} ]]; then
   echo "GARBAGE_COLLECTION_SERVICE_DIRECTORY is available!"
   report_status "GARBAGE_COLLECTION_SERVICE_DIRECTORY is available!"

   #Post a notification to consume, don't wait for response.
   get_unique_id
   notify_id=$?
   echo "MessagingService:3:${MESSAGING_SERVICE_DIRECTORY}" > ${GARBAGE_COLLECTION_SERVICE_DIRECTORY}/notify_${notify_id}
fi


while :
do

   for path in `ls -1 ${MESSAGING_SERVICE_DIRECTORY}/request_* 2>/dev/null`; do
      file=$(basename "$path")
      req_id=$(echo $file | sed 's/request_//')

      #First Line
      from=`head ${path}`
      #Second line
      to=`head -2 ${path} | tail -1`
      #third line
      msg=`head -3 ${path} | tail -1`

      report_status "Processing $file"


      check_name ${from}
      if [[ $? -eq 0 ]] ; then
         echo "from exists"

         check_name ${to}
         if [[ $? -eq 0 ]] ; then
            echo "to exists"
         fi

         mkdir -p ${MESSAGING_SERVICE_DIRECTORY}/${to}

         echo $msg > ${MESSAGING_SERVICE_DIRECTORY}/${to}/${req_id}

      fi

      rm -rf ${path}

   done

   sleep 1

done

