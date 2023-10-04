#!/usr/bin/env bash

user=$USER
sudo sh -c "echo \"$user\tALL=(ALL)\tNOPASSWD:ALL\" > /etc/sudoers.d/mastertalk"
unset user
sudo sh -c "cat << EOF >> /etc/hosts 

# Mastertalk 
## Fabric CA Server
127.0.0.1	ca.org1.com
127.0.0.1	tls.org1.com
127.0.0.1	ca.org2.com
127.0.0.1	tls.org2.com
127.0.0.1	ca.org3.com
127.0.0.1	tls.org3.com
127.0.0.1	ca.org4.com
127.0.0.1	tls.org4.com

## Nodes
127.0.0.1	peer0.org1.com
127.0.0.1	peer1.org1.com
127.0.0.1	peer0.org2.com
127.0.0.1	peer1.org2.com
127.0.0.1	peer0.org3.com
127.0.0.1	peer1.org3.com
127.0.0.1	orderer0.org4.com
127.0.0.1	orderer1.org4.com
127.0.0.1	orderer2.org4.com
127.0.0.1	orderer3.org4.com
127.0.0.1	orderer4.org4.com

EOF"

ARCH=$(uname -m)
OS=$(uname -o)
RELEASE=$(uname -r|grep -i 'microsoft')

case $OS in
	GNU/Linux)
		DIST=$(grep 'ID=' /etc/os-release |awk -F '=' '{print $2}')
		if [ "$DIST" != "ubuntu" ]; then
			echo "系統僅支援ubuntu 作業系統 "
		fi
		if [ "$RELEASE" != "" ]; then
		  ./scripts/deploy-ms.sh
		else 
		  ./scripts/deploy-ubuntu.sh
		fi
	;;
	Darwin)
		./scripts/deploy-mac.sh
	;;
esac
