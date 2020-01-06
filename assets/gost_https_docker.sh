#!/bin/bash

DOMAIN=""
USER=""
PASS=""
PORT=443

BIND_IP=0.0.0.0
CERT_DIR=/etc/letsencrypt
CERT=${CERT_DIR}/live/${DOMAIN}/fullchain.pem
KEY=${CERT_DIR}/live/${DOMAIN}/privkey.pem
sudo docker run -d --name gost \
    -v ${CERT_DIR}:${CERT_DIR}:ro \
    --net=host ginuerzh/gost \
    -L "http2://${USER}:${PASS}@${BIND_IP}:${PORT}?cert=${CERT}&key=${KEY}&probe_resist=code:404"

# -F "http://127.0.0.1:7890"
# pm2 start clash -- -d .
