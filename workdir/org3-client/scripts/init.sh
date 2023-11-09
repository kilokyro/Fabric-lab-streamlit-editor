#!/usr/bin/env bash
cp -a ../ca/localMSP/peerOrganizations/org3.com/users .
if [ ! -d "tlsca" ]; then
        mkdir tlsca
fi
if [ ! -d "tmp" ]; then
        mkdir tmp
fi
find ../ca/localMSP/*/*/msp/tlscacerts/*.pem -exec cp {} tlsca/ \;
