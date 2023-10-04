#!/usr/bin/env bash

addpeers() {
    for index in "${!peers[@]}";
    do
        peer="${peers[$index]}"
        peeradd=$(echo $tmpl|jq  ".Organizations[1].peerOrganizations[$index] |= . + $(cat ${peer})")
        tmpl=$(jq '.' <<< $(echo $peeradd))
    done
}

addorderers() {
    for index in "${!orderers[@]}";
    do
        echo "${orderers[$index]}"
        orderer="${orderers[$index]}"
        ordereradd=$(echo $tmpl|jq  ".Organizations[0].ordererOrganizations[$index] |= . + $(cat ${orderer})")
        tmpl=$(jq "." <<< $(echo $ordereradd))
    done
}
while getopts ":t: :p::o::O::-d:" opt; do
    case $opt in

    p)
     peers+=("$OPTARG")  
    ;;

    t)
    TMPL=$OPTARG
    tmpl=$(cat $TMPL)
    ;;
    o)
    orderers+=("$OPTARG")
    ;;
    O)
    output=$OPTARG
    ;;
    esac
done
addorderers
addpeers
echo $tmpl|jq > $output