#!/usr/bin/env sh
# SPDX-License-Identifier: MIT

JAVA_DEBUG_OPTIONS=""

wait_loop() {
    while true
    do
	    echo "Press [CTRL+C] to stop.."
	    sleep 120
    done
}

debug () {
    wait_loop
}

# Start with localserver settings 
localserver () {
    check_setup

    profiles="pds_localserver"
    database_options=""
    storage_options="-Dsechub.pds.storage.sharedvolume.upload.dir=$SHARED_VOLUME_UPLOAD_DIR"

    if [ "$POSTGRES_ENABLED" = true ]
    then
        echo "Using database: Postgres"

        profiles="$profiles,pds_postgres"
        database_options="-Dspring.datasource.url=$DATABASE_CONNECTION -Dspring.datasource.username=$DATABASE_USERNAME  -Dspring.datasource.password=$DATABASE_PASSWORD"

        echo "Database connection:"
        echo " * URL: $DATABASE_CONNECTION"
        echo " * Username: $DATABASE_USERNAME"
    fi

    if [ "$S3_ENABLED" = true ]
    then
        echo "Using object storage"

        storage_options="-Dsechub.pds.storage.s3.endpoint=$S3_ENDPOINT"
        storage_options="$storage_options -Dsechub.pds.storage.s3.bucketname=$S3_BUCKETNAME"
        storage_options="$storage_options -Dsechub.pds.storage.s3.accesskey=$S3_ACCESSKEY"
        storage_options="$storage_options -Dsechub.pds.storage.s3.secretkey=$S3_SECRETKEY"

        echo "Object storage:"
        echo " * Endpoint: $S3_ENDPOINT"
        echo " * Bucketname: $S3_BUCKETNAME"
        echo " * Accesskey: $S3_ACCESSKEY"
    fi

	# -silent: disables telemetry calls, of the call home addon: https://www.zaproxy.org/docs/desktop/addons/call-home/
	#   This addon is mandatory now but the telemetry calls can be deactivated.
	#   This feature addtionally disables automated update calls, e.g. to update extensions.
	#   Otherwise, if you want to use a specific versions of extensions e.g. for testing reasons, ZAP would automatically check for updates.
    nohup owasp-zap -daemon -silent -nostdout -host 127.0.0.1 -port 8080 -config api.key="$ZAP_API_KEY" &

    # Regarding entropy collection:
    #   with JDK 8+ the "obscure workaround using file:///dev/urandom 
    #   and file:/dev/./urandom is no longer required."
    #   (source: https://docs.oracle.com/javase/8/docs/technotes/guides/security/enhancements-8.html)
    java $JAVA_DEBUG_OPTIONS $database_options \
        $storage_options \
        -Dfile.encoding=UTF-8 \
        -Dspring.profiles.active=$profiles \
        -DsecHub.pds.admin.userid=$ADMIN_USERID \
        -Dsechub.pds.admin.apitoken=$ADMIN_APITOKEN \
        -DsecHub.pds.techuser.userid=$TECHUSER_USERID \
        -Dsechub.pds.techuser.apitoken=$TECHUSER_APITOKEN \
        -Dsechub.pds.config.execute.queue.max=$PDS_CONFIG_EXECUTE_QUEUE_MAX \
        -Dsechub.pds.config.execute.worker.thread.count=$PDS_CONFIG_EXECUTE_WORKER_THREAD_COUNT \
        -Dsechub.pds.workspace.rootfolder=/workspace \
        -Dsechub.pds.config.file=/pds/pds-config.json \
        -Dserver.port=8444 \
        -Dserver.address=0.0.0.0 \
        -jar /pds/sechub-pds-$PDS_VERSION.jar
    
    keep_container_alive_or_exit
}

keep_container_alive_or_exit() {
    if [ "$KEEP_CONTAINER_ALIVE_AFTER_PDS_CRASHED" = "true" ]
    then
        echo "[ERROR] PDS crashed, but keeping the container alive."
        wait_loop
    fi
}

check_setup () {
    check_variable "$ADMIN_USERID" "ADMIN_USERID"
    check_variable "$ADMIN_APITOKEN" "ADMIN_APITOKEN"
    check_variable "$TECHUSER_USERID" "TECHUSER_USERID"
    check_variable "$TECHUSER_APITOKEN" "TECHUSER_APITOKEN"
    check_variable "$SHARED_VOLUME_UPLOAD_DIR" "SHARED_VOLUME_UPLOAD_DIR"
    check_variable "$ZAP_API_KEY" "ZAP_API_KEY"
}

check_variable () {
    value="$1"
    name="$2"

    if [ -z "$value" ]
    then
        echo "Environment variable $name not set."
        exit 1
    fi
}

if [ "$JAVA_ENABLE_DEBUG" = "true" ]
then
    # By using `address=*:15024` the server will bind 
    # all available IP addresses to port 15024
    # otherwise the container cannot be accessed from outside
    JAVA_DEBUG_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,address=*:15024"
fi

if [ "$PDS_START_MODE" = "localserver" ]
then
    localserver
else
    debug
fi