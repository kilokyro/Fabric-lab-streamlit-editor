#!/usr/bin/env bash
CHANNEL_NAME=$1

peer channel fetch config config_block.pb -c $CHANNEL_NAME -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq .data.data[].payload.data.config config_block.json >config.json
jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST.$DOMAIN'","port": '$PORT'}]},"version": "0"}}' config.json >config_modified.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input config_modified.json --type common.Config --output config_modified.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated config_modified.pb --output config_update.pb
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}'|jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
peer channel update -f config_update_in_envelope.pb -c $CHANNEL_NAME -o orderer1.org4.com:4150 --tls --cafile $ORDERER_TLS_CA
