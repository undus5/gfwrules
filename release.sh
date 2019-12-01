#!/bin/bash

WORKING_DIR="$( cd -P "$( dirname "$BASH_SOURCE" )" > /dev/null 2>&1 && pwd -P )"
cd $WORKING_DIR;

ruby ./scripts/surge.rb;
ruby ./scripts/clash.rb;
ruby ./scripts/pacs.rb;
