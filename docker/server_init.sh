#!/bin/bash

set -e
source utils.bash

echo "Waiting for at least one locator..."
LOCATORS="$(wait_for_min_locator_count 1)"

java \
  -server \
  -classpath "/geode/lib/geode-core-1.10.0.jar:/geode/lib/geode-dependencies.jar" \
  -Dgemfire.default.locators=$LOCATORS \
  -Dgemfire.start-dev-rest-api=false \
  -Dgemfire.use-cluster-configuration=true \
  -Dgemfire.launcher.registerSignalHandlers=true \
  -Djava.awt.headless=true \
  -Dsun.rmi.dgc.server.gcInterval=9223372036854775806 \
  org.apache.geode.distributed.ServerLauncher start server-${POD_INDEX}

