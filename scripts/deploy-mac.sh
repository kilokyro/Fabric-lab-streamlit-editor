#!/bin/bash

arm64 () {
	echo 'I am Apple M1 chip'
	softwareupdate --install-rosetta
	export DOCKER_DEFAULT_PLATFORM=linux/amd64
	echo "export DOCKER_DEFAULT_PLATFORM=linux/amd64" >> $HOME/.bash_profile
	export BREW_ROOT=/opt/homebrew
	ln -sf /Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion $BREW_ROOT/etc/bash_completion.d/docker-compose
	ln -sf /Applications/Docker.app/Contents/Resources/etc/docker.bash-completion $BREW_ROOT/etc/bash_completion.d/docker
}

amd64(){
	echo 'I am x86_64'
	export BREW_ROOT=/usr/local/Homebrew
	ln -sf /Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion $BREW_ROOT/completions/docker-compose
	ln -sf /Applications/Docker.app/Contents/Resources/etc/docker.bash-completion $BREW_ROOT/completions/docker
}

setpath () {
	export GOROOT=/usr/local/go
	export GOPATH=$HOME/go
	mkdir -p $GOPATH
	echo "export GOROOT=/usr/local/go" >> $HOME/.bash_profile
	echo "export GOPATH=$HOME/go" >> $HOME/.bash_profile
	echo "PATH=$BREW_ROOT/bin:$PATH" >> $HOME/.bash_profile
	echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> $HOME/.bash_profile
	export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
	export FABRIC_CFG_PATH=$GOPATH/config
	echo "export FABRIC_CFG_PATH=$GOPATH/config" >> $HOME/.bash_profile
}
downloadBin (){
	wget https://go.dev/dl/go1.20.5.darwin-amd64.tar.gz -O /tmp/go1.20.5.darwin-amd64.tar.gz
	sudo tar zxvf /tmp/go1.20.5.darwin-amd64.tar.gz -C /usr/local
	rm -rf /tmp/go1.20.5.darwin-amd64.tar.gz
	wget https://github.com/hyperledger/fabric/releases/download/v2.2.12/hyperledger-fabric-darwin-amd64-2.2.12.tar.gz -O /tmp/hyperledger-fabric-darwin-amd64-2.2.12.tar.gz
	tar zxvf /tmp/hyperledger-fabric-darwin-amd64-2.2.12.tar.gz -C $GOPATH
	rm -rf /tmp/hyperledger-fabric-darwin-amd64-2.2.12.tar.gz
	wget https://github.com/hyperledger/fabric-ca/releases/download/v1.5.6/hyperledger-fabric-ca-darwin-amd64-1.5.6.tar.gz -O /tmp/hyperledger-fabric-ca-darwin-amd64-1.5.6.tar.gz
	tar zxvf /tmp/hyperledger-fabric-ca-darwin-amd64-1.5.6.tar.gz -C $GOPATH
}

downloadImages () {
	docker pull hyperledger/fabric-baseos:2.2.12
	docker pull hyperledger/fabric-ccenv:2.2.12
	docker pull hyperledger/fabric-tools:2.2.12
	docker pull hyperledger/fabric-peer:2.2.12
	docker pull hyperledger/fabric-orderer:2.2.12
	docker pull hyperledger/fabric-ca:1.5.6
	docker pull couchdb:3.1.1
	docker image tag hyperledger/fabric-baseos:2.2.12 hyperledger/fabric-baseos:latest
	docker image tag hyperledger/fabric-ccenv:2.2.12 hyperledger/fabric-ccenv:latest
	docker image tag hyperledger/fabric-tools:2.2.12 hyperledger/fabric-tools:latest
	docker image tag hyperledger/fabric-peer:2.2.12 hyperledger/fabric-peer:latest
	docker image tag hyperledger/fabric-orderer:2.2.12 hyperledger/fabric-orderer:latest
	docker image tag hyperledger/fabric-ca:1.5.6 hyperledger/fabric-ca:latest
	cp -a $HOME/go/{config,bin} $PWD/fabric-samples
}
ARCH=$(arch)
if [ "$ARCH" != "i386" ]; then
	arm64
else
	amd64
fi



brew install bash
brew install jq
brew install wget 
brew install curl 
brew install git 
brew install visual-studio-code 
brew install drawio

setpath
downloadBin
downloadImages
