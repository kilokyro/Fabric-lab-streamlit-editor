#!/usr/bin/env bash
cp -a ../ca/localMSP/peerOrganizations/org2.com/users/Admin@org2.com .
if [ ! -d "tlsca" ]; then
        mkdir tlsca
fi
if [ ! -d "tmp" ]; then
        mkdir tmp
fi
find ../ca/localMSP/*/*/msp/tlscacerts/*.pem -exec cp {} tlsca/ \;
