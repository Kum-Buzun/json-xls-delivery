#!/bin/bash

[[ -z "$1" ]] && echo "Usage: $0 version-of-json-to-xls-delivery-to-deploy" >&2 && exit 1

VERSION=$1
FILENAME="json-to-xls-${VERSION}-shadow.jar"

#copying json-to-xls.yml to Prod
scp json-to-xls.yml prod://home/motech/config-json-to-xls.yml


echo "FETCHING FILE: ${FILENAME}"
ssh prod '\
    export time=`date +%F_%T`; \
    mkdir -p old/backup-json-to-xls.${time} && \
    ([[ `ls | grep -q "json-to-xls.*"; echo $?` = 0 ]] && /bin/mv -f json-to-xls* old/backup-json-to-xls.${time} || true) && \
    wget http://nexus.motechproject.org/content/repositories/json-to-xls/io/ei/jsontoxls/json-to-xls/'${VERSION}'/'${FILENAME}' && \
    java -Ddw.http.port=9090 -jar '${FILENAME}' server config-json-to-xls.yml'
