#!/bin/bash
set -e

if [[ "$1" == "zenzo-cli" || "$1" == "zenzo-tx" || "$1" == "zenzod" || "$1" == "test_zenzo" ]]; then
	mkdir -p "$DOGECOIN_DATA"

	CONFIG_PREFIX=""
    if [[ "${BITCOIN_NETWORK}" == "testnet" ]]; then
        CONFIG_PREFIX=$'testnet=1\n'
    fi
    if [[ "${BITCOIN_NETWORK}" == "mainnet" ]]; then
        CONFIG_PREFIX=$'mainnet=1\n'
    fi

	cat <<-EOF > "$ZENZO_DATA/zenzo.conf"
	${CONFIG_PREFIX}
	printtoconsole=1
	rpcallowip=::/0
	${ZENZO_EXTRA_ARGS}
	EOF
	chown zenzo:zenzo "$ZENZO_DATA/zenzo.conf"

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R zenzo "$ZENZO_DATA"
	ln -sfn "$ZENZO_DATA" /home/zenzo/.zenzo
	chown -h zenzo:zenzo /home/zenzo/.zenzo
	exec gosu zenzo "$@"
else
	exec "$@"
fi
