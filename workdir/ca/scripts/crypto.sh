#!/usr/bin/env bash
declare -A array
FILE=$1

FABRIC_CA_CLIENT=$(which fabric-ca-client)
f=$(cat $FILE)
ROOTPATH=$PWD
key0=$(jq -r '.[]|keys[]' <<< $(echo $f))
level0=$(jq -r '.|keys[]' <<< $(echo $f))
json=$(jq ".$level0" <<< $(echo $f))
ROOTPATH=$ROOTPATH/$level0
for i in $key0
do
    orgs=$(jq .[$i] <<< $(echo $json))
    key=$(jq -r ".[]|keys[]" <<< $(echo $orgs))
    level=$(jq -r ".|keys[]" <<< $(echo $orgs))
    CURDIR=$ROOTPATH/$level
    for i in $key
    do 
        msp=$(jq .$level[$i] <<< $(echo $orgs))
        level1=$(jq -r ".|keys[]" <<< $(echo $msp))   
        for i in $level1
        do 
            domain=$(jq -r ".$level1.domain" <<< $(echo $msp))
            csrname=$(jq -r ".$level1.csrname" <<< $(echo $msp))
            CDIR=$CURDIR/$domain
	   		array[caServer.client]=$CDIR/ca
	    	array[tlsServer.client]=$CDIR/tls
            element=$(jq -r ".$level1|keys[]" <<< $(echo $msp))	    
            a=$(jq .$level1 <<< $(echo $msp))
            for i in $element
            do
                if [[ "$i" == "caServer" || "$i" == "tlsServer" ]]; then
                    b=$(jq -r ".$i|keys[]" <<< $(echo $a))
                    bvalue=$(jq -r ".$i" <<< $(echo $a))
                    for m in $b
                    do
						array["$i.$m"]=$(jq -r ".$m" <<< $(echo $bvalue))
                    done
                fi
			done
	   done
	   for i in $element
		do
			if [[ "$i" == "orderers" || "$i" == "peers" || "$i" == "users" ]]; then
				MDIR=$CDIR/$i
				ROLES=$i
				c=$(jq -r ".$i[]|keys[]" <<< $(echo $a))
				c1=$(jq -r ".$i|keys[]" <<< $(echo $a))
				cvalue=$(jq -r ".$i" <<< $(echo $a))
				for h in $c1
				do
					d=$(jq -r ".[$h]|keys[]" <<< $(echo $cvalue))
					dvalue=$(jq -r ".[$h]" <<< $(echo $cvalue))
					for z in $d
					do
						OPT=''
						z1=$(jq -r ".$z|keys[]" <<< $(echo $dvalue))
						zvalue=$(jq -r ".$z" <<< $(echo $dvalue))
						for y in $z1
						do
							array[$d.$y]=$(jq -r ".$y" <<< $(echo $zvalue))
							array[$d.$y]=$(echo ${array[$d.$y]} |sed 's/\[//g'|sed 's/\]//g'|sed 's/^ +//g'|sed 's/ +$//g')
							if test ! -z "${array[$d.$y]}" ;  then
								if [ "$y" == "attrs" ]; then
									attrs=''
									Y=$(jq -r ".attrs" <<< $(echo $zvalue))
									for k in $Y
									do
										if [[ $k == *"hf.Registrar"* ]]; then
											k=$(echo \"$k\")
										fi
										attrs=$attrs$k,
									done
									array[$d.$y]=$(sed 's/,$//g' <<< $(echo $attrs))
								fi
								if [ "$y" != "sans" ]; then
									OPT="$OPT --id.$y ${array[$d.$y]}";
								fi
							fi
						done
						OPT=$(echo $OPT| sed 's/id.identity/id.name/g')
						array[$d.mdir]=$MDIR/${array[$d.identity]}
						caServer=${array[caServer.host]}
						identity=${array[caServer.identity]}
						secret=${array[caServer.secret]}
						port=${array[caServer.port]}
						tlscert=$PWD/${array[caServer.tlscert]}
						FABRIC_CA_CLIENT_HOME=${array[caServer.client]}
						if test ! -z "${array[$d.affiliation]}"; then
							affiliation_check=$($FABRIC_CA_CLIENT affiliation list --affiliation ${array[$d.affiliation]} -u https://$caServer:$port --tls.certfiles $tlscert -H $FABRIC_CA_CLIENT_HOME|awk -F ':' '{print $2}'|sed 's/ +//g')
							echo $affiliation_check "${array[$d.affiliation]}"
							if test -z "$affiliation_check"; then
								$FABRIC_CA_CLIENT affiliation add ${array[$d.affiliation]} --force -u https://$caServer:$port --tls.certfiles $tlscert -H $FABRIC_CA_CLIENT_HOME
							fi
						fi
						identity_check=$($FABRIC_CA_CLIENT identity list --id ${array[$d.identity]} -u https://$caServer:$port --tls.certfiles $tlscert -H $FABRIC_CA_CLIENT_HOME| awk -F ',' '{print $1}'|awk -F ': ' '{print $2}')		
						if test  -z "$identity_check"; then
							$FABRIC_CA_CLIENT register -u https://$caServer:$port --tls.certfiles $tlscert $OPT -H $FABRIC_CA_CLIENT_HOME
						fi
						$FABRIC_CA_CLIENT enroll -u https://${array[$d.identity]}:${array[$d.secret]}@$caServer:$port --tls.certfiles $tlscert --csr.names $csrname -M ${array[$d.mdir]}/msp -H $FABRIC_CA_CLIENT_HOME
						LOCALMSP=$(sed 's/\/Organizations/\/localMSP/g' <<< $(echo ${array[$d.mdir]}/msp))
						mkdir -p $LOCALMSP/{admincerts,cacerts,keystore,signcerts,tlscacerts}
						cp ${array[$d.mdir]}/msp/cacerts/* $LOCALMSP/cacerts/ca.pem
						cp ${array[$d.mdir]}/msp/signcerts/cert.pem $LOCALMSP/signcerts/${array[$d.identity]}-cert.pem
						cert_md5=$(openssl x509 -in ${array[$d.mdir]}/msp/signcerts/cert.pem -pubkey -noout|openssl md5)
						for priv in "${array[$d.mdir]}/msp/keystore/*"
						do
							for i in $priv
							do
								i_md5=$(openssl pkey -in $i -pubout|openssl md5)
								if [ "$i_md5" == "$cert_md5" ] ; then
									cp $i $LOCALMSP/keystore/priv_sk
								fi
							done
						done
						mkdir -p $LOCALMSP/../../../msp/{admincerts,cacerts,tlscacerts}
						cp $LOCALMSP/cacerts/ca.pem $LOCALMSP/../../../msp/cacerts/ca.pem
						FABRIC_CA_CLIENT_HOME=${array[tlsServer.client]}

cat << EOF > $LOCALMSP/../../../msp/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF

cat << EOF > $LOCALMSP/config.yaml
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF

						tlsServer=${array[tlsServer.host]}
						identity=${array[tlsServer.identity]}
						secret=${array[tlsServer.secret]}
						tlsport=${array[tlsServer.port]}
						tlscert=$PWD/${array[tlsServer.tlscert]}
						TLS_ARG=''
						if test ! -z "${array[$d.sans]}" ; then
							TLS_ARG=$(echo $TLS_ARG --csr.hosts ${array[$d.sans]})
						fi
						identity_check=$($FABRIC_CA_CLIENT identity list --id ${array[$d.identity]} -u https://$tlsServer:$tlsport --tls.certfiles $tlscert -H $FABRIC_CA_CLIENT_HOME| awk -F ',' '{print $1}'|awk -F ': ' '{print $2}')		
						if test  -z "$identity_check"; then
							$FABRIC_CA_CLIENT register -u https://$tlsServer:$tlsport --tls.certfiles $tlscert -H $FABRIC_CA_CLIENT_HOME --id.name ${array[$d.identity]} --id.secret ${array[$d.secret]}
						fi
						$FABRIC_CA_CLIENT enroll -u https://${array[$d.identity]}:${array[$d.secret]}@$tlsServer:$tlsport --tls.certfiles $tlscert --csr.names $csrname -H $FABRIC_CA_CLIENT_HOME -M ${array[$d.mdir]}/tls --enrollment.profile tls $TLS_ARG
						LOCALMSP=$(sed 's/\/Organizations/\/localMSP/g' <<< $(echo ${array[$d.mdir]}/tls))
						mkdir -p $LOCALMSP
						cp ${array[$d.mdir]}/tls/tlscacerts/* $LOCALMSP/ca.crt
						cp $LOCALMSP/ca.crt $LOCALMSP/../../../msp/tlscacerts/tlsca.$domain-cert.pem
						cp ${array[$d.mdir]}/tls/signcerts/cert.pem $LOCALMSP/server.crt
						cp $LOCALMSP/ca.crt $LOCALMSP/../msp/tlscacerts/tlsca.$domain-cert.pem
						cert_md5=$(openssl x509 -in ${array[$d.mdir]}/tls/signcerts/cert.pem -pubkey -noout|openssl md5)
						for priv in "${array[$d.mdir]}/tls/keystore/*"
						do
							for i in $priv
							do
								i_md5=$(openssl pkey -in $i -pubout|openssl md5)
								if [ "$i_md5" == "$cert_md5" ] ; then
									cp $i $LOCALMSP/server.key
								fi
							done
						done
						if [[ "$ROLES" != "peers" && "$ROLES" != "orderers" ]]; then
							mv $LOCALMSP/server.crt $LOCALMSP/client.crt
							mv $LOCALMSP/server.key $LOCALMSP/client.key
						fi
					done
				done
			fi
        done
    done
done
echo $ROOTPATH
if [ ! -d "$ROOTPATH/../channelMSP" ]; then
	mkdir $ROOTPATH/../channelMSP
fi
cp -a $ROOTPATH/../localMSP/* $ROOTPATH/../channelMSP
ls -d  $ROOTPATH/../channelMSP/*/*/*|egrep -v 'msp|orderers'|xargs rm -rf
rm -rf  $ROOTPATH/../channelMSP/ordererOrganizations/*/orderers/*/msp
rm -rf  $ROOTPATH/../channelMSP/ordererOrganizations/*/orderers/*/tls/{ca.crt,server.key}


