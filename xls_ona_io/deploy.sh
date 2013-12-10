#!/bin/bash

[[ -z "$1" ]] && echo "Usage: $0 version-of-json-to-xls-delivery-to-deploy" >&2 && exit 1
VERSION=$1
SNAPSHOT_VERSION=${VERSION}
FILENAME="json-to-xls-${VERSION}.tar"
SNAPSHOT_VERSION=`echo $VERSION | cut -d "-" -f1`
EXTRACTED_DIRECTORY="json-to-xls-'${SNAPSHOT_VERSION}'-SNAPSHOT/bin"

#copying json-to-xls.yml to Prod
scp json-to-xls.yml xlsonaio://root/config-json-to-xls.yml

scp keystore.jks xlsonaio://root/keystore.jks
scp api.txt xlsonaio://root/api.txt

echo "FETCHING FILE: ${FILENAME}"
ssh xlsonaio '\
    export time=`date +%F_%T`; \
    mkdir -p old/backup-json-to-xls-'${VERSION}'.'${time}' && \
	pg_dump -U json_to_xls_user json_to_xls > old/backup-json-to-xls-'${VERSION}'.'${time}'/backup-json-to-xls-database-'${VERSION}'.'${time}' && \
    ([[ `ls | grep -q "json-to-xls.*"; echo $?` = 0 ]] && /bin/mv -f json-to-xls* old/backup-json-to-xls-'${VERSION}'.'${time}' || true) && \
    wget http://nexus.motechproject.org/content/repositories/json-to-xls/io/ei/jsontoxls/json-to-xls/'${SNAPSHOT_VERSION}'-SNAPSHOT/'${FILENAME}' && \
    tar -xvf '${FILENAME}' && \
	echo EXTRACTED DIRECTORY '${EXTRACTED_DIRECTORY}' && \
	cd '${EXTRACTED_DIRECTORY}' && \  
	cp /root/keystore.jks /root/'${EXTRACTED_DIRECTORY}'/keystore.jks && \
	cp /root/api.txt /root/'${EXTRACTED_DIRECTORY}'/api.txt && \
	echo "Migrating Database"	&& \
	sh ./json-to-xls db migrate ../../config-json-to-xls.yml && \
	echo "Starting the service" && \
	sh ./json-to-xls server ../../config-json-to-xls.yml &'
	

