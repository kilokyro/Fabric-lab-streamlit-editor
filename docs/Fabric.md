# Hyperledger Fabric Lab from scratch
## Hardware:
- CPU: x86_64 4Core
- Mem: 4GB
- Storage: 32GB

## OS and packages is required:
- OS: Ubuntu 22.04 LTS
- packages:
  - docker-ce
  - docker-compose
  - jq
  - tree
  - sqlite3
  - hyperledger-fabric-linux
  - hyperledger-fabric-ca-linux

## Docker images:
- hyperledger/fabric-baseos:2.2.11
- hyperledger/fabric-ccenv:2.2.11
- hyperledger/fabric-tools:2.2.11
- hyperledger/fabric-peer:2.2.11
- hyperledger/fabric-orderer:2.2.11
- hyperledger/fabric-ca:1.5.6
- couchdb:3.2.2
- busybox:latest

![Hyperledger Fabric](../../fabric-lab/resources/images/fabric-bigpic.png)

來源: [Blockchain network]: https://hyperledger-fabric.readthedocs.io/en/release-2.2/network/network.html#blockchain-network

> 1. Organizations: R1,R2,R3,R4 分別代表 Organization1 ~ Organization4
> 2. Fabric-ca-server: CA1~CA4 分別代表 Organization1 ~ Organization4 的 Fabric CA Server
> 3. Channel: C1, C2 代表 C 1 & channel 2
> 4. Network: NC4 代表 network 4 configure
> 5. Channel Configure : CC1 & CC2 代表 channel 1 & channel 2 的 configure
> 6. Orderer Organization: O4 代表 ordererOrganizations
> 7. PeerOrganizations: P1~P3 分別代表 peer1Organizations~ peer3Organization
> 8. Smartcontract(Chanicode): S5, S6
> 9. Ledger: L1, L2

## Fetch & install packages
執行下列指令，
```bash
${PWD}/fabric-material.sh
```

## Fabric-ca

### 架構
1. orderer.com
   - ca.orderer.nchc.org.tw
     - port: 1054
     - user: caadmin
     - password: 2e2ecf9fd5434f5dd47f0a887799ac46
   - tls.orderer.nchc.org.tw
     - port: 1154
     - user: tlsadmin
     - password: e6764b589fc34d7c8f7ca99de4ecdf17

  
2. nchc.org.tw
   - ca.nchc.org.tw
     - port: 2054
     - user: caadmin
     - password: 32b0a5d985ff6eec0065993961631832
   - tls.nchc.org.tw
     - port: 2154
     - user: tlsadmin
     - password: 5fe31ca3b113fe68ca6466ae48d50d7d

3. biobank.org.tw
   - ca.biobank.org.tw
     - port: 3054
     - user: caadmin
     - password: 198b39f4f823b8c0d036b40c5ea171c4
   - tls.biobank.org.tw
     - port: 3154
     - user: tlsadmin
     - password: 9a5bb428d5cccb4c1f7078fb72316012

4. baasid.com.tw
   - ca.baasid.com.tw
     - port: 4054
     - user: caadmin
     - password: 3d2b6285b27cf2f702a700cfd6f3693e
   - tls.baasid.com.tw
     - port: 4154
     - user: tlsadmin
     - password: 6b1f1d66842e5c475c7d16b487fdfbd7
