#!/bin/bash

WORKING_DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"
cd $WORKING_DIR;

./scripts/generate_pacs.rb "$@"
./scripts/generate_surge.rb "$@"
./scripts/generate_clash.rb "$@"
