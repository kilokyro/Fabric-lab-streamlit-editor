#!/usr/bin/env bash
cp -a ../ca/localMSP/peerOrganizations/org1.com/users/Admin@org1.com .
if [ ! -d "tlsca" ]; then
        mkdir tlsca
fi
if [ ! -d "tmp" ]; then
        mkdir tmp
fi
find ../ca/localMSP/*/*/msp/tlscacerts/*.pem -exec cp {} tlsca/ \;
