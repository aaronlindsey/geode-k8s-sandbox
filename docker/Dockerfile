FROM apachegeode/geode:1.10.0

# BIND tools for querying SRV DNS records
RUN apk add --no-cache bind-tools

COPY locator_init.sh server_init.sh ready_probe.sh utils.bash ./
RUN chmod +x locator_init.sh server_init.sh ready_probe.sh
