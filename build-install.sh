#!/bin/bash

set -ex

# sudo snap remove envtester
SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1 snapcraft -v
sudo snap install --dangerous ./envtester_demo_amd64.snap