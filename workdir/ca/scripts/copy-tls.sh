#!/bin/bash

for dir in $(find $PWD/../../ca/config/ -maxdepth 2 -mindepth 2)
do
	DEST=$(echo $dir|sed 's/\.\.\/\.\.\/ca\/config/tls/g')
	if [ ! -d "$DEST" ]; then
		mkdir -p $DEST
	fi
	cp $dir/tls-cert.pem $DEST
done
