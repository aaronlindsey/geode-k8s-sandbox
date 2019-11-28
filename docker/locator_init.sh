#!/bin/bash

set -e
source utils.bash

echo "Waiting for previous locators..."
LOCATORS="$(wait_for_min_locator_count ${POD_INDEX})"

java \
  -server \
  -classpath "/geode/lib/geode-core-1.10.0.jar:/geode/lib/geode-dependencies.jar" \
  -Dgemfire.default.locators=$LOCATORS \
  -Dgemfire.enable-cluster-configuration=true \
  -Dgemfire.load-cluster-configuration-from-dir=false \
  -Dgemfire.launcher.registerSignalHandlers=true \
  -Djava.awt.headless=true \
  -Dsun.rmi.dgc.server.gcInterval=9223372036854775806 \
  org.apache.geode.distributed.LocatorLauncher start locator-${POD_INDEX}

