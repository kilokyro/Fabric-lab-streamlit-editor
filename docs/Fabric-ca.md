# Hyperledger Fabric Deployment

## 檔案/ 目錄架構

```bash
baasid@nchc-lab:~/lab$ tree
.
├── biobank
│   ├── orderers
│   │   ├── orderer0
│   │   │   └── docker-compose.yaml
│   │   ├── orderer1
│   │   │   └── docker-compose.yaml
│   │   └── orderer2
│   │       └── docker-compose.yaml
│   └── peers
│       ├── peer0
│       │   ├── docker-compose.yaml
│       │   └── peer0-core.yaml
│       └── peer1
│           ├── docker-compose.yaml
│           └── peer1-core.yaml
├── ca
│   ├── config
│   │   ├── baasid.com.tw
│   │   │   ├── ca
│   │   │   │   └── fabric-ca-server-config.yaml
│   │   │   └── tls
│   │   │       └── fabric-ca-server-config.yaml
│   │   ├── biobank.org.tw
│   │   │   ├── ca
│   │   │   │   └── fabric-ca-server-config.yaml
│   │   │   └── tls
│   │   │       └── fabric-ca-server-config.yaml
│   │   ├── fabric-ca-server-config.yaml
│   │   ├── nchc.org.tw
│   │   │   ├── ca
│   │   │   │   └── fabric-ca-server-config.yaml
│   │   │   └── tls
│   │   │       └── fabric-ca-server-config.yaml
│   │   └── orderer.com
│   │       ├── ca
│   │       │   └── fabric-ca-server-config.yaml
│   │       └── tls
│   │           └── fabric-ca-server-config.yaml
│   └── docker-compose.yaml
├── docs
│   └── Fabric-ca.md
├── fabric-material.sh
├── nchc
│   ├── orderers
│   │   ├── orderer0
│   │   │   └── docker-compose.yaml
│   │   └── orderer1
│   │       └── docker-compose.yaml
│   └── peers
│       ├── peer0
│       │   ├── docker-compose.yaml
│       │   └── peer0-core.yaml
│       └── peer1
│           ├── docker-compose.yaml
│           └── peer1-core.yaml
└── workdir
    ├── biobank-client
    │   └── peer.env
    ├── ca
    │   ├── cp-tls-cert.sh
    │   ├── crypto.sh
    │   ├── enroll.sh
    │   ├── nchc.json
    │   ├── network.json
    │   ├── peers.json
    │   └── tls
    │       ├── baasid.com.tw
    │       │   ├── ca
    │       │   └── tls
    │       ├── biobank.org.tw
    │       │   ├── ca
    │       │   └── tls
    │       ├── nchc.org.tw
    │       │   ├── ca
    │       │   └── tls
    │       └── orderer.com
    │           ├── ca
    │           └── tls
    ├── channel-artifacts
    ├── config
    │   ├── configtx-orig.yaml
    │   └── configtx.yaml
    ├── nchc-client
    │   └── peer.env
    ├── orderer-client
    └── system-genesis-block
```