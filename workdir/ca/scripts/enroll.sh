
#!/usr/bin/env bash
declare -A array
copy-tls(){
    for dir in $(find $PWD/../../ca/config/ -maxdepth 2 -mindepth 2)
do
        DEST=$(echo $dir|sed 's/\.\.\/\.\.\/ca\/config/tls/g')
        if [ ! -d "$DEST" ]; then
                mkdir -p $DEST
        fi
        cp $dir/tls-cert.pem $DEST
done
}
copy-tls
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
            CAMSP=$CURDIR/$domain/ca
            TLSMSP=$CURDIR/$domain/tls
            if [ ! -d "$CAMSP" ]; then
                
                mkdir -p $CAMSP
            fi
            if [ ! -d "$TLSMSP" ]; then
                mkdir -p $TLSMSP
            fi
                cp $PWD/tls/$domain/ca/tls-cert.pem $CAMSP
                cp $PWD/tls/$domain/tls/tls-cert.pem $TLSMSP
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
	        FABRIC_CA_CLIENT_HOME=$CAMSP
            $FABRIC_CA_CLIENT enroll -u https://${array[caServer.identity]}:${array[caServer.secret]}@${array[caServer.host]}:${array[caServer.port]} --tls.certfiles $CAMSP/tls-cert.pem -H $FABRIC_CA_CLIENT_HOME --csr.names $csrname
	        FABRIC_CA_CLIENT_HOME=$TLSMSP
            $FABRIC_CA_CLIENT enroll -u https://${array[tlsServer.identity]}:${array[tlsServer.secret]}@${array[tlsServer.host]}:${array[tlsServer.port]} --tls.certfiles $TLSMSP/tls-cert.pem  -H $FABRIC_CA_CLIENT_HOME --csr.names $csrname
        done
    done
done
