#!/usr/bin/env bash
cp -a ../ca/localMSP/ordererOrganizations/org4.com/users/Admin@org4.com .
if [ ! -d "tlsca" ]; then
        mkdir tlsca
fi
if [ ! -d "tmp" ]; then
        mkdir tmp
fi
find ../ca/localMSP/*/*/msp/tlscacerts/*.pem -exec cp {} tlsca/ \;
