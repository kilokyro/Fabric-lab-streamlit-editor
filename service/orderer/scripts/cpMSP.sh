#!/usr/bin/env bash

# 設定來源和目標目錄
SRC_DIR="../../workdir/ca/localMSP/ordererOrganizations"
DST_DIR="$PWD"

# 從來源目錄獲取組織名稱
ORG_NAMES=$(ls $SRC_DIR)

# 遍歷每一個組織和節點
for org in $ORG_NAMES; do
    PEER_NAMES=$(ls $SRC_DIR/$org/orderers)
    for orderer in $PEER_NAMES; do
        # 確保目的地目錄存在
        mkdir -p $DST_DIR/$org/$orderer/$orderer

        # 複製資料
        cp -R $SRC_DIR/$org/orderers/$orderer/* $DST_DIR/$org/$orderer/$orderer
    done
done

# copy genesis block 
cp $PWD/../../workdir/system-genesis-block/genesis.block .
