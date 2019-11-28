# Index of the current pod in the StatefulSet
POD_INDEX=${HOSTNAME##*-}

# Discover locator services and print them on separate lines in the format hostname[port]
lookup_locators() {
  dig +search +short "_locator._tcp.geode-locator" SRV | while read priority weight port target; do
    if [ -n "$target" ]; then
      echo "${target%.}[$port]"
    fi
  done
}

# Wait for a minimum number of locators. Returns the locators in comma-separated format host1[port1],host2[port2]...
wait_for_min_locator_count() {
  local min_count=$1

  if [ -z "${min_count}" ]; then
    return 1
  fi

  while true; do
    local locators="$(lookup_locators)"

    if [ -z "${locators}" ]; then
      local locator_count=0
    else
      local locator_count=$(echo "${locators}" | wc -l)
    fi

    if [ ${locator_count} -ge ${min_count} ]; then
      break
    fi

    sleep 2
  done

  echo "${locators}" | paste -d',' -s -
}

