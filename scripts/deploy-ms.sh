#!/bin/bash

sudo apt update
sudo apt dist-upgrade -y
sudo apt install wget curl git jq tree sqlite3 -y

wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz -O go1.20.4.linux-amd64.tar.gz -O /tmp/go1.20.4.linux-amd64.tar.gz
sudo tar zxvf /tmp/go1.20.4.linux-amd64.tar.gz -C /usr/local
rm -rf /tmp/go1.20.4.linux-amd64.tar.gz
mkdir ${HOME}/go

wget https://github.com/hyperledger/fabric/releases/download/v2.2.12/hyperledger-fabric-linux-amd64-2.2.12.tar.gz -O /tmp/hyperledger-fabric-linux-amd64-2.2.12.tar.gz
tar zxvf /tmp/hyperledger-fabric-linux-amd64-2.2.12.tar.gz -C $HOME/go
rm /tmp/hyperledger-fabric-linux-amd64-2.2.12.tar.gz

wget https://github.com/hyperledger/fabric-ca/releases/download/v1.5.6/hyperledger-fabric-ca-linux-amd64-1.5.6.tar.gz -O /tmp/hyperledger-fabric-ca-linux-amd64-1.5.6.tar.gz
tar zxvf /tmp/hyperledger-fabric-ca-linux-amd64-1.5.6.tar.gz -C $HOME/go
rm /tmp/hyperledger-fabric-ca-linux-amd64-1.5.6.tar.gz

sudo docker pull hyperledger/fabric-baseos:2.2.12
sudo docker tag hyperledger/fabric-baseos:2.2.12 hyperledger/fabric-baseos:latest
sudo docker pull hyperledger/fabric-ccenv:2.2.12
sudo docker tag hyperledger/fabric-ccenv:2.2.12 hyperledger/fabric-ccenv:latest
sudo docker pull hyperledger/fabric-tools:2.2.12
sudo docker tag hyperledger/fabric-tools:2.2.12 hyperledger/fabric-tools:latest
sudo docker pull hyperledger/fabric-peer:2.2.12
sudo docker tag hyperledger/fabric-peer:2.2.12 hyperledger/fabric-peer:latest
sudo docker pull hyperledger/fabric-orderer:2.2.12
sudo docker tag hyperledger/fabric-orderer:2.2.12 hyperledger/fabric-orderer:latest
sudo docker pull hyperledger/fabric-ca:1.5.6
sudo docker tag hyperledger/fabric-ca:1.5.6 hyperledger/fabric-ca:latest
sudo docker pull couchdb:3.1.1
sudo docker tag couchdb:3.1.1 couchdb:latest

sudo cp $HOME/go/bin/* /usr/local/bin

cat <<EOF>>$HOME/.bashrc
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$HOME/go/bin:$PATH
export FABRIC_CFG_PATH=$HOME/go/config
EOF
source $HOME/.bashrc

cp -a $HOME/go/{bin,config} $PWD/fabric-samples/
