#!/bin/env bash

if [ -d genconf.d ]; then
    rm -rf genconf.d
fi
mkdir -p ./genconf.d/conf.d

KEYS="'
\${SERVER_NAME} \
\${SERVER_NAME_EXT} \
\${BACKEND_SERVERS} \
\${FRONTEND_SERVERS} \
\${FILE_CERT_CRT} \
\${FILE_CERT_KEY} \
\${BACKEND_SCHEME} \
\${FRONTEND_SCHEME} \
\${US_BACKEND} \
\${US_FRONTEND} \
\${US_PREFIX_BACKEND} \
\${US_PREFIX_FRONTEND} \
\${US_URL_HEALTH_BACKEND} \
\${US_URL_HEALTH_FRONTEND} \
'"

source ./template/default.env

envsubst "$KEYS" < ./template/tmpl.nginx.conf  > ./genconf.d/nginx.conf
envsubst "$KEYS" < ./template/tmpl.monitor.conf  > ./genconf.d/conf.d/monitor.conf
envsubst "$KEYS" < ./template/tmpl.default.conf  > ./genconf.d/conf.d/default.conf

for filename in ./vhost/*.env; do
    env_filename=$(basename "$filename")
    vhost_name="${env_filename%.*}"
    echo $env_filename
    echo $vhost_name
    source $filename
    envsubst "$KEYS" < ./template/tmpl.hitradex.conf  > ./genconf.d/conf.d/${vhost_name}.conf
done

envsubst "$KEYS" < ./template/tmpl.healthcheck.lua  > ./genconf.d/conf.d/healthcheck.lua

exit