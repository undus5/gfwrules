#!/bin/bash

WORKING_DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"
cd $WORKING_DIR;

./scripts/update_china_ip.sh;
ruby ./scripts/generate_surge.rb;
ruby ./scripts/generate_clash.rb;
ruby ./scripts/generate_pacs.rb;
