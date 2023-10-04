# Fabric CA 工作目錄

為簡化 Fabric CA Client issue 憑證的繁雜工作

## 創建 MSP 
1. 由 msp-template copy 到另一 新的目錄 msp
```bash
cp -a msp-template msp
```
檢視內容
1. organization.json
    1. Organizations 陣列有二個元件，ordererOrganizations 以及 peerOrganizations，分別為 orderer 及 peer 二種不同機構類型
```json
{
  "Organizations": [
    {
      "ordererOrganizations": []
    },
    {
      "peerOrganizations": []
    }
  ]
}
```
2. orderer.json
    1. 定義要發行 ordererMSP 的憑證應有的 資訊，包含
        1. caServer 的連線資訊
        2. tlsServer 的連線資訊
        3. orderers 可自行 0-N 個 orderer
        4. users 可定義 0-N 個 client

```json
{
    "ordererMSP": {
      "domain": "org4.com",
      "csrname": "C=TW,ST=Taiwan,O=org4.com,OU=Fabric",
      "caServer": {
        "identity": "admin",
        "secret": "adminpw",
        "host": "ca.org4.com",
        "port": 4054,
        "tlscert": "Organizations/ordererOrganizations/org4.com/ca/tls-cert.pem"
      },
      "tlsServer": {
        "identity": "admin",
        "secret": "adminpw",
        "host": "tls.org4.com",
        "port": 4154,
        "tlscert": "Organizations/ordererOrganizations/org4.com/tls/tls-cert.pem"
      },
      "orderers": [
        {
          "orderer0": {
            "identity": "orderer0.org4.com",
            "secret": "ZjE0ZDU3ZDU0YTdhMDdhZWQ0OTRjMzYzMWE3OTViMjcK",
            "type": "orderer",
            "attrs": "",
            "sans": "orderer0.org4.com"
          },
          "orderer1": {
            "identity": "orderer1.org4.com",
            "secret": "ZjE0ZDU3ZDU0YTdhMDdhZWQ0OTRjMzYzMWE3OTViMjcK",
            "type": "orderer",
            "attrs": "",
            "sans": "orderer1.org4.com"
          },
          "orderer2": {
            "identity": "orderer2.org4.com",
            "secret": "ZjE0ZDU3ZDU0YTdhMDdhZWQ0OTRjMzYzMWE3OTViMjcK",
            "type": "orderer",
            "attrs": "",
            "sans": "orderer2.org4.com"
          }
        }
      ],
      "users": [
        {
          "Admin": {
            "identity": "Admin@org4.com",
            "secret": "ODg1YmIyOGE0MzIzNTdiNzc4NzEK",
            "affiliation": "",
            "attrs": "",
            "sans": "",
            "type": "admin"
          }
        }
      ]
    }
  }
```

3. peer.json

```json
{
    "org1MSP": {
      "domain": "org1.com",
      "csrname": "C=TW,ST=Taiwan,O=org1.com,OU=Fabric",
      "caServer": {
        "identity": "admin",
        "secret": "adminpw",
        "host": "ca.org1.com",
        "port": 2054,
        "tlscert": "Organizations/peerOrganizations/org1.com/ca/tls-cert.pem"
      },
      "tlsServer": {
        "identity": "admin",
        "secret": "adminpw",
        "host": "tls.org1.com",
        "port": 2154,
        "tlscert": "Organizations/peerOrganizations/org1.com/tls/tls-cert.pem"
      },
      "peers": [
        {
          "peer0": {
            "identity": "peer0.org1.com",
            "secret": "ZjE0ZDU3ZDU0YTdhMDdhZWQ0OTRjMzYzMWE3OTViMjcK",
            "type": "peer",
            "attrs": "",
            "sans": "peer0.org1.com"
          },
          "peer1": {
            "identity": "peer1.org1.com",
            "secret": "ZjE0ZDU3ZDU0YTdhMDdhZWQ0OTRjMzYzMWE3OTViMjcK",
            "type": "peer",
            "attrs": "",
            "sans": "peer1.org1.com"
          }
        }
      ],
      "users": [
        {
          "Admin": {
            "identity": "Admin@org1.com",
            "secret": "ODg1YmIyOGE0MzIzNTdiNzc4NzEK",
            "affiliation": "",
            "attrs": "",
            "sans": "",
            "type": "admin"
          }
        },
        {
          "user1": {
            "identity": "user1@org1.com",
            "secret": "YzMzMGVkMmY1Y2M4NTE0NDk1NDYK",
            "affiliation": "",
            "attrs": "role=manager:ecert",
            "sans": "",
            "type": "client"
          }
        }
      ]
    }
  }
```

## 產出 整合檔案 network.json
```bash
cd msp
../scripts/networkgen.sh -t organizations.json -o orderer.json -p peerorg1.json -p peerorg2.json -p peerorg3.json -O ../network.json
```
## enrollment admin

```bash
cd ..
./scripts/enroll.sh network.json
```
會產出 $PWD/Organizations 目錄下包含各 organizations (org1, org2, org3, org4) 的 ca/tls admin 的 Homedir 以及所有憑證資訊

### register & enroll 所有定義在 network.json 中的所有個體 (entities) 的身份識別文件 

```bash
./scripts/crypto.sh network.json
```
會產出 Organizations, localMSP, channelMSP