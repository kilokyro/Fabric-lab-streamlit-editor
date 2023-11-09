#!/usr/bin/env bash
# 生成 系統頻道 (system Channel) 的設定區塊 (創世塊/genesis.block)
configtxgen -profile OrdererGenesis -configPath . -channelID system-channel -outputBlock ../system-genesis-block/genesis.block

# 將創世區塊 genesis.block 檔案格式由 protobuf 轉換成 json
configtxgen -inspectBlock ../system-genesis-block/genesis.block > ../system-genesis-block/genesis.json

# 產生應用頻道 (Application Channel) 的設定區塊 ()
configtxgen -profile Channel12 -configPath . -channelID channel1 -outputCreateChannelTx ../channel-artifacts/channel1.tx
# 將應用頻道 的設定區塊 檔案格式由 protobuf 轉換成 json
configtxgen -inspectChannelCreateTx ../channel-artifacts/channel1.tx > ../channel-artifacts/channel1.json

# configtxgen -profile Channel23 -configPath . -channelID channel2 -outputCreateChannelTx ../channel-artifacts/channel2.tx
# 將應用頻道 的設定區塊 檔案格式由 protobuf 轉換成 json
# configtxgen -inspectChannelCreateTx ../channel-artifacts/channel2.tx > ../channel-artifacts/channel2.json

# configtxgen -profile AllChannel -configPath . -channelID channel3 -outputCreateChannelTx ../channel-artifacts/channel3.tx
# 將應用頻道 的設定區塊 檔案格式由 protobuf 轉換成 json
# configtxgen -inspectChannelCreateTx ../channel-artifacts/channel3.tx > ../channel-artifacts/channel3.json
