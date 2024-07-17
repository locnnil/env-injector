#!/bin/bash

set -ex

SNAPCRAFT_ENABLE_EXPERIMENTAL_EXTENSIONS=1 snapcraft -v
sudo snap install --dangerous ./envtester_demo_amd64.snap