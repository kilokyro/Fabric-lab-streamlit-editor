#!/usr/bin/env bash
tls=$(cat $3|base64 -w0)
CHANNEL_NAME=$1
HOST=$2

declare -a consenters
peer channel fetch config config_block.pb -c $CHANNEL_NAME -o orderer1.org4.com:4150 --tls --cafile $ORDERER_TLS_CA
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
cat config_block.json|jq '.data.data[].payload.data.config' > config.json
F=$(cat config.json)
consenters=$(echo $F|jq .channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters)
updated=$(echo "$consenters" | jq --arg newVal "$tls" 'map(if .host == "'$HOST'" then .client_tls_cert = $newVal | .server_tls_cert = $newVal else . end)')

modified=$(echo $F | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters = $new_consenters' --argjson new_consenters "$updated")
echo $modified |jq . > config_modified.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input config_modified.json --type common.Config --output config_modified.pb

configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated config_modified.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

