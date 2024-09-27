#!/bin/bash

set -e

sudo snap set envtester \
    env.test-global=glob \
    env.test-port=0000 \
    apps.app1.env.test-port=1111 \
    apps.app1.env.test-server=option \
    apps.app2.env.test-port=2222

sudo snap set envtester \
    envfile=/var/snap/envtester/common/global.env \
    apps.app1.envfile=/var/snap/envtester/common/myapp1.env

sudo cp global.env /var/snap/envtester/common/global.env
sudo cp myapp1.env /var/snap/envtester/common/myapp1.env

echo "myapp1 options"
envtester.myapp1

echo "myapp1 tests"
envtester.myapp1 | grep TEST_GLOBAL=glob
envtester.myapp1 | grep TEST_ORACULAR=Oriole
envtester.myapp1 | grep TEST_NOBLE=Numbat
envtester.myapp1 | grep TEST_PORT=1111 # not 0000
envtester.myapp1 | grep TEST_SERVER=option # not file
envtester.myapp1 | grep TEST_HOST=localhost

echo "myapp2 options"
envtester.myapp2

echo "myapp2 tests"
envtester.myapp2 | grep TEST_GLOBAL=glob
envtester.myapp2 | grep TEST_ORACULAR=Oriole
envtester.myapp2 | grep TEST_NOBLE=Numbat
envtester.myapp2 | grep TEST_PORT=2222 # not 0000

echo "complete"