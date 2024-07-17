#!/bin/bash

set -ex

sudo snap set envtester \
    env.check=true \
    apps.myapp1.env.port=1111 \
    apps.myapp1.env.server=option \
    apps.myapp2.env.port=2222 \
    envfile=/var/snap/envtester/common/config.env \
    apps.myapp1.envfile=/var/snap/envtester/common/myapp1.env

sudo cp config.env /var/snap/envtester/common/config.env
sudo cp myapp1.env /var/snap/envtester/common/myapp1.env