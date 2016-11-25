#!/bin/bash

## xpected variables
## MESSAGING_SERVICE_DIRECTORY
## STATUS_REPORT_FILE

# Add function to remove

return_msg=""
USER_NAME=""
RECEIVED_RESPONSE_MSG=""

LOGIN_FAILED=1
SIGN_UP_FAILED=2
INTERNAL_ERROR=-1

function report_status
{

   [[ -z ${STATUS_REPORT_FILE} ]] && return 

   if [[ ! -w ${STATUS_REPORT_FILE} ]]; then
      echo "No write permission on Status report file." 
      exit 1 
   fi

   echo "chat_client : $1" >> ${STATUS_REPORT_FILE}

}

function get_unique_id
{
   local req_id="get_id.chat_clnt"
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

#Params
#Directory
#Response File Name
#RECEIVED_RESPONSE_MSG is updated
function receive_response
{
   if [[ $# -ne 2 ]];then
      echo "Invalid params, Internal error!"
      exit ${INTERNAL_ERROR}
   fi
   RECEIVED_RESPONSE_MSG=""

   while :
   do
      if [[ -e ${1}/${2} ]]; then
         RECEIVED_RESPONSE_MSG=`cat ${1}/${2}`
         rm -rf ${1}/${2}
         break
      fi
   done
}

#Param username
function check_name
{

   get_unique_id
   local uniq_id="$?.chatsrv"
   local request_file_name=request_${uniq_id}
   local response_file_name=response_${uniq_id}

   cat >${REGISTRY_SERVICE_DIRECTORY}/${request_file_name} <<EOF
NAME_CHECK
$1
EOF

   receive_response ${REGISTRY_SERVICE_DIRECTORY} ${response_file_name}

   [[ ${RECEIVED_RESPONSE_MSG} = "EXISTS" ]] && return 0
   return 1

}



function login_options
{
   clear
   echo ""
   echo ""
   echo "**** Welcome to the Chat System ****"
   echo ""
   echo ""
   echo "1. Existing User? Login"
   echo "2. New User, Sign-up"
   printf 'Choose : '
   read _lo_input
   if [[ ${_lo_input} -eq 1 ]]; then
      printf "User Name:"
      read _lo_username
      printf "Password:"
      read _lo_password
      # TODO Now only checkname is used, later authentication can be used.
      check_name ${_lo_username}
      if [[ $? -eq 0 ]] ; then
         USER_NAME=${_lo_username}
      else
         #TODO: include password message also
         echo "User Name not valid.."
         exit ${LOGIN_FAILED}
      fi
   elif [[ ${_lo_input} -eq 2 ]]; then
      printf "User Name:"
      read _lo_username
      printf "Password:"
      read _lo_password

      get_unique_id
      local uniq_id="$?.chatsrv"
      cat >${REGISTRY_SERVICE_DIRECTORY}/request_${uniq_id} <<EOF
REGISTER
${_lo_username}:${_lo_password}
EOF

      receive_response ${REGISTRY_SERVICE_DIRECTORY} "response_${uniq_id}"

      if [[ ${RECEIVED_RESPONSE_MSG} = "OK" ]]; then
         echo "Registration Successful..."
         USER_NAME=${_lo_username}
      elif [[ ${RECEIVED_RESPONSE_MSG} = "ERROR : user already exists" ]]; then
         echo "Registration Failed : ${RECEIVED_RESPONSE_MSG}"
         exit ${SIGN_UP_FAILED}
      else
         echo "Registration failed! Internal error"
         exit ${INTERNAL_ERROR}
      fi
   else
      echo "Invalid option"
      exit 100
   fi
   return 1
}


#Params
#Username to chat with
#Message
function send_message_to
{

   get_unique_id
   local uniq_id=$?.chatsrv

   cat >${MESSAGING_SERVICE_DIRECTORY}/request_${uniq_id} <<EOF
${USER_NAME}
${1}
${2}
EOF

}

function read_message_from
{
   count=1
   while :
   do
      for file in `ls -tr1 ${MESSAGING_SERVICE_DIRECTORY}/${USER_NAME}/${1}_* 2>/dev/null`
      do
         cat $file | sed "s/^/$1:/"
         cat $file | sed "s/^/$1:/" >> ${USER_NAME}_chatwith_${1}
         rm -rf $file
      done
      count=$(expr ${count} + 1)
      [[ ${count} -eq 3 ]] && break;
   done
}


function chat_with
{
   check_name ${1}
   if [[ $? -ne 0 ]]; then
      echo "No such user"
      return 1
   fi

   #TODO need some working directpry
   touch ${USER_NAME}_chatwith_${1}

   echo "Type quit to end the chat session"
   while :
   do
      printf '${USER_NAME} :'
      read -t 10 _cw_txt
      if [[ $? -ne 0 ]];then
         read_message_from ${1}
         continue
      fi
      [[ ${_cw_txt} = "quit" ]] && break
      echo "${USER_NAME} : ${_cw_txt}" >> ${USER_NAME}_chatwith_${1}
      send_message_to ${1} "${_cw_txt}"
      read_message_from ${1}
   done


}


function present_user_main_screen
{
   clear
   echo ""
   echo ""
   echo "**** Welcome ${USER_NAME} ****"
   echo ""
   echo ""
   echo "1. List users"
   echo "2. Chat"
   echo "3. Send Message"
   echo "4. List Rooms"
   echo "5. Read Messages"
   echo "6. List rooms"
   echo "7. Join Room"
   echo "8. Create Room"
   echo "9. Log off"

  
   printf 'Choose :'
   read _pumsc_input

   [[ ${_pumsc_input} -eq 9 ]] && exit 0

   get_unique_id
   local uniq_id="$?.chatsrv"

   if [[ ${_pumsc_input} -eq 1 ]]; then
      cat >${REGISTRY_SERVICE_DIRECTORY}/request_${uniq_id} <<EOF
LIST_USERS
EOF
      receive_response ${REGISTRY_SERVICE_DIRECTORY} "response_${uniq_id}"

      echo""
      echo""
      echo "Available Users..."
      echo ${RECEIVED_RESPONSE_MSG} | tr " " "\n"

   elif [[ ${_pumsc_input} -eq 2 ]]; then
      printf "Enter the user name to chat with : "
      read __pumsc_user_to_chat
      chat_with ${__pumsc_user_to_chat}
   else
      echo "Not supported operation"
   fi


   read -t 15 dummy_ip



}


###############################################
## Main
###

report_status "started..."

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

if [[ -z ${MESSAGING_SERVICE_DIRECTORY} ]]; then
   echo "MESSAGING_SERVICE_DIRECTORY not defined, exiting..."
   report_status "MESSAGING_SERVICE_DIRECTORY not defined, exiting..."
   exit 1
fi

login_options

while :
do
   present_user_main_screen
done

#if [[ -n ${GARBAGE_COLLECTOR_SERVICE_DIRECTORY} ]] && [[ -d ${GARBAGE_COLLECTOR_SERVICE_DIRECTORY} ]]; then
#   echo "GARBAGE_COLLECTOR_SERVICE_DIRECTORY is available!"
#   report_status "GARBAGE_COLLECTOR_SERVICE_DIRECTORY is available!"
#
#   #Post a notification to consume, don't wait for response.
#   get_unique_id
#   notify_id=$?
#   echo "MessagingService:3:${MESSAGING_SERVICE_DIRECTORY}" > ${GARBAGE_COLLECTOR_SERVICE_DIRECTORY}/notify_${notify_id}
#fi


#while :
#do
#
#   for path in `ls -1 ${MESSAGING_SERVICE_DIRECTORY}/request_* 2>/dev/null`; do
#      file=$(basename "$path")
#      req_id=$(echo $file | sed 's/request_//')
#
#      #First Line
##      from=`head ${path}`
#      #Second line
#      to=`head -2 ${path} | tail -1`
#      #third line
#      msg=`head -3 ${path} | tail -1`
#
#      report_status "Processing $file"
#
#
#      check_name ${from}
#      if [[ $? -eq 0 ]] ; then
#         echo "from exists"
#
#         check_name ${to}
#         if [[ $? -eq 0 ]] ; then
#            echo "to exists"
#         fi
#
#         mkdir -p ${MESSAGING_SERVICE_DIRECTORY}/${to}
#
#         echo $msg > ${MESSAGING_SERVICE_DIRECTORY}/${to}/${req_id}
#
#      fi
#
#      rm -rf ${path}
#
#   done
#
#   sleep 1
#
#done

