#!/bin/bash

WORKING_DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"
cd $WORKING_DIR;

ruby surge.rb;
ruby clash.rb;
ruby pacs.rb;

cp assets/gost_https_docker.sh test/;
cp assets/clash_gost_forward.sh test/;
