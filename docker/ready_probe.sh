#!/bin/bash

set -e

MEMBER_TYPE=${1}

if [ -z "${MEMBER_TYPE}" ]; then
  echo "Member type expected"
  exit 1
fi

/geode/bin/gfsh -e "status ${MEMBER_TYPE} --dir=./" | grep -q "is currently online"

