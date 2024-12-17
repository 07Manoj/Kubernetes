#!/bin/bash

# Source the environment variables
source /root/code/.env

# Set the PASSWORD environment variable
export PASSWORD=$CODE_SERVER_PASSWORD

# Start code-server and nginx
code-server --install-extension redhat.ansible
code-server --host 0.0.0.0 --port 8080 --auth password &
nginx -g "daemon off;"