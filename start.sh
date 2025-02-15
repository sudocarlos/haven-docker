#!/usr/bin/env bash
if [[ "$TOR_ENABLED" == 1 ]]; then
	echo "HiddenServiceDir /var/lib/tor/haven/" >> /etc/tor/torrc; \
	echo "HiddenServicePort 80 ${RELAY_BIND_ADDRESS}:${RELAY_PORT}" >> /etc/tor/torrc
    tor &
fi
cd /haven
./haven