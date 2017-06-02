FROM ubuntu

# Copy the service
RUN mkdir -p /home/service/scripts /tmp/tcs-working-dir/
ADD unique_id.sh /home/service/scripts/unique_id.sh

# Add the user
ARG USER
ARG UID
RUN useradd -M ${USER} -s /bin/bash -u ${UID}
RUN chown -R ${USER} /home/service/ /tmp/tcs-working-dir/
USER ${USER}


# Env for script to work
ENV UNIQUE_ID_SERVICE_DIRECTORY /tmp/tcs-working-dir/unique_id_service/
ENV ROOM_SERVICE_DIRECTORY /tmp/tcs-working-dir/room_service/
ENV REGISTRY_SERVICE_DIRECTORY /tmp/tcs-working-dir/registry_service/
ENV MESSAGING_SERVICE_DIRECTORY /tmp/tcs-working-dir/messaging_service/
ENV GARBAGE_COLLECTOR_SERVICE_DIRECTORY /tmp/tcs-working-dir/garbage_collector_service/
ENV CHAT_CLIENT_DIRECTORY /tmp/tcs-working-dir/chat_client/
ENV BACKUP_SERVICE_DIRECTORY /tmp/tcs-working-dir/backup_service/

# Start the service
CMD ["/home/service/scripts/unique_id.sh"]

#Run this service with -v ${SERVICE_DIRECTORIES_ROOT}:/tmp/tcs-working-dir/

