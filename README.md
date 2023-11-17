> # **Hyperledger Fabric 實作**
>
> 原始環境概況
>
> 1. 一個 orderer Organization (OrdererMSP/ org4.com), 包含三個 orderer nodes (orderer0.org4.com, orderer1.org4.com, orderer2.org4.com)
> 2. 二個 peer Organizations, (Org1MSP/ org1.com, Org2MSP/ org2.com), 2 peer nodes/org
> 3. 一個  orderer channel (system-channel)
> 4. 一個  application channel (channel1)
> 5. 部署  chaincode (hyperledger fabric samples 範例 asset-transfer-basic)
> 6. 二個 peer Organizations 的 peer0 加入 channel1, 部署 asset-transfer-basic chaincode

## 重頭開始

***先期準備環境***

### 1. 下載 fabric-lab 材料

***`[command]`***

```bash
   mkdir $HOME/workspaces
   cd $HOME/workspaces
   git clone -b add-neworg --recursive https://gitlab.com/cshuangtw/fabric-lab.git
```

### 2. 執行 env-deploy.sh

> 工作目標:
>
> 1. 更新系統套件
> 2. 下載梘關工具 (git, curl, wget, tree, jq 等)
> 3. 下載及部署 golang 程式語言編譯執行檔
> 4. 下載 fabric-ca server/client 套件
> 5. 下載 fabric 指令工具
> 6. 安裝 docker, docker-compose
> 7. 下載 fabric 官方 docker image
> 8. 配置 fabric-samples 工作環境

> 工作目錄: $HOME/workspaces/fabric-lab
>
> ***`[command]`***
>
> ```bash
> ./env-deploy.sh
> ```

### 3. 斷開與 vscode 的連線

   ***`[command]`***

```bash
   ps -ef |grep vscode|grep code|awk '{print $2}'|xargs kill -9
```

### 4. 重新載入 vsocde

> #### 4-1 由 vscode 圖形介面開啟資料夾
>
>> **工作目錄: $HOME/workspaces/fabric-lab**
>

> #### 4-2 測試 docker 指令是否可以正常運作
>
> ***`[command]`***
>
> ```bash
> docker ps
> ```
>
> `System Response:`
>
> ```docker
> CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS                                                                                        NAMES
> ```

### 5. 測試下載套件及材料的可用性及完整性

> **工作目錄: $HOME/workspaces/fabric-lab/fabric-samples/test-network**
>
> #### 5-1 啟動 test network
>
> ***`[command]`***
>
> ```bash
> cd $HOME/workspaces/fabric-lab/fabric-samples/test-network
> ./network.sh up createChannel -c channel1 -s couchdb -ca
> ```
>
> 最終啟動成功的結果:
> ***`[command]`***
>
> ```docker
> docker ps
> ```
>
> `System Response`
>
> ```bash
> CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS                                                                                                NAMES
> 9e2b138448a1   hyperledger/fabric-tools:latest     "/bin/bash"              32 minutes ago   Up 32 minutes                                                                                                        cli
> 39a0bc11b2db   hyperledger/fabric-peer:latest      "peer node start"        32 minutes ago   Up 32 minutes   0.0.0.0:9051->9051/tcp, :::9051->9051/tcp, 7051/tcp, 0.0.0.0:9445->9445/tcp, :::9445->9445/tcp       peer0.org2.example.com
> 45711638afa7   hyperledger/fabric-peer:latest      "peer node start"        32 minutes ago   Up 32 minutes   0.0.0.0:7051->7051/tcp, :::7051->7051/tcp, 0.0.0.0:9444->9444/tcp, :::9444->9444/tcp                 peer0.org1.example.com
> 66cfe33d8f67   couchdb:3.1.1                       "tini -- /docker-ent…"   32 minutes ago   Up 32 minutes   4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp, :::7984->5984/tcp                                        couchdb1
> 6a1efb206b5f   couchdb:3.1.1                       "tini -- /docker-ent…"   32 minutes ago   Up 32 minutes   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp, :::5984->5984/tcp                                        couchdb0
> 04177e310c7f   hyperledger/fabric-orderer:latest   "orderer"                32 minutes ago   Up 32 minutes   0.0.0.0:7050->7050/tcp, :::7050->7050/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp                 orderer.example.com
> b0a9c4908613   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   32 minutes ago   Up 32 minutes   0.0.0.0:7054->7054/tcp, :::7054->7054/tcp, 0.0.0.0:17054->17054/tcp, :::17054->17054/tcp             ca_org1
> 39ef69bd3771   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   32 minutes ago   Up 32 minutes   0.0.0.0:8054->8054/tcp, :::8054->8054/tcp, 7054/tcp, 0.0.0.0:18054->18054/tcp, :::18054->18054/tcp   ca_org2
> 6e098d6ba063   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   32 minutes ago   Up 32 minutes   0.0.0.0:9054->9054/tcp, :::9054->9054/tcp, 7054/tcp, 0.0.0.0:19054->19054/tcp, :::19054->19054/tcp   ca_orderer
> ```
>
> ***`[command]`***
>
> ```docker
> docker ps |wc -l
> ```
>
> `System Response`
>
> ```bash
> 10
> ```
>
> #### 5-2 shutdown test-network
>
> ***`[command]`***
>
> ```bash
> cd $HOME/workspaces/fabric-lab/fabric-samples/test-network
> ./network.sh down
> ```

***創建原始環境***

### 6. 啟動 fabric-ca server

> **工作目錄: $HOME/workspaces/fabric-lab/ca**
>
> ***`[command]`***
>
> ```bash
> cd $HOME/workspaces/fabric-lab/ca
> tree config/
> ```

  `System Response:`

> ```bash
> config/
> ├── org1.com
> │   ├── ca
> │   │   └── fabric-ca-server-config.yaml
> │   └── tls
> │       └── fabric-ca-server-config.yaml
> ├── org2.com
> │   ├── ca
> │   │   └── fabric-ca-server-config.yaml
> │   └── tls
> │       └── fabric-ca-server-config.yaml
> ├── org3.com
> │   ├── ca
> │   │   └── fabric-ca-server-config.yaml
> │   └── tls
> │       └── fabric-ca-server-config.yaml
> └── org4.com
>   ├── ca
>   │   └── fabric-ca-server-config.yaml
>   └── tls
>       └── fabric-ca-server-config.yaml
> 
> 12 directories, 8 files
> ```
>
> **工作目錄: $HOME/workspaces/fabric-lab/ca**
>
> #### 6-1 修改設定檔 (option, 但強烈建議)
>
> 修改 $HOME/workspaces/fabric-lab/ca/config/org[N].com/{ca,tls}/fabric-ca-server-config.yaml
>
> 以 org1.com/ca/fabric-ca-server-config.yaml 為例, 使用 vscode 編輯修改
>
> 1. 修改密碼
>
>> 第 132 行, 將 adminpw 修改為較強密碼
>
>> ***`[command]`***
>
>> ```bash
>> openssl rand -hex 10|base64
>> ```
>
>
> **`[編輯設定檔內容]`**
>
>> 第 310 行，修改 csr
>
>> ```yaml
>> csr:
>> cn: ca.org1.com
>> keyrequest:
>> algo: ecdsa
>> size: 256
>> names:
>>    - C: TW
>>      ST: Taiwan
>>      L:
>>      O: org1.com
>>      OU: Fabric
>> hosts:
>>   - ca.org1.com
>>   - localhost
>> ca:
>>    expiry: 131400h
>>    pathlength: 1
>> ```
>
>
> ***重覆操作，修改 ca.org1.com, tls.org1.com, ca.org2.com, tls.org2.com, ca.org3.com, tls.org3.com, ca.org4.com, tls.org4.com 共 8 個服務***
>
> #### 6-2 啟動 fabric-ca-server docker instances,
>
> ***`[command]`***
>
>> ```bash
>> cd $HOME/workspaces/fabric-lab/ca/
>> docker-compose up -d
>> ```
>

### 7. 登錄以及註冊所有加密材料 (MSP/TLS crypto material)

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/ca**
>
> #### 7.1 編輯各機構的個體基本資料
>
>> **工作目錄: $HOME/workspaces/fabric-lab/workdir/ca/msp**
>
>
> #### 7.2 將範本檔複製到工作目錄
>
> ***`[command]`***
>
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/ca/msp
>> cp ../msp-template/organizations.json organizations.json
>> cp ../msp-template/orderer.json org4.json
>> cp ../msp-template/peer.json org1.json
>> cp ../msp-template/peer.json org2.json
>> ```
>
>
> #### 7.3 編輯修改個別機構資料
>
>> 1. 各機構的 domain name: org1.com,org2.com,org3.com,org4.com
>> 2. port number:
>>    1. ca 服務： 1054, 2054, 3054, 4054
>>    2. tls 服務: 1154, 2154, 3154, 4154
>> 3. secret (密碼):
>>    1. ca, tls server的 admin 密碼，必須要和 section 6-1 的密碼相符
>>    2. 每 一 entity 的密碼 (是選項，但強烈建議修改)
>

> #### 7-4 組合
>
>> 執行 ../script/networkgen.sh 將三個機構的設定檔組合成一個檔案
>
>> ***`[command]`***
>
>> ```bash
>> cd  $HOME/workspaces/fabric-lab/workdir/ca/msp
>> ../scripts/networkgen.sh -t organizations.json -o org4.json -p org1.json -p org2.json -O ../network.json
>> ```
>
>> **-t [template]: 檔案架構的框架**
>
>> **-o [orderer]: orderer 機構的設定檔**
>
>> **-p [peer]: peer 機構設定檔**
>
>> **-O [Output]: 輸出檔案的位置**
>

> #### 7-5 註冊 fabric-ca server 的 admin 管理者
>
>> **工作目錄: $HOME/workspaces/fabric-lab/workdir/ca**
>
>> ***`[command]`***
>
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/ca/
>> ./scripts/enroll.sh ./network.json
>> ```
>
>> 執行完成後，在 $HOME/workspaces/fabric-lab/workdir/ca 會產生 出 Organizations 目錄，結構如下
>
>> ***`[command]`***
>
>>> ```bash
>>> tree -d Organizations
>>> ```
>
>
>> `System Response:`
>
>>> ```bash
>>> Organizations/
>>> ├── ordererOrganizations
>>> │   └── org4.com
>>> │       ├── ca
>>> │       │   └── msp
>>> │       │       ├── cacerts
>>> │       │       ├── keystore
>>> │       │       ├── signcerts
>>> │       │       └── user
>>> │       └── tls
>>> │           └── msp
>>> │               ├── cacerts
>>> │               ├── keystore
>>> │               ├── signcerts
>>> │               └── user
>>> └── peerOrganizations
>>>  ├── org1.com
>>>  │   ├── ca
>>>  │   │   └── msp
>>>  │   │       ├── cacerts
>>>  │   │       ├── keystore
>>>  │   │       ├── signcerts
>>>  │   │       └── user
>>>  │   └── tls
>>>  │       └── msp
>>>  │           ├── cacerts
>>>  │           ├── keystore
>>>  │           ├── signcerts
>>>  │           └── user
>>>  └── org2.com
>>>      ├── ca
>>>      │   └── msp
>>>      │       ├── cacerts
>>>      │       ├── keystore
>>>      │       ├── signcerts
>>>      │       └── user
>>>      └── tls
>>>          └── msp
>>>              ├── cacerts
>>>              ├── keystore
>>>              ├── signcerts
>>>              └── user
>>> ```
>
>
>> 每一 organization 目錄下，有二個目錄 (ca,tls), 分別代表 每一 organization 的 ca 以笗 tls 的管理者 admin 的 identity (身份識別)加密文件
>> 檢查每一個 admin 的檔案架構，以 `$HOME/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/ca` 為例
>
>> ***`[command]`***
>
>>> ```bash
>>> tree Organizations/ordererOrganizations/org4.com/ca/
>>> ```
>
>
>> `System Response:`
>
>>> ```bash
>>> Organizations/ordererOrganizations/org4.com/ca/
>>> ├── fabric-ca-client-config.yaml
>>> ├── msp
>>> │   ├── IssuerPublicKey
>>> │   ├── IssuerRevocationPublicKey
>>> │   ├── cacerts
>>> │   │   └── ca-org4-com-4054.pem
>>> │   ├── keystore
>>> │   │   └── 4ed91631a845b3d444121c64c2744fef3239b96cac07310a386f56fd601f64c3_sk
>>> │   ├── signcerts
>>> │   │   └── cert.pem
>>> │   └── user
>>> └── tls-cert.pem
>>> ```
>
> 

> #### 7-6 生成加密材料
>
>> 登錄以及註冊 Fabric Network 所有 Organizations 以及每一 Organization 的參與者的 identity (身份識別) 加密文件 MSP, TLS
>
>> **工作目錄: $HOME/workspaces/fabric-lab/workdir/ca**
>
>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/ca
>>> ./scripts/crypto.sh network.json
>>> ```
>
>
>> 第一次登錄，會出現 `Error: Response from server: Error Code: 63 - Failed to get User: sql: no rows in result set` 的錯誤訊息，這是因為在登錄前 script 先檢查該 entity 是否已登錄，若沒登錄會收到這個錯誤，並重新登錄。
>
>>> `System Response:`
>
>>> ```bash
>>> Error: Response from server: Error Code: 63 - Failed to get User: sql: no rows in result set
>>> 2023/11/10 23:55:45 [INFO] Configuration file location: /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/ca/fabric-ca-client-config.yaml
>>> 2023/11/10 23:55:45 [INFO] TLS Enabled
>>> 2023/11/10 23:55:45 [INFO] TLS Enabled
>>> Password: adminpw
>>> 2023/11/10 23:55:45 [INFO] TLS Enabled
>>> 2023/11/10 23:55:45 [INFO] generating key: &{A:ecdsa S:256}
>>> 2023/11/10 23:55:45 [INFO] encoded CSR
>>> 2023/11/10 23:55:45 [INFO] Stored client certificate at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/msp/signcerts/cert.pem
>>> 2023/11/10 23:55:45 [INFO] Stored root CA certificate at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/msp/cacerts/ca-org4-com-4054.pem
>>> 2023/11/10 23:55:45 [INFO] Stored Issuer public key at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/msp/IssuerPublicKey
>>> 2023/11/10 23:55:45 [INFO] Stored Issuer revocation public key at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/msp/IssuerRevocationPublicKey
>>> Error: Response from server: Error Code: 63 - Failed to get User: sql: no rows in result set
>>> 2023/11/10 23:55:45 [INFO] Configuration file location: /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/tls/fabric-ca-client-config.yaml
>>> 2023/11/10 23:55:45 [INFO] TLS Enabled
>>> 2023/11/10 23:55:45 [INFO] TLS Enabled
>>> Password: adminpw
>>> 2023/11/10 23:55:45 [INFO] TLS Enabled
>>> 2023/11/10 23:55:45 [INFO] generating key: &{A:ecdsa S:256}
>>> 2023/11/10 23:55:45 [INFO] encoded CSR
>>> 2023/11/10 23:55:45 [INFO] Stored client certificate at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/tls/signcerts/cert.pem
>>> 2023/11/10 23:55:45 [INFO] Stored TLS root CA certificate at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/tls/tlscacerts/tls-tls-org4-com-4154.pem
>>> 2023/11/10 23:55:45 [INFO] Stored Issuer public key at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/tls/IssuerPublicKey
>>> 2023/11/10 23:55:45 [INFO] Stored Issuer revocation public key at /home/hyperledger/workspaces/fabric-lab/workdir/ca/Organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/tls/IssuerRevocationPublicKey
>>> ```
>
> 

>> 執行後，Organization 的目錄結構如下
>
>> ***`[command]`***
>
>>> ```bash
>>> tree -d Organizations
>>> ```
>
>
>> `System Response:`
>
>>> ```bash
>>> Organizations/
>>> ├── ordererOrganizations
>>> │   └── org4.com
>>> │       ├── ca
>>> │       │   └── msp
>>> │       │       ├── cacerts
>>> │       │       ├── keystore
>>> │       │       ├── signcerts
>>> │       │       └── user
>>> │       ├── orderers
>>> │       │   ├── orderer0.org4.com
>>> │       │   │   ├── msp
>>> │       │   │   │   ├── cacerts
>>> │       │   │   │   ├── keystore
>>> │       │   │   │   ├── signcerts
>>> │       │   │   │   └── user
>>> │       │   │   └── tls
>>> │       │   │       ├── cacerts
>>> │       │   │       ├── keystore
>>> │       │   │       ├── signcerts
>>> │       │   │       ├── tlscacerts
>>> │       │   │       └── user
>>> │       │   ├── orderer1.org4.com
>>> │       │   │   ├── msp
>>> │       │   │   │   ├── cacerts
>>> │       │   │   │   ├── keystore
>>> │       │   │   │   ├── signcerts
>>> │       │   │   │   └── user
>>> │       │   │   └── tls
>>> │       │   │       ├── cacerts
>>> │       │   │       ├── keystore
>>> │       │   │       ├── signcerts
>>> │       │   │       ├── tlscacerts
>>> │       │   │       └── user
>>> │       │   └── orderer2.org4.com
>>> │       │       ├── msp
>>> │       │       │   ├── cacerts
>>> │       │       │   ├── keystore
>>> │       │       │   ├── signcerts
>>> │       │       │   └── user
>>> │       │       └── tls
>>> │       │           ├── cacerts
>>> │       │           ├── keystore
>>> │       │           ├── signcerts
>>> │       │           ├── tlscacerts
>>> │       │           └── user
>>> │       ├── tls
>>> │       │   └── msp
>>> │       │       ├── cacerts
>>> │       │       ├── keystore
>>> │       │       ├── signcerts
>>> │       │       └── user
>>> │       └── users
>>> │           └── Admin@org4.com
>>> │               ├── msp
>>> │               │   ├── cacerts
>>> │               │   ├── keystore
>>> │               │   ├── signcerts
>>> │               │   └── user
>>> │               └── tls
>>> │                   ├── cacerts
>>> │                   ├── keystore
>>> │                   ├── signcerts
>>> │                   ├── tlscacerts
>>> │                   └── user
>>> └── peerOrganizations
>>>  ├── org1.com
>>>  │   ├── ca
>>>  │   │   └── msp
>>>  │   │       ├── cacerts
>>>  │   │       ├── keystore
>>>  │   │       ├── signcerts
>>>  │   │       └── user
>>>  │   ├── peers
>>>  │   │   ├── peer0.org1.com
>>>  │   │   │   ├── msp
>>>  │   │   │   │   ├── cacerts
>>>  │   │   │   │   ├── keystore
>>>  │   │   │   │   ├── signcerts
>>>  │   │   │   │   └── user
>>>  │   │   │   └── tls
>>>  │   │   │       ├── cacerts
>>>  │   │   │       ├── keystore
>>>  │   │   │       ├── signcerts
>>>  │   │   │       ├── tlscacerts
>>>  │   │   │       └── user
>>>  │   │   └── peer1.org1.com
>>>  │   │       ├── msp
>>>  │   │       │   ├── cacerts
>>>  │   │       │   ├── keystore
>>>  │   │       │   ├── signcerts
>>>  │   │       │   └── user
>>>  │   │       └── tls
>>>  │   │           ├── cacerts
>>>  │   │           ├── keystore
>>>  │   │           ├── signcerts
>>>  │   │           ├── tlscacerts
>>>  │   │           └── user
>>>  │   ├── tls
>>>  │   │   └── msp
>>>  │   │       ├── cacerts
>>>  │   │       ├── keystore
>>>  │   │       ├── signcerts
>>>  │   │       └── user
>>>  │   └── users
>>>  │       ├── Admin@org1.com
>>>  │       │   ├── msp
>>>  │       │   │   ├── cacerts
>>>  │       │   │   ├── keystore
>>>  │       │   │   ├── signcerts
>>>  │       │   │   └── user
>>>  │       │   └── tls
>>>  │       │       ├── cacerts
>>>  │       │       ├── keystore
>>>  │       │       ├── signcerts
>>>  │       │       ├── tlscacerts
>>>  │       │       └── user
>>>  │       └── user1@org1.com
>>>  │           ├── msp
>>>  │           │   ├── cacerts
>>>  │           │   ├── keystore
>>>  │           │   ├── signcerts
>>>  │           │   └── user
>>>  │           └── tls
>>>  │               ├── cacerts
>>>  │               ├── keystore
>>>  │               ├── signcerts
>>>  │               ├── tlscacerts
>>>  │               └── user
>>>  └── org2.com
>>>      ├── ca
>>>      │   └── msp
>>>      │       ├── cacerts
>>>      │       ├── keystore
>>>      │       ├── signcerts
>>>      │       └── user
>>>      ├── peers
>>>      │   ├── peer0.org2.com
>>>      │   │   ├── msp
>>>      │   │   │   ├── cacerts
>>>      │   │   │   ├── keystore
>>>      │   │   │   ├── signcerts
>>>      │   │   │   └── user
>>>      │   │   └── tls
>>>      │   │       ├── cacerts
>>>      │   │       ├── keystore
>>>      │   │       ├── signcerts
>>>      │   │       ├── tlscacerts
>>>      │   │       └── user
>>>      │   └── peer1.org2.com
>>>      │       ├── msp
>>>      │       │   ├── cacerts
>>>      │       │   ├── keystore
>>>      │       │   ├── signcerts
>>>      │       │   └── user
>>>      │       └── tls
>>>      │           ├── cacerts
>>>      │           ├── keystore
>>>      │           ├── signcerts
>>>      │           ├── tlscacerts
>>>      │           └── user
>>>      ├── tls
>>>      │   └── msp
>>>      │       ├── cacerts
>>>      │       ├── keystore
>>>      │       ├── signcerts
>>>      │       └── user
>>>      └── users
>>>          ├── Admin@org2.com
>>>          │   ├── msp
>>>          │   │   ├── cacerts
>>>          │   │   ├── keystore
>>>          │   │   ├── signcerts
>>>          │   │   └── user
>>>          │   └── tls
>>>          │       ├── cacerts
>>>          │       ├── keystore
>>>          │       ├── signcerts
>>>          │       ├── tlscacerts
>>>          │       └── user
>>>          └── user1@org2.com
>>>              ├── msp
>>>              │   ├── cacerts
>>>              │   ├── keystore
>>>              │   ├── signcerts
>>>              │   └── user
>>>              └── tls
>>>                  ├── cacerts
>>>                  ├── keystore
>>>                  ├── signcerts
>>>                  ├── tlscacerts
>>>                  └── user
>>> ```
>
>
>> 執行完成後， script 會依 Organizations 目錄內容產出 channelMSP, localMSP 二個目錄，channelMSP 為提供區塊鏈設定以及其他機構驗證我機構的 entity 使用， localMSP 為我方各 entity (orderer,peer, admin, client) 參與 Fabric network 的身份識別、簽章使用
>> 檢查 channelMSP 的檔案內容
>
>>> ***`[command]`***
>
>>> ```bash
>>> tree channelMSP
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> channelMSP
>>> ├── ordererOrganizations
>>> │   └── org4.com
>>> │       ├── msp
>>> │       │   ├── admincerts
>>> │       │   ├── cacerts
>>> │       │   │   └── ca.pem
>>> │       │   ├── config.yaml
>>> │       │   └── tlscacerts
>>> │       │       └── tlsca.org4.com-cert.pem
>>> │       └── orderers
>>> │           ├── orderer0.org4.com
>>> │           │   └── tls
>>> │           │       └── server.crt
>>> │           ├── orderer1.org4.com
>>> │           │   └── tls
>>> │           │       └── server.crt
>>> │           └── orderer2.org4.com
>>> │               └── tls
>>> │                   └── server.crt
>>> └── peerOrganizations
>>>  ├── org1.com
>>>  │   └── msp
>>>  │       ├── admincerts
>>>  │       ├── cacerts
>>>  │       │   └── ca.pem
>>>  │       ├── config.yaml
>>>  │       └── tlscacerts
>>>  │           └── tlsca.org1.com-cert.pem
>>>  └── org2.com
>>>      └── msp
>>>          ├── admincerts
>>>          ├── cacerts
>>>          │   └── ca.pem
>>>          ├── config.yaml
>>>          └── tlscacerts
>>>              └── tlsca.org2.com-cert.pem
>>> ```
>
>
>> 檢查 localMSP 的內容
>
>> ***`[command]`***
>
>>> ```bash
>>> tree -d localMSP/
>>> ```
>
>
>> `System Response:`
>
>>> ```bash
>>> localMSP/
>>> ├── ordererOrganizations
>>> │   └── org4.com
>>> │       ├── msp
>>> │       │   ├── admincerts
>>> │       │   ├── cacerts
>>> │       │   └── tlscacerts
>>> │       ├── orderers
>>> │       │   ├── orderer0.org4.com
>>> │       │   │   ├── msp
>>> │       │   │   │   ├── admincerts
>>> │       │   │   │   ├── cacerts
>>> │       │   │   │   ├── keystore
>>> │       │   │   │   ├── signcerts
>>> │       │   │   │   └── tlscacerts
>>> │       │   │   └── tls
>>> │       │   ├── orderer1.org4.com
>>> │       │   │   ├── msp
>>> │       │   │   │   ├── admincerts
>>> │       │   │   │   ├── cacerts
>>> │       │   │   │   ├── keystore
>>> │       │   │   │   ├── signcerts
>>> │       │   │   │   └── tlscacerts
>>> │       │   │   └── tls
>>> │       │   └── orderer2.org4.com
>>> │       │       ├── msp
>>> │       │       │   ├── admincerts
>>> │       │       │   ├── cacerts
>>> │       │       │   ├── keystore
>>> │       │       │   ├── signcerts
>>> │       │       │   └── tlscacerts
>>> │       │       └── tls
>>> │       └── users
>>> │           └── Admin@org4.com
>>> │               ├── msp
>>> │               │   ├── admincerts
>>> │               │   ├── cacerts
>>> │               │   ├── keystore
>>> │               │   ├── signcerts
>>> │               │   └── tlscacerts
>>> │               └── tls
>>> └── peerOrganizations
>>>  ├── org1.com
>>>  │   ├── msp
>>>  │   │   ├── admincerts
>>>  │   │   ├── cacerts
>>>  │   │   └── tlscacerts
>>>  │   ├── peers
>>>  │   │   ├── peer0.org1.com
>>>  │   │   │   ├── msp
>>>  │   │   │   │   ├── admincerts
>>>  │   │   │   │   ├── cacerts
>>>  │   │   │   │   ├── keystore
>>>  │   │   │   │   ├── signcerts
>>>  │   │   │   │   └── tlscacerts
>>>  │   │   │   └── tls
>>>  │   │   └── peer1.org1.com
>>>  │   │       ├── msp
>>>  │   │       │   ├── admincerts
>>>  │   │       │   ├── cacerts
>>>  │   │       │   ├── keystore
>>>  │   │       │   ├── signcerts
>>>  │   │       │   └── tlscacerts
>>>  │   │       └── tls
>>>  │   └── users
>>>  │       ├── Admin@org1.com
>>>  │       │   ├── msp
>>>  │       │   │   ├── admincerts
>>>  │       │   │   ├── cacerts
>>>  │       │   │   ├── keystore
>>>  │       │   │   ├── signcerts
>>>  │       │   │   └── tlscacerts
>>>  │       │   └── tls
>>>  │       └── user1@org1.com
>>>  │           ├── msp
>>>  │           │   ├── admincerts
>>>  │           │   ├── cacerts
>>>  │           │   ├── keystore
>>>  │           │   ├── signcerts
>>>  │           │   └── tlscacerts
>>>  │           └── tls
>>>  └── org2.com
>>>      ├── msp
>>>      │   ├── admincerts
>>>      │   ├── cacerts
>>>      │   └── tlscacerts
>>>      ├── peers
>>>      │   ├── peer0.org2.com
>>>      │   │   ├── msp
>>>      │   │   │   ├── admincerts
>>>      │   │   │   ├── cacerts
>>>      │   │   │   ├── keystore
>>>      │   │   │   ├── signcerts
>>>      │   │   │   └── tlscacerts
>>>      │   │   └── tls
>>>      │   └── peer1.org2.com
>>>      │       ├── msp
>>>      │       │   ├── admincerts
>>>      │       │   ├── cacerts
>>>      │       │   ├── keystore
>>>      │       │   ├── signcerts
>>>      │       │   └── tlscacerts
>>>      │       └── tls
>>>      └── users
>>>          ├── Admin@org2.com
>>>          │   ├── msp
>>>          │   │   ├── admincerts
>>>          │   │   ├── cacerts
>>>          │   │   ├── keystore
>>>          │   │   ├── signcerts
>>>          │   │   └── tlscacerts
>>>          │   └── tls
>>>          └── user1@org2.com
>>>              ├── msp
>>>              │   ├── admincerts
>>>              │   ├── cacerts
>>>              │   ├── keystore
>>>              │   ├── signcerts
>>>              │   └── tlscacerts
>>>              └── tls
>>> ```
>
>
>> 檢查 localMSP 目錄下每一 entity 的加密文件是否齊全完整
>
>> ***`[command]`***
>
>>> ```bash
>>> tree localMSP/peerOrganizations/org1.com/peers/peer0.org1.com/
>>> ```
>
>
>> `System Response:`
>
>>> ```bash
>>> localMSP/peerOrganizations/org1.com/peers/peer0.org1.com/
>>> ├── msp
>>> │   ├── admincerts
>>> │   ├── cacerts
>>> │   │   └── ca.pem
>>> │   ├── config.yaml
>>> │   ├── keystore
>>> │   │   └── priv_sk
>>> │   ├── signcerts
>>> │   │   └── peer0.org1.com-cert.pem
>>> │   └── tlscacerts
>>> │       └── tlsca.org1.com-cert.pem
>>> └── tls
>>>  ├── ca.crt
>>>  ├── server.crt
>>>  └── server.key
>>> ```
>
>

### 8. Hyperldger Fabric Network configuration

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/config**

>> #### 8-1 將 section 7 產出的  `channelMSP` 複製到工作目錄 organizations
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/config
>>> cp -a $HOME/workspaces/fabric-lab/workdir/ca/channelMSP $HOME/workspaces/fabric-lab/workdir/config/organizations
>>> ```
>
>
>> #### 8-2 編輯 configtx.yaml
>
>> **`[設定檔內容]`**`
>
>>> ```yaml
>>> Organizations:
>>>     - &OrdererOrg
>>>         Name: OrdererMSP
>>>         ID: OrdererMSP
>>>         MSPDir: ./organizations/ordererOrganizations/org4.com/msp
>>>         Policies:
>>>             Readers:
>>>                 Type: Signature
>>>                 Rule: "OR('OrdererMSP.member')"
>>>             Writers:
>>>                 Type: Signature
>>>                 Rule: "OR('OrdererMSP.member')"
>>>             Admins:
>>>                 Type: Signature
>>>                 Rule: "OR('OrdererMSP.admin')"
>>>         OrdererEndpoints:
>>>             - orderer0.org4.com:4050
>>>             - orderer1.org4.com:4150
>>>             - orderer2.org4.com:4250
>>>     - &Org1
>>>         Name: Org1MSP
>>>         ID: Org1MSP
>>>         MSPDir: ./organizations/peerOrganizations/org1.com/msp
>>>         Policies:
>>>             Readers:
>>>                 Type: Signature
>>>                 Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
>>>             Writers:
>>>                 Type: Signature
>>>                 Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
>>>             Admins:
>>>                 Type: Signature
>>>                 Rule: "OR('Org1MSP.admin')"
>>>             Endorsement:
>>>                 Type: Signature
>>>                 Rule: "OR('Org1MSP.peer')"
>>>     - &Org2
>>>         Name: Org2MSP
>>>         ID: Org2MSP
>>>         MSPDir: ./organizations/peerOrganizations/org2.com/msp
>>>         Policies:
>>>             Readers:
>>>                 Type: Signature
>>>                 Rule: "OR('Org2MSP.admin', 'Org2MSP.peer', 'Org2MSP.client')"
>>>             Writers:
>>>                 Type: Signature
>>>                 Rule: "OR('Org2MSP.admin', 'Org2MSP.client')"
>>>             Admins:
>>>                 Type: Signature
>>>                 Rule: "OR('Org2MSP.admin')"
>>>             Endorsement:
>>>                 Type: Signature
>>>                 Rule: "OR('Org2MSP.peer')"
>>> Capabilities:
>>>  Channel: &ChannelCapabilities
>>>      V2_0: true
>>>  Orderer: &OrdererCapabilities
>>>      V2_0: true
>>>  Application: &ApplicationCapabilities
>>>      V2_0: true
>>> Application: &ApplicationDefaults
>>>  Organizations:
>>>  Policies:
>>>      Readers:
>>>          Type: ImplicitMeta
>>>          Rule: "ANY Readers"
>>>      Writers:
>>>          Type: ImplicitMeta
>>>          Rule: "ANY Writers"
>>>      Admins:
>>>          Type: ImplicitMeta
>>>          Rule: "MAJORITY Admins"
>>>      LifecycleEndorsement:
>>>          Type: ImplicitMeta
>>>          Rule: "MAJORITY Endorsement"
>>>      Endorsement:
>>>          Type: ImplicitMeta
>>>          Rule: "MAJORITY Endorsement"
>>>  Capabilities:
>>>      <<: *ApplicationCapabilities
>>> Orderer: &OrdererDefaults
>>>     OrdererType: etcdraft
>>>     Addresses:
>>>         - orderer0.org4.com:4050
>>>         - orderer1.org4.com:4150
>>>         - orderer2.org4.com:4250
>>>     EtcdRaft:
>>>         Consenters:
>>>         - Host: orderer0.org4.com
>>>           Port: 4050
>>>           ClientTLSCert: ./organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/tls/server.crt
>>>           ServerTLSCert: ./organizations/ordererOrganizations/org4.com/orderers/orderer0.org4.com/tls/server.crt
>>>         - Host: orderer1.org4.com
>>>           Port: 4150
>>>           ClientTLSCert: ./organizations/ordererOrganizations/org4.com/orderers/orderer1.org4.com/tls/server.crt
>>>           ServerTLSCert: ./organizations/ordererOrganizations/org4.com/orderers/orderer1.org4.com/tls/server.crt
>>>         - Host: orderer2.org4.com
>>>           Port: 4250
>>>           ClientTLSCert: ./organizations/ordererOrganizations/org4.com/orderers/orderer2.org4.com/tls/server.crt
>>>           ServerTLSCert: ./organizations/ordererOrganizations/org4.com/orderers/orderer2.org4.com/tls/server.crt
>>>     BatchTimeout: 2s
>>>     BatchSize:
>>>         MaxMessageCount: 100
>>>         AbsoluteMaxBytes: 99 MB
>>>         PreferredMaxBytes: 512 KB
>>>     Organizations:
>>>     Policies:
>>>         Readers:
>>>             Type: ImplicitMeta
>>>             Rule: "ANY Readers"
>>>         Writers:
>>>             Type: ImplicitMeta
>>>             Rule: "ANY Writers"
>>>         Admins:
>>>             Type: ImplicitMeta
>>>             Rule: "MAJORITY Admins"
>>>         BlockValidation:
>>>             Type: ImplicitMeta
>>>             Rule: "ANY Writers"
>>> Channel: &ChannelDefaults
>>>     Policies:
>>>         Readers:
>>>             Type: ImplicitMeta
>>>             Rule: "ANY Readers"
>>>         Writers:
>>>             Type: ImplicitMeta
>>>             Rule: "ANY Writers"
>>>         Admins:
>>>             Type: ImplicitMeta
>>>             Rule: "MAJORITY Admins"
>>>     Capabilities:
>>>         <<: *ChannelCapabilities
>>> Profiles:
>>>  OrdererGenesis:
>>>      <<: *ChannelDefaults
>>>      Orderer:
>>>          <<: *OrdererDefaults
>>>          Organizations:
>>>                 - *OrdererOrg
>>>             Capabilities:
>>>                 <<: *OrdererCapabilities
>>>         Consortiums:
>>>             financeConsortium:
>>>                 Organizations:
>>>                     - *Org1
>>>                     - *Org2
>>>     Channel12:
>>>         Consortium: financeConsortium
>>>         <<: *ChannelDefaults
>>>         Application:
>>>             <<: *ApplicationDefaults
>>>             Organizations:
>>>                 - *Org1
>>>                 - *Org2
>>>             Capabilities:
>>>                 <<: *ApplicationCapabilities
>>>     ```
>
>> #### 8-3 由 configtx.yaml 中的 OrdererGenesis profile 生成 system-channel 的創世區塊
>
>> **工作目錄: $HOWM/workspaces/fabric-lab/workdir/config**
>> 執行下列指令生成 創世區塊
>
>> ***`[command]`***
>
>>> ```bash
>>> cd $HOWM/workspaces/fabric-lab/workdir/config
>>> configtxgen -profile OrdererGenesis -configPath $PWD -channelID system-channel -outputBlock ../system-genesis-block/genesis.block
>>> ```
>
>
>> 將 protobuf 檔案格式 轉換成 json 格式 (option)
>
>> ***`[command]`***
>
>>> ```bash
>>> configtxgen -inspectBlock ../system-genesis-block/genesis.block > ../system-genesis-block/genesis.json
>>> ```
>
>

### 9. Application channel 的 configure block

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/config**
>
>> 使用 configtx.yaml 中的 Channel12 profile 生成 channel1 的 config block
>
>> ***`[command]`***
>
>>> ```bash
>>> configtxgen -profile Channel12 -configPath $PWD  -channelID channel1 -outputCreateChannelTx ../channel-artifacts/channel1.tx
>>> ```
>
>
>> 將 protobuf 檔案格式 轉換成 json 格式 (option)
>
>> ***`[command]`***
>
>>> ```bash
>>> configtxgen -inspectChannelCreateTx ../channel-artifacts/channel1.tx > ../channel-artifacts/channel1.json
>>> ```
>
> 

### 10. 啟動 orderer service

> **工作目錄: $HOME/workspaces/fabric-lab/service/orderer**
>
>> 10-1 環境部署
>
>> 1. 創建每一orderer 服務的工作目錄
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/service/orderer
>>> mkdir -p $HOME/workspaces/fabric-lab/service/orderer/org4.com/{orderer0.org4.com,orderer1.org4.com,orderer2.org4.com}
>>> ```
>
>
>> 2. 複製創世區塊
>
>>> ***`[command]`***
>
>>> ```bash
>>> cp $HOME/workspaces/fabric-lab/workdir/system-genesis-block/genesis.block $HOME/workspaces/fabric-lab/service/orderer
>>> ```
>
>
>> 3. 由 $HOME/workspaces/fabric-lab/workdir/ca/localMSP/ordererOrganizations/org4.com/orderers/ 複製 每一 orderer 服務的 `localMSP` 的資料夾到對應的工作目錄
>
>>> ***`[command]`***
>
>>> ```bash
>>> tree -d $HOME/workspaces/fabric-lab/workdir/ca/localMSP/ordererOrganizations/org4.com/orderers/
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> $HOME/workspaces/fabric-lab/workdir/ca/localMSP/ordererOrganizations/org4.com/orderers/
>>> ├── orderer0.org4.com
>>> │   ├── msp
>>> │   │   ├── admincerts
>>> │   │   ├── cacerts
>>> │   │   ├── keystore
>>> │   │   ├── signcerts
>>> │   │   └── tlscacerts
>>> │   └── tls
>>> ├── orderer1.org4.com
>>> │   ├── msp
>>> │   │   ├── admincerts
>>> │   │   ├── cacerts
>>> │   │   ├── keystore
>>> │   │   ├── signcerts
>>> │   │   └── tlscacerts
>>> │   └── tls
>>> └── orderer2.org4.com
>>>  ├── msp
>>>  │   ├── admincerts
>>>  │   ├── cacerts
>>>  │   ├── keystore
>>>  │   ├── signcerts
>>>  │   └── tlscacerts
>>>  └── tls
>>> ```
>
>
>> 4. 或直接執行以下 script 完成
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/service/orderer
>>> ./scripts/cpMSP.sh 
>>> ```
>
>
>> 5. 最終部署完成的架構
>
>>> ***`[command]`***
>
>>> ```bash
>>> tree -d $HOME/workspaces/fabric-lab/service/orderer
>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> $HOME/workspaces/fabric-lab/service/orderer
>>>> ├── org4.com
>>>> │   ├── orderer0.org4.com
>>>> │   │   └── orderer0.org4.com
>>>> │   │       ├── msp
>>>> │   │       │   ├── admincerts
>>>> │   │       │   ├── cacerts
>>>> │   │       │   ├── keystore
>>>> │   │       │   ├── signcerts
>>>> │   │       │   └── tlscacerts
>>>> │   │       └── tls
>>>> │   ├── orderer1.org4.com
>>>> │   │   └── orderer1.org4.com
>>>> │   │       ├── msp
>>>> │   │       │   ├── admincerts
>>>> │   │       │   ├── cacerts
>>>> │   │       │   ├── keystore
>>>> │   │       │   ├── signcerts
>>>> │   │       │   └── tlscacerts
>>>> │   │       └── tls
>>>> │   └── orderer2.org4.com
>>>> │       └── orderer2.org4.com
>>>> │           ├── msp
>>>> │           │   ├── admincerts
>>>> │           │   ├── cacerts
>>>> │           │   ├── keystore
>>>> │           │   ├── signcerts
>>>> │           │   └── tlscacerts
>>>> │           └── tls
>>>> └── scripts
>>>> ```
>
> 
>
>> 10-2 啟動 orderer service
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/service/orderer
>>> docker-compose up -d
>>> ```
>
> 

>> 10-3 檢查 各 orderer 服務的 docker instance 是否正常啟動
>
>>> 檢查每一 orderer 服務的 log 是否選舉 leader 完成
>
>>> ***`[command]`***
>
>>> ```bash
>>> docker logs -f orderer0.org4.com
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> 2023-11-11 03:35:38.005 UTC [orderer.consensus.etcdraft] campaign -> INFO 030 1 [logterm: 1, index: 3] sent MsgVote request to 2 at term 2 channel=system-channel node=1
>>> 2023-11-11 03:35:38.005 UTC [orderer.consensus.etcdraft] campaign -> INFO 031 1 [logterm: 1, index: 3] sent MsgVote request to 3 at term 2 channel=system-channel node=1
>>> 2023-11-11 03:35:38.006 UTC [orderer.consensus.etcdraft] poll -> INFO 032 1 received MsgVoteResp from 2 at term 2 channel=system-channel node=1
>>> 2023-11-11 03:35:38.006 UTC [orderer.consensus.etcdraft] stepCandidate -> INFO 033 1 [quorum:2] has received 2 MsgVoteResp votes and 0 vote rejections channel=system-channel node=1
>>> 2023-11-11 03:35:38.006 UTC [orderer.consensus.etcdraft] becomeLeader -> INFO 034 1 became leader at term 2 channel=system-channel node=1
>>> 2023-11-11 03:35:38.006 UTC [orderer.consensus.etcdraft] run -> INFO 035 raft.node: 1 elected leader 1 at term 2 channel=system-channel node=1
>>> 2023-11-11 03:35:38.006 UTC [orderer.consensus.etcdraft] run -> INFO 036 Leader 1 is present, quit campaign channel=system-channel node=1
>>> 2023-11-11 03:35:38.006 UTC [orderer.consensus.etcdraft] run -> INFO 037 Raft leader changed: 0 -> 1 channel=system-channel node=1
>>> ```
>
>

### 11. 啟動 peer service

> **工作目錄: $HOME/workspaces/fabric-lab/service/peers**
>
>> 11-1 環境部署配置
>
>>> 1. 創建每一organization 的 peer node 的工作目錄
>
>>> ***`[command]`***
>
>>>> ```bash
>>>> mkdir -p $HOME/workspaces/fabric-lab/service/peers/org1.com/{peer0.org1.com,peer1.org1.com}
>>>> mkdir -p $HOME/workspaces/fabric-lab/service/peers/org2.com/{peer0.org2.com,peer1.org2.com}
>>>> ```
>
>
>>> 2. 複製每一 peer organizations 的 peers/pee{0,1}/ 到對應的目錄位置
>
>>> ***`[command]`***
>
>>> ```bash
>>> tree -d $HOME/workspaces/fabric-lab/workdir/ca/localMSP/peerOrganizations/*/peers/peer*
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> $homeworkspaces/fabric-lab/workdir/ca/localMSP/peerOrganizations/org1.com/peers/peer0.org1.com
>>> ├── msp
>>> │   ├── admincerts
>>> │   ├── cacerts
>>> │   ├── keystore
>>> │   ├── signcerts
>>> │   └── tlscacerts
>>> └── tls
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> $homeworkspaces/fabric-lab/workdir/ca/localMSP/peerOrganizations/org1.com/peers/peer1.org1.com
>>> ├── msp
>>> │   ├── admincerts
>>> │   ├── cacerts
>>> │   ├── keystore
>>> │   ├── signcerts
>>> │   └── tlscacerts
>>> └── tls
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> $homeworkspaces/fabric-lab/workdir/ca/localMSP/peerOrganizations/org2.com/peers/peer0.org2.com
>>> ├── msp
>>> │   ├── admincerts
>>> │   ├── cacerts
>>> │   ├── keystore
>>> │   ├── signcerts
>>> │   └── tlscacerts
>>> └── tls
>>> ```
>
>>> `System Response:`
>
>>> ```bash
>>> $homeworkspaces/fabric-lab/workdir/ca/localMSP/peerOrganizations/org2.com/peers/peer1.org2.com
>>> ├── msp
>>> │   ├── admincerts
>>> │   ├── cacerts
>>> │   ├── keystore
>>> │   ├── signcerts
>>> │   └── tlscacerts
>>> └── tls
>>> ```
>
>>> 3. 替代方案, 執行 $HOME/workspaces/fabric-lab/service/peers/scripts/cpMSP.sh
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/service/peers
>>>> $HOME/workspaces/fabric-lab/service/peers/scripts/cpMSP.sh
>>>> ```
>
>
>>> 4. 檢查結果:
>
>>> ***`[command]`***
>
>>> ```bash
>>> tree */
>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> org1.com/
>>>> ├── peer0.org1.com
>>>> │   └── peer0.org1.com
>>>> │       ├── msp
>>>> │       │   ├── admincerts
>>>> │       │   ├── cacerts
>>>> │       │   │   └── ca.pem
>>>> │       │   ├── config.yaml
>>>> │       │   ├── keystore
>>>> │       │   │   └── priv_sk
>>>> │       │   ├── signcerts
>>>> │       │   │   └── peer0.org1.com-cert.pem
>>>> │       │   └── tlscacerts
>>>> │       │       └── tlsca.org1.com-cert.pem
>>>> │       └── tls
>>>> │           ├── ca.crt
>>>> │           ├── server.crt
>>>> │           └── server.key
>>>> └── peer1.org1.com
>>>>  └── peer1.org1.com
>>>>      ├── msp
>>>>      │   ├── admincerts
>>>>      │   ├── cacerts
>>>>      │   │   └── ca.pem
>>>>      │   ├── config.yaml
>>>>      │   ├── keystore
>>>>      │   │   └── priv_sk
>>>>      │   ├── signcerts
>>>>      │   │   └── peer1.org1.com-cert.pem
>>>>      │   └── tlscacerts
>>>>      │       └── tlsca.org1.com-cert.pem
>>>>      └── tls
>>>>          ├── ca.crt
>>>>          ├── server.crt
>>>>          └── server.key
>>>> ```
>
>
>>> `System Response:`
>
>>>> ```bash
>>>> org2.com/
>>>> ├── peer0.org2.com
>>>> │   └── peer0.org2.com
>>>> │       ├── msp
>>>> │       │   ├── admincerts
>>>> │       │   ├── cacerts
>>>> │       │   │   └── ca.pem
>>>> │       │   ├── config.yaml
>>>> │       │   ├── keystore
>>>> │       │   │   └── priv_sk
>>>> │       │   ├── signcerts
>>>> │       │   │   └── peer0.org2.com-cert.pem
>>>> │       │   └── tlscacerts
>>>> │       │       └── tlsca.org2.com-cert.pem
>>>> │       └── tls
>>>> │           ├── ca.crt
>>>> │           ├── server.crt
>>>> │           └── server.key
>>>> └── peer1.org2.com
>>>>  └── peer1.org2.com
>>>>      ├── msp
>>>>      │   ├── admincerts
>>>>      │   ├── cacerts
>>>>      │   │   └── ca.pem
>>>>      │   ├── config.yaml
>>>>      │   ├── keystore
>>>>      │   │   └── priv_sk
>>>>      │   ├── signcerts
>>>>      │   │   └── peer1.org2.com-cert.pem
>>>>      │   └── tlscacerts
>>>>      │       └── tlsca.org2.com-cert.pem
>>>>      └── tls
>>>>          ├── ca.crt
>>>>          ├── server.crt
>>>>          └── server.key
>>>> ```
>
> 
>
>>> 5. 啟動 peer 服務
>
>>>> 1. docker-compose up -d peer0.org1.com peer1.org1.com peer0.org2.com peer1.org2.com
>
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/service/peers
>>>> docker-compose up -d peer0.org1.com peer1.org1.com peer0.org2.com peer1.org2.com
>>>> ```
>
> 
>

### 12. 創建 channel 以及 join channel

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/org1-client**

>> 1. 啟始環境部署配置
>>    執行 $HOME/workspaces/fabric-lab/workdir/org1-client/scripts/init.sh
>
>>> 1. 複製執行角色的身份識別文件 (MSP/TLS) 到對映位置，
>>> 2. 複製每一參與機構的 TLS root CA 到對應位置
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org1-client
>>>> ./scripts/init.sh
>>>> ```
>
>
>
>> 2. 初始化環境變數
>
>>> 1. 設定 MSPID, 操作的節點, 操作的角色 (admin or client) 以及 ORDERER_TLS_CA 的位置
>
>>>> `[設定檔內容]`
>
>>>> ```script
>>>> export MSP=Org1MSP
>>>> export HOST=$1
>>>> export DOMAIN=org1.com
>>>> export PORT=$2
>>>> export CORE_PEER_TLS_ENABLED=true
>>>> export CORE_PEER_LOCALMSPID=$MSP
>>>> export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/users/Admin@$DOMAIN/tls/ca.crt
>>>> export CORE_PEER_MSPCONFIGPATH=${PWD}/users/Admin@$DOMAIN/msp
>>>> # export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
>>>> # export CORE_PEER_TLS_CLIENTCERT_FILE=${PWD}/users/Admin@$DOMAIN/tls/client.crt
>>>> # export CORE_PEER_TLS_CLIENTKEY_FILE=${PWD}/users/Admin@$DOMAIN/tls/client.key
>>>> export CORE_PEER_ADDRESS=$HOST.$DOMAIN:$PORT
>>>> export FABRIC_CFG_PATH=$GOPATH/config
>>>> export ORDERER_TLS_CA=$PWD/tlsca/tlsca.org4.com-cert.pem
>>>> ```
>
>
>>> 2. 初始化身 Admin@org1.com 的身份
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> source admin.env peer0 1051
>>>> ```
>
>
>
>> 3. 創建 Application channel - channel1
>
>>> **工作目錄: $HOME/workspaces/fabric-lab/workdir/org1-client/tmp**
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org1-client/tmp
>>>> peer channel create -f ../../channel-artifacts/channel1.tx -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>>> ```
>
>
>>> `System response:`
>
>>>> ```bash
>>>> 2023-11-11 08:45:10.206 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:10.214 UTC [cli.common] readBlock -> INFO 002 Expect block, but got status: &{NOT_FOUND}
>>>> 2023-11-11 08:45:10.216 UTC [channelCmd] InitCmdFactory -> INFO 003 Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:10.417 UTC [cli.common] readBlock -> INFO 004 Expect block, but got status: &{SERVICE_UNAVAILABLE}
>>>> 2023-11-11 08:45:10.418 UTC [channelCmd] InitCmdFactory -> INFO 005 Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:10.619 UTC [cli.common] readBlock -> INFO 006 Expect block, but got status: &{SERVICE_UNAVAILABLE}
>>>> 2023-11-11 08:45:10.620 UTC [channelCmd] InitCmdFactory -> INFO 007 Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:10.821 UTC [cli.common] readBlock -> INFO 008 Expect block, but got status: &{SERVICE_UNAVAILABLE}
>>>> 2023-11-11 08:45:10.822 UTC [channelCmd] InitCmdFactory -> INFO 009 Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:11.023 UTC [cli.common] readBlock -> INFO 00a Expect block, but got status: &{SERVICE_UNAVAILABLE}
>>>> 2023-11-11 08:45:11.024 UTC [channelCmd] InitCmdFactory -> INFO 00b Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:11.225 UTC [cli.common] readBlock -> INFO 00c Expect block, but got status: &{SERVICE_UNAVAILABLE}
>>>> 2023-11-11 08:45:11.226 UTC [channelCmd] InitCmdFactory -> INFO 00d Endorser and orderer connections initialized
>>>> 2023-11-11 08:45:11.428 UTC [cli.common] readBlock -> INFO 00e Received block: 0
>>>> ```
>
>
>>> 檢查 orderer node 的 log 是否創建 channel1 的 log, 並完成 leader election?
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs -f orderer0.org4.com
>>>> ```
>
>
>>> 系統回應 (僅列出關鍵列)
>
>>>> `以下 log 在 system-channel create 一個區塊, 接收到 config transaction 的請求`
>
>>>> ```log
>>>> 2023-11-11 08:45:10.213 UTC [orderer.consensus.etcdraft] propose -> INFO 039 Created block [1], there are 0 blocks in flight channel=system-channel node=1
>>>> 2023-11-11 08:45:10.214 UTC [orderer.consensus.etcdraft] run -> INFO 03a Received config transaction, pause accepting transaction till it is committed channel=system-channel node=1
>>>> 2023-11-11 08:45:10.214 UTC [comm.grpc.server] 1 -> INFO 03b streaming call completed grpc.service=orderer.AtomicBroadcast grpc.method=Broadcast grpc.peer_address=172.21.0.1:36278 grpc.code=OK grpc.call_duration=6.376872ms
>>>> 2023-11-11 08:45:10.214 UTC [comm.grpc.server] 1 -> INFO 03c streaming call completed grpc.service=orderer.AtomicBroadcast grpc.method=Deliver grpc.peer_address=172.21.0.1:36272 grpc.code=OK grpc.call_duration=7.813752ms
>>>> 2023-11-11 08:45:10.219 UTC [orderer.consensus.etcdraft] writeBlock -> INFO 03d Writing block [1] (Raft index: 5) to ledger channel=system-channel node=1
>>>> ```
>
>>>> `開始 leader election, 最終選出第二個 orderer node (orderer1.org4.com) 為 leader`
>
>>>> ```log
>>>> 2023-11-11 08:45:11.232 UTC [orderer.consensus.etcdraft] Step -> INFO 05c 1 [logterm: 1, index: 3, vote: 0] cast MsgPreVote for 2 [logterm: 1, index: 3] at term 1 channel=channel1 node=1
>>>> 2023-11-11 08:45:11.233 UTC [orderer.consensus.etcdraft] Step -> INFO 05d 1 [term: 1] received a MsgVote message with higher term from 2 [term: 2] channel=channel1 node=1
>>>> 2023-11-11 08:45:11.233 UTC [orderer.consensus.etcdraft] becomeFollower -> INFO 05e 1 became follower at term 2 channel=channel1 node=1
>>>> 2023-11-11 08:45:11.233 UTC [orderer.consensus.etcdraft] Step -> INFO 05f 1 [logterm: 1, index: 3, vote: 0] cast MsgVote for 2 [logterm: 1, index: 3] at term 2 channel=channel1 node=1
>>>> 2023-11-11 08:45:11.234 UTC [orderer.consensus.etcdraft] run -> INFO 060 raft.node: 1 elected leader 2 at term 2 channel=channel1 node=1
>>>> 2023-11-11 08:45:11.234 UTC [orderer.consensus.etcdraft] run -> INFO 061 Raft leader changed: 0 -> 2 channel=channel1 node=1
>>>> ```
>
>
>>> ***PS:*** 在 create channel 成功後，在當下目錄會有一創世區塊的檔案，<channel_name>.block
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> ls
>>>> ```
>
>
>>> 系統 response:
>
>>>> ```bash
>>>> channel1.block
>>>> ```
>
>
>
>> 4. Org1 Join  channel
>
>>> 1. 執行指令加入 channel1
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer channel join -b channel1.block
>>>> ```
>
>
>>> `System Response:``
>
>>>> ```bash
>>>> 2023-11-11 09:29:59.371 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 09:29:59.428 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
>>>> ```
>
>
>>> `檢查 peero.org1.com log`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs -f peer0.org1.com
>>>> ```
>
>>>> `System Response:`
>
>>>> ```log
>>>> 2023-11-11 09:37:57.473 UTC [gossip.gossip] JoinChan -> INFO 01b Joining gossip network of channel channel1 with 2 organizations
>>>> 2023-11-11 09:37:57.473 UTC [gossip.gossip] learnAnchorPeers -> INFO 01c No configured anchor peers of Org1MSP for channel channel1 to learn about
>>>> 2023-11-11 09:37:57.473 UTC [gossip.gossip] learnAnchorPeers -> INFO 01d No configured anchor peers of Org2MSP for channel channel1 to learn about
>>>> ```
>
>
>
>> 5. Org2 join channel
>
>>> **工作目錄: $HOME/workspaces/fabric-lab/workdir/org2-client**
>>> 1 啟始環境部署配置
>>> 執行 $HOME/workspaces/fabric-lab/workdir/org2-client/scripts/init.sh
>
>>>> 1. 複製執行角色的身份識別文件 (MSP/TLS) 到對映位置，
>>>> 2. 複製每一參與機構的 TLS root CA 到對應位置
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org2-client
>>>> ./scripts/init.sh
>>>> ```
>
>
>>> 2. 初始化環境變數
>
>

>>>> 1. 設定 MSPID, 操作的節點, 操作的角色 (admin or client) 以及 ORDERER_TLS_CA 的位置
>
>>>> `[設定檔內容]`
>
>>>> ```script
>>>> export MSP=Org2MSP
>>>> export HOST=$1
>>>> export DOMAIN=org2.com
>>>> export PORT=$2
>>>> export CORE_PEER_TLS_ENABLED=true
>>>> export CORE_PEER_LOCALMSPID=$MSP
>>>> export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/users/Admin@$DOMAIN/tls/ca.crt
>>>> export CORE_PEER_MSPCONFIGPATH=${PWD}/users/Admin@$DOMAIN/msp
>>>> # export CORE_PEER_TLS_CLIENTAUTHREQUIRED=true
>>>> # export CORE_PEER_TLS_CLIENTCERT_FILE=${PWD}/users/Admin@$DOMAIN/tls/client.crt
>>>> # export CORE_PEER_TLS_CLIENTKEY_FILE=${PWD}/users/Admin@$DOMAIN/tls/client.key
>>>> export CORE_PEER_ADDRESS=$HOST.$DOMAIN:$PORT
>>>> export FABRIC_CFG_PATH=$GOPATH/config
>>>> export ORDERER_TLS_CA=$PWD/tlsca/tlsca.org4.com-cert.pem
>>>> ```
>
>
>>> 2. 初始化身 Admin@org2.com 的身份
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> source admin.env peer0 2051
>>>> ```
>
>
>>> 3. Fetching channel1 config block
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org2-client/tmp
>>>> peer channel fetch config -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>>> ```
>
>>>> `System response:`
>
>>>> ```bash
>>>> 2023-11-11 09:58:37.371 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 09:58:37.372 UTC [cli.common] readBlock -> INFO 002 Received block: 0
>>>> 2023-11-11 09:58:37.373 UTC [channelCmd] fetch -> INFO 003 Retrieving last config block: 0
>>>> 2023-11-11 09:58:37.373 UTC [cli.common] readBlock -> INFO 004 Received block: 0
>>>> ```
>
>
>>> 4. Join channel
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> ls
>>>> ```
>
>>>> `System response:`
>
>>>> ```bash
>>>> channel1_config.block
>>>> ```
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer channel join -b channel1_config.block 
>>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-11 10:05:50.089 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 10:05:50.151 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
>>>> ```
>
>>>> `檢查 peer0.org2.com docker log`
>
>>>> ***`[command]`***
>
>>>> ```docker
>>>> docker logs -f peer0.org2.com
>>>> ```
>
>>>> ```log
>>>> 2023-11-11 10:05:50.093 UTC [ledgermgmt] CreateLedger -> INFO 01f Creating ledger [channel1] with genesis block
>>>> 2023-11-11 10:05:50.095 UTC [blkstorage] newBlockfileMgr -> INFO 020 Getting block information from block storage
>>>> 2023-11-11 10:05:50.108 UTC [couchdb] createDatabaseIfNotExist -> INFO 021 Created state database channel1_
>>>> 2023-11-11 10:05:50.126 UTC [couchdb] createDatabaseIfNotExist -> INFO 022 Created state database channel1__lifecycle
>>>> 2023-11-11 10:05:50.147 UTC [kvledger] CommitLegacy -> INFO 023 [channel1] Committed block [0] with 1 transaction(s) in 16ms (state_validation=0ms block_and_pvtdata_commit=2ms state_commit=12ms) commitHash=[]
>>>> 2023-11-11 10:05:50.147 UTC [ledgermgmt] CreateLedger -> INFO 024 Created ledger [channel1] with genesis block
>>>> 2023-11-11 10:05:50.150 UTC [peer.orderers] Update -> WARN 025 Config defines both orderer org specific endpoints and global endpoints, global endpoints will be ignored channel=channel1
>>>> 2023-11-11 10:05:50.150 UTC [gossip.gossip] JoinChan -> INFO 026 Joining gossip network of channel channel1 with 2 organizations
>>>> 2023-11-11 10:05:50.150 UTC [gossip.gossip] learnAnchorPeers -> INFO 027 No configured anchor peers of Org1MSP for channel channel1 to learn about
>>>> 2023-11-11 10:05:50.150 UTC [gossip.gossip] learnAnchorPeers -> INFO 028 No configured anchor peers of Org2MSP for channel channel1 to learn about
>>>> 2023-11-11 10:05:50.151 UTC [gossip.state] NewGossipStateProvider -> INFO 029 Updating metadata information for channel channel1, current ledger sequence is at = 0, next expected block is = 1
>>>> 2023-11-11 10:05:50.151 UTC [deliveryClient] StartDeliverForChannel -> INFO 02a This peer will retrieve blocks from ordering service and disseminate to other peers in the organization channel=channel1
>>>> 2023-11-11 10:05:50.151 UTC [endorser] callChaincode -> INFO 02b finished chaincode: cscc duration: 59ms channel= txID=d196f1bb
>>>> ```
>
>
>
>> 6. Set Anchor Peer
>
>>> 1. 設定 peer0.org2.com 為 org2.com 的 anchor Peer
>>>    **工作目錄: $HOME/workspaces/fabric-lab/workdir/org2-client**
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/org2-client
>>> source admin.env peer0 2051
>>> ```
>
>>> 操作 anchor peer 的設定會有許多檔案產生，所以將在 $HOME/workspaces/fabric-lab/workdir/org2-client/tmp 目錄操作
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/org2-client/tmp
>>> ../scripts/setAnchorPeer.sh channel1
>>> ```
>
>>> `System response:`
>
>>>> ```log
>>>> 2023-11-11 10:38:44.922 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 10:38:44.924 UTC [cli.common] readBlock -> INFO 002 Received block: 0
>>>> 2023-11-11 10:38:44.924 UTC [channelCmd] fetch -> INFO 003 Retrieving last config block: 0
>>>> 2023-11-11 10:38:44.924 UTC [cli.common] readBlock -> INFO 004 Received block: 0
>>>> 2023-11-11 10:38:45.006 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 10:38:45.012 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
>>>> ```
>
>
>>> `檢查 channel1 的config block`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> rm -rf *
>>>> peer channel fetch config -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>>> ```
>
>
>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-11 10:42:32.772 UTC [cli.common] readBlock -> INFO 002 Received block: 1
>>>> 2023-11-11 10:42:32.772 UTC [channelCmd] fetch -> INFO 003 Retrieving last config block: 1
>>>> 2023-11-11 10:42:32.773 UTC [cli.common] readBlock -> INFO 004 Received block: 1
>>>> ```
>
>
>>> `將 protobuf 的格式轉換成 json`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> configtxlator proto_decode --input channel1_config.block --type common.Block|jq .data.data[].payload.data.config > chonfig.json
>>>> ```
>
>
>>> 檢查  `config.json` 是否在 Org2 加入 anchor peer:
>
>>>> `[設定檔內容]`
>
>>>> ```json
>>>> "AnchorPeers": {
>>>> "mod_policy": "Admins",
>>>> "value": {
>>>>  "anchor_peers": [
>>>>    {
>>>>      "host": "peer0.org2.com",
>>>>      "port": 2051
>>>>    }
>>>>  ]
>>>> },
>>>> "version": "0"
>>>> },
>>>> ```
>
>
>>> `檢查 peer0.org1.com log`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs -f peer0.org1.com
>>>> ```
>
>
>>> `System response:`
>
>>>> ```bash
>>>> 2023-11-11 10:38:45.022 UTC [gossip.privdata] StoreBlock -> INFO 029 Received block [1] from buffer channel=channel1
>>>> 2023-11-11 10:38:45.024 UTC [peer.orderers] Update -> WARN 02a Config defines both orderer org specific endpoints and global endpoints, global endpoints will be ignored channel=channel1
>>>> 2023-11-11 10:38:45.024 UTC [gossip.gossip] JoinChan -> INFO 02b Joining gossip network of channel channel1 with 2 organizations
>>>> 2023-11-11 10:38:45.024 UTC [gossip.gossip] learnAnchorPeers -> INFO 02c No configured anchor peers of Org1MSP for channel channel1 to learn about
>>>> 2023-11-11 10:38:45.024 UTC [gossip.gossip] learnAnchorPeers -> INFO 02d Learning about the configured anchor peers of Org2MSP for channel channel1: [{peer0.org2.com 2051}]
>>>> 2023-11-11 10:38:45.025 UTC [committer.txvalidator] Validate -> INFO 02e [channel1] Validated block [1] in 2ms
>>>> 2023-11-11 10:38:45.042 UTC [kvledger] CommitLegacy -> INFO 02f [channel1] Committed block [1] with 1 transaction(s) in 17ms (state_validation=0ms block_and_pvtdata_commit=2ms state_commit=14ms) commitHash=[47dc540c94ceb704a23875c11273e16bb0b8a87aed84de911f2133568115f254]
>>>> 2023-11-11 10:38:47.474 UTC [gossip.channel] reportMembershipChanges -> INFO 030 [[channel1] Membership view has changed. peers went online:  [[peer0.org2.com:2051 ]] , current view:  [[peer0.org2.com:2051 ]]]
>>>> ```
>
>
>>> `檢查 peer0.org2.com log`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs -f peer0.org2.com
>>>> ```
>
>
>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-11 10:38:45.022 UTC [gossip.privdata] StoreBlock -> INFO 02e Received block [1] from buffer channel=channel1
>>>> 2023-11-11 10:38:45.025 UTC [peer.orderers] Update -> WARN 02f Config defines both orderer org specific endpoints and global endpoints, global endpoints will be ignored channel=channel1
>>>> 2023-11-11 10:38:45.025 UTC [gossip.gossip] JoinChan -> INFO 030 Joining gossip network of channel channel1 with 2 organizations
>>>> 2023-11-11 10:38:45.025 UTC [gossip.gossip] learnAnchorPeers -> INFO 031 Learning about the configured anchor peers of Org2MSP for channel channel1: [{peer0.org2.com 2051}]
>>>> 2023-11-11 10:38:45.025 UTC [gossip.gossip] learnAnchorPeers -> INFO 032 Anchor peer for channel channel1 with same endpoint, skipping connecting to myself
>>>> 2023-11-11 10:38:45.025 UTC [gossip.gossip] learnAnchorPeers -> INFO 033 No configured anchor peers of Org1MSP for channel channel1 to learn about
>>>> 2023-11-11 10:38:45.025 UTC [committer.txvalidator] Validate -> INFO 034 [channel1] Validated block [1] in 2ms
>>>> 2023-11-11 10:38:45.026 UTC [comm.grpc.server] 1 -> INFO 035 unary call completed grpc.service=gossip.Gossip grpc.method=Ping grpc.request_deadline=2023-11-11T10:38:47.026Z grpc.peer_address=172.23.0.10:52044 grpc.peer_subject="CN=peer0.org1.com,OU=client,O=org1.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=51.035µs
>>>> 2023-11-11 10:38:45.027 UTC [gossip.comm] GossipStream -> INFO 036 Peer d413108aec9c8f11a3a6014382dc5eba8930756bf48297736c46f095581a4f3e (172.23.0.10:52044) probed us
>>>> 2023-11-11 10:38:45.027 UTC [comm.grpc.server] 1 -> INFO 037 streaming call completed grpc.service=gossip.Gossip grpc.method=GossipStream grpc.request_deadline=2023-11-11T10:38:55.026Z grpc.peer_address=172.23.0.10:52044 grpc.peer_subject="CN=peer0.org1.com,OU=client,O=org1.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=704.384µs
>>>> 2023-11-11 10:38:45.030 UTC [comm.grpc.server] 1 -> INFO 038 unary call completed grpc.service=gossip.Gossip grpc.method=Ping grpc.request_deadline=2023-11-11T10:38:47.03Z grpc.peer_address=172.23.0.10:52058 grpc.peer_subject="CN=peer0.org1.com,OU=client,O=org1.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=47.012µs
>>>> 2023-11-11 10:38:45.040 UTC [kvledger] CommitLegacy -> INFO 039 [channel1] Committed block [1] with 1 transaction(s) in 15ms (state_validation=0ms block_and_pvtdata_commit=3ms state_commit=11ms) commitHash=[47dc540c94ceb704a23875c11273e16bb0b8a87aed84de911f2133568115f254]
>>>> 2023-11-11 10:38:50.151 UTC [gossip.channel] reportMembershipChanges -> INFO 03a [[channel1] Membership view has changed. peers went online:  [[peer0.org1.com:1051 ]] , current view:  [[peer0.org1.com:1051 ]]]
>>>> ```
>
>
>
>>> 2. 設定 peer0.org1.com 為 org1.com 的 anchor Peer
>>>    **工作目錄: $HOME/workspaces/fabric-lab/workdir/org1-client**
>
>>>> ***`[command]`***
>
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/org1-client
>>> source admin.env peer0 1051
>>> ```
>
>>> 操作 anchor peer 的設定會有許多檔案產生，所以將在 $HOME/workspaces/fabric-lab/workdir/or12-client/tmp 目錄操作
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org1-client/tmp
>>>> ../scripts/setAnchorPeer.sh channel1
>>>> ```
>
>
>>> `System response:`
>
>>>> ```bash
>>>> 2023-11-11 11:12:40.595 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 11:12:40.597 UTC [cli.common] readBlock -> INFO 002 Received block: 1
>>>> 2023-11-11 11:12:40.597 UTC [channelCmd] fetch -> INFO 003 Retrieving last config block: 1
>>>> 2023-11-11 11:12:40.597 UTC [cli.common] readBlock -> INFO 004 Received block: 1
>>>> 2023-11-11 11:12:40.681 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 11:12:40.687 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
>>>> ```
>
>
>>> `檢查 channel1 的config block`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> rm -rf *
>>>> peer channel fetch config -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>>> ```
>
>
>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-11 11:22:19.722 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>>>> 2023-11-11 11:22:19.724 UTC [cli.common] readBlock -> INFO 002 Received block: 2
>>>> 2023-11-11 11:22:19.724 UTC [channelCmd] fetch -> INFO 003 Retrieving last config block: 2
>>>> 2023-11-11 11:22:19.724 UTC [cli.common] readBlock -> INFO 004 Received block: 2
>>>> ```
>
>
>>> `將 protobuf 的格式轉換成 json`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> configtxlator proto_decode --input channel1_config.block --type common.Block|jq .data.data[].payload.data.config > chonfig.json
>>>> ```
>
>
>>> 檢查  `config.json` 是否在 Org1 加入 anchor peer:
>
>>>> `[設定檔內容]`
>
>>>> ```json
>>>> "AnchorPeers": {
>>>> "mod_policy": "Admins",
>>>> "value": {
>>>>  "anchor_peers": [
>>>>    {
>>>>      "host": "peer0.org1.com",
>>>>      "port": 1051
>>>>    }
>>>>  ]
>>>> },
>>>> "version": "0"
>>>> },
>>>> ```
>
>
>>> `檢查 peer0.org1.com log`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs -f peer0.org1.com
>>>> ```
>
>
>>> `System response:`
>
>>>> ```bash
>>>> 2023-11-11 11:12:40.697 UTC [gossip.privdata] StoreBlock -> INFO 031 Received block [2] from buffer channel=channel1
>>>> 2023-11-11 11:12:40.699 UTC [peer.orderers] Update -> WARN 032 Config defines both orderer org specific endpoints and global endpoints, global endpoints will be ignored channel=channel1
>>>> 2023-11-11 11:12:40.699 UTC [gossip.gossip] JoinChan -> INFO 033 Joining gossip network of channel channel1 with 2 organizations
>>>> 2023-11-11 11:12:40.699 UTC [gossip.gossip] learnAnchorPeers -> INFO 034 Learning about the configured anchor peers of Org2MSP for channel channel1: [{peer0.org2.com 2051}]
>>>> 2023-11-11 11:12:40.699 UTC [gossip.gossip] learnAnchorPeers -> INFO 035 Learning about the configured anchor peers of Org1MSP for channel channel1: [{peer0.org1.com 1051}]
>>>> 2023-11-11 11:12:40.699 UTC [gossip.gossip] learnAnchorPeers -> INFO 036 Anchor peer for channel channel1 with same endpoint, skipping connecting to myself
>>>> 2023-11-11 11:12:40.699 UTC [committer.txvalidator] Validate -> INFO 037 [channel1] Validated block [2] in 2ms
>>>> 2023-11-11 11:12:40.702 UTC [comm.grpc.server] 1 -> INFO 038 unary call completed grpc.service=gossip.Gossip grpc.method=Ping grpc.request_deadline=2023-11-11T11:12:42.702Z grpc.peer_address=172.23.0.11:53462 grpc.peer_subject="CN=peer0.org2.com,OU=client,O=org2.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=41.509µs
>>>> 2023-11-11 11:12:40.703 UTC [gossip.comm] GossipStream -> INFO 039 Peer 27e4eaf07a743b76a4f6d7345defed972dc2a0ebce508eb795e581d5e39684d4 (172.23.0.11:53462) probed us
>>>> 2023-11-11 11:12:40.703 UTC [comm.grpc.server] 1 -> INFO 03a streaming call completed grpc.service=gossip.Gossip grpc.method=GossipStream grpc.request_deadline=2023-11-11T11:12:50.702Z grpc.peer_address=172.23.0.11:53462 grpc.peer_subject="CN=peer0.org2.com,OU=client,O=org2.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=416.791µs
>>>> 2023-11-11 11:12:40.720 UTC [kvledger] CommitLegacy -> INFO 03b [channel1] Committed block [2] with 1 transaction(s) in 20ms (state_validation=0ms block_and_pvtdata_commit=4ms state_commit=14ms) commitHash=[5f88b61407b149a48413433f4670c46531e5c4a8febdc339a9536ff8716a559e]
>>>> ```
>
>
>>> `檢查 peer0.org2.com log`
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs -f peer0.org2.com
>>>> ```
>
>
>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-11 11:12:40.698 UTC [gossip.privdata] StoreBlock -> INFO 03b Received block [2] from buffer channel=channel1
>>>> 2023-11-11 11:12:40.700 UTC [peer.orderers] Update -> WARN 03c Config defines both orderer org specific endpoints and global endpoints, global endpoints will be ignored channel=channel1
>>>> 2023-11-11 11:12:40.700 UTC [gossip.gossip] JoinChan -> INFO 03d Joining gossip network of channel channel1 with 2 organizations
>>>> 2023-11-11 11:12:40.700 UTC [gossip.gossip] learnAnchorPeers -> INFO 03e Learning about the configured anchor peers of Org2MSP for channel channel1: [{peer0.org2.com 2051}]
>>>> 2023-11-11 11:12:40.700 UTC [gossip.gossip] learnAnchorPeers -> INFO 03f Anchor peer for channel channel1 with same endpoint, skipping connecting to myself
>>>> 2023-11-11 11:12:40.700 UTC [gossip.gossip] learnAnchorPeers -> INFO 040 Learning about the configured anchor peers of Org1MSP for channel channel1: [{peer0.org1.com 1051}]
>>>> 2023-11-11 11:12:40.700 UTC [committer.txvalidator] Validate -> INFO 041 [channel1] Validated block [2] in 2ms
>>>> 2023-11-11 11:12:40.701 UTC [comm.grpc.server] 1 -> INFO 042 unary call completed grpc.service=gossip.Gossip grpc.method=Ping grpc.request_deadline=2023-11-11T11:12:42.701Z grpc.peer_address=172.23.0.10:54994 grpc.peer_subject="CN=peer0.org1.com,OU=client,O=org1.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=44.483µs
>>>> 2023-11-11 11:12:40.702 UTC [gossip.comm] GossipStream -> INFO 043 Peer d413108aec9c8f11a3a6014382dc5eba8930756bf48297736c46f095581a4f3e (172.23.0.10:54994) probed us
>>>> 2023-11-11 11:12:40.702 UTC [comm.grpc.server] 1 -> INFO 044 streaming call completed grpc.service=gossip.Gossip grpc.method=GossipStream grpc.request_deadline=2023-11-11T11:12:50.701Z grpc.peer_address=172.23.0.10:54994 grpc.peer_subject="CN=peer0.org1.com,OU=client,O=org1.com,ST=Taiwan,C=TW" grpc.code=OK grpc.call_duration=1.205016ms
>>>> 2023-11-11 11:12:40.720 UTC [kvledger] CommitLegacy -> INFO 045 [channel1] Committed block [2] with 1 transaction(s) in 20ms (state_validation=0ms block_and_pvtdata_commit=4ms state_commit=14ms) commitHash=[5f88b61407b149a48413433f4670c46531e5c4a8febdc339a9536ff8716a559e]
>>>> ```
>
### 13. Deploy chaincode

1. 準備 chaincode source code

> 1. asset-transfer-basic 目錄位置: $HOME/workspaces/fabric-lab/workdir/chaincode/asset-transfer-basic/chaincode-go
> 2. 下載 Go chaincode 的相依套件 (dependency package)
>
>> 1. go mod tidy
>
>> ***`[command]`***
>
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/chaincode/asset-transfer-basic/chaincode-go
>> go mod tidy
>> ```
>
>> 2. go mod vendor
>
>> ***`[command]`***
>
>> ```bash
>> go mod vendor
>> ```
>
>> 3. 檢查 $PWD/vendor 目錄內容
>
>>> ***`[command]`***
>
>>> ```bash
>>> tree -d vendor
>>> ```
>
>>> `System Response`
>
>>> ```bash
>>> vendor/
>>> ├── github.com
>>> │   ├── PuerkitoBio
>>> │   │   ├── purell
>>> │   │   └── urlesc
>>> │   ├── davecgh
>>> │   │   └── go-spew
>>> │   │       └── spew
>>> │   ├── go-openapi
>>> │   │   ├── jsonpointer
>>> │   │   ├── jsonreference
>>> │   │   ├── spec
>>> │   │   └── swag
>>> │   ├── gobuffalo
>>> │   │   ├── envy
>>> │   │   ├── packd
>>> │   │   │   └── internal
>>> │   │   │       └── takeon
>>> │   │   │           └── github.com
>>> │   │   │               └── markbates
>>> │   │   │                   └── errx
>>> │   │   └── packr
>>> │   ├── golang
>>> │   │   └── protobuf
>>> │   │       ├── proto
>>> │   │       └── ptypes
>>> │   │           ├── any
>>> │   │           ├── duration
>>> │   │           ├── empty
>>> │   │           └── timestamp
>>> │   ├── hyperledger
>>> │   │   ├── fabric-chaincode-go
>>> │   │   │   ├── pkg
>>> │   │   │   │   ├── attrmgr
>>> │   │   │   │   └── cid
>>> │   │   │   └── shim
>>> │   │   │       └── internal
>>> │   │   ├── fabric-contract-api-go
>>> │   │   │   ├── contractapi
>>> │   │   │   │   └── utils
>>> │   │   │   ├── internal
>>> │   │   │   │   ├── types
>>> │   │   │   │   └── utils
>>> │   │   │   ├── metadata
>>> │   │   │   └── serializer
>>> │   │   └── fabric-protos-go
>>> │   │       ├── common
>>> │   │       ├── ledger
>>> │   │       │   ├── queryresult
>>> │   │       │   └── rwset
>>> │   │       ├── msp
>>> │   │       └── peer
>>> │   ├── joho
>>> │   │   └── godotenv
>>> │   ├── mailru
>>> │   │   └── easyjson
>>> │   │       ├── buffer
>>> │   │       ├── jlexer
>>> │   │       └── jwriter
>>> │   ├── pmezard
>>> │   │   └── go-difflib
>>> │   │       └── difflib
>>> │   ├── rogpeppe
>>> │   │   └── go-internal
>>> │   │       ├── modfile
>>> │   │       ├── module
>>> │   │       └── semver
>>> │   ├── stretchr
>>> │   │   └── testify
>>> │   │       ├── assert
>>> │   │       └── require
>>> │   └── xeipuuv
>>> │       ├── gojsonpointer
>>> │       ├── gojsonreference
>>> │       └── gojsonschema
>>> ├── golang.org
>>> │   └── x
>>> │       ├── net
>>> │       │   ├── http
>>> │       │   │   └── httpguts
>>> │       │   ├── http2
>>> │       │   │   └── hpack
>>> │       │   ├── idna
>>> │       │   ├── internal
>>> │       │   │   └── timeseries
>>> │       │   └── trace
>>> │       ├── sys
>>> │       │   └── unix
>>> │       └── text
>>> │           ├── secure
>>> │           │   └── bidirule
>>> │           ├── transform
>>> │           ├── unicode
>>> │           │   ├── bidi
>>> │           │   └── norm
>>> │           └── width
>>> ├── google.golang.org
>>> │   ├── genproto
>>> │   │   └── googleapis
>>> │   │       └── rpc
>>> │   │           └── status
>>> │   └── grpc
>>> │       ├── balancer
>>> │       │   ├── base
>>> │       │   └── roundrobin
>>> │       ├── binarylog
>>> │       │   └── grpc_binarylog_v1
>>> │       ├── codes
>>> │       ├── connectivity
>>> │       ├── credentials
>>> │       │   └── internal
>>> │       ├── encoding
>>> │       │   └── proto
>>> │       ├── grpclog
>>> │       ├── internal
>>> │       │   ├── backoff
>>> │       │   ├── balancerload
>>> │       │   ├── binarylog
>>> │       │   ├── channelz
>>> │       │   ├── envconfig
>>> │       │   ├── grpcrand
>>> │       │   ├── grpcsync
>>> │       │   ├── syscall
>>> │       │   └── transport
>>> │       ├── keepalive
>>> │       ├── metadata
>>> │       ├── naming
>>> │       ├── peer
>>> │       ├── resolver
>>> │       │   ├── dns
>>> │       │   └── passthrough
>>> │       ├── serviceconfig
>>> │       ├── stats
>>> │       ├── status
>>> │       └── tap
>>> └── gopkg.in
>>>  └── yaml.v2
>>> ```
>
>
>> 4. org1.com 部署 chaincode
>
>> ***`工作目錄： $HOME/workspaces/fabric-lab/workdir/org1-client`***
>
>> ***`[command]`***
>
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/org1-client
>> source admin.env peer0 1051
>> ```
>
>> 切換工作目錄到 $HOME/workspaces/fabric-lab/workdir/org1-client/tmp
>
>> ***`[command]`***
>
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/org1-client/tmp
>> ```
>
>>> 1. package chaincode
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer lifecycle chaincode package basic.tar.gz --path ../../chaincode/asset-transfer-basic/chaincode-go/ --lang golang --label basic_1.0
>>>> ```
>
>>> 2. install chaincode
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer lifecycle chaincode install basic.tar.gz 
>>>> ```
>
>>>> `System Response`
>
>>>> ```bash
>>>> 2023-11-12 03:20:52.617 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJbasic_1.0:cada8480a2f0cafe5acc135e17803f622780a350d438d2bf67383a4ebd92d172\022\tbasic_1.0" > 
>>>> 2023-11-12 03:20:52.617 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: basic_1.0:cada8480a2f0cafe5acc135e17803f622780a350d438d2bf67383a4ebd92d172
>>>> ```
>
>>>> 1. 在完成 lifecycle chaincode install 後，檢查 `$HOME/workspaces/fabric-lab/service/peers/org1.com/peer0-data/lifecycle/ ***`[command]`***
>
>>>> ```bash
>>>> sudo tree $HOME//workspaces/fabric-lab/service/peers/org1.com/peer0.org1.com/peer0-data/lifecycle/
>>>> ```
>
>>>> `System Response`
>
>>>> ```bash
>>>> $HOME/workspaces/fabric-lab/service/peers/org1.com/peer0.org1.com/peer0-data/lifecycle/
>>>> └── chaincodes
>>>>  └── basic_1.0.cada8480a2f0cafe5acc135e17803f622780a350d438d2bf67383a4ebd92d172.tar.gz
>>>> ```
>
>>>> 2. 檢查 peer0.org1.com 的 docker logs
>
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> docker logs peer0.org1.com
>>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-12 03:20:52.617 UTC [lifecycle] InstallChaincode -> INFO 03c Successfully installed chaincode with package ID 'basic_1.0:cada8480a2f0cafe5acc135e17803f622780a350d438d2bf67383a4ebd92d172'
>>>> 2023-11-12 03:20:52.617 UTC [endorser] callChaincode -> INFO 03d finished chaincode: _lifecycle duration: 19627ms channel= txID=e6cdca84
>>>> 2023-11-12 03:20:52.617 UTC [comm.grpc.server] 1 -> INFO 03e unary call completed grpc.service=protos.Endorser grpc.method=ProcessProposal grpc.peer_address=192.168.2.201:56082 grpc.code=OK grpc.call_duration=19.639528404s
>>>> ```
>
>
>>> 3. 執行 `peer lifecycle chaincode queryinstalled` 取得 chaincode 的 package id
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled -O json | jq -r '.installed_chaincodes[] | select(.label=="basic_1.0").package_id')
>>>> ```
>
>>>> 檢查自定環境變數 CC_PACKAGE_ID 的數值
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> echo $CC_PACKAGE_ID
>>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> basic_1.0:cada8480a2f0cafe5acc135e17803f622780a350d438d2bf67383a4ebd92d172
>>>> ```
>
>
>>> 3. Approve chaincode
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer lifecycle chaincode approveformyorg -C channel1 -n basic --version 1.0 --sequence 1 --orderer orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA --package-id $CC_PACKAGE_ID
>>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-12 03:59:12.313 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [43ac023332b22820f489d2abd17e24498605c96da1636d07067215d808b2739d] committed with status (VALID) at peer0.org1.com:1051
>>>> ```
>
>
>>> 4. 檢查提交準備狀況 (chack commit readiness)
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer lifecycle chaincode checkcommitreadiness -C channel1  -n basic --version 1.0 --sequence 1 --orderer orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> Chaincode definition for chaincode 'basic', version '1.0', sequence '1' on >>>> channel 'channel1' approval status by org:
>>>> Org1MSP: true
>>>> Org2MSP: false
>>>> ```
>
>>>> 未滿足 Lifecycle Endorsement (在  configtx.yaml 中定義 lifecycle endorsement 的Policy 是 MAJORITY)，目前只有一個 Organization approve，所以要等 org2.com approve 後才能  commit (提交)
>
>
>>> 5. org2.com 部署 chaincode
>>>    ***`工作目錄: $HOME/workspaces/fabric-lab/workdir/org2-client`***
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org2-client
>>>> source admin.env peer0 2051
>>>> ```
>
>
>>> 切換工作目錄 $HOME/workspaces/fabric-lab/workdor/org2-client/tmp
>
>>>> ***`[command]`***
>
>>>> 1. package chaincode
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> cd $HOME/workspaces/fabric-lab/workdir/org1-client/tmp
>>>> peer lifecycle chaincode package basic.tar.gz --path ../../chaincode/asset-transfer-basic/chaincode-go/ --lang golang --label basic_1.0
>>>> ```
>
>>>> 2. install package
>
>>>> ***`[command]`***
>
>>>> ```bash
>>>> peer lifecycle chaincode install basic.tar.gz
>>>> ```
>
>>>> `System Response:`
>
>>>> ```bash
>>>> 2023-11-12 06:57:59.397 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJbasic_1.0:1f4749caf72871f38e43a65861a31f1708c541d306143287ecbfe068fa7dd5bb\022\tbasic_1.0" > 
>>>> 2023-11-12 06:57:59.397 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: basic_1.0:1f4749caf72871f38e43a65861a31f1708c541d306143287ecbfe068fa7dd5bb
>>>>>>>> ```
>
>>>>> 1. 在完成 lifecycle chaincode install 後，檢查 $HOME/workspaces/fabric-lab/service/peers/org1.com/peer0-data/lifecycle/
>
>>>>> ***`[command]`***
>>>>> ```bash
>>>>> sudo tree $HOME//workspaces/fabric-lab/service/peers/org2.com/peer0.org2.com/peer0-data/lifecycle/
>>>>> ```
>>>>> `System Response:`
>>>>> ```bash
>>>>> $HOME/workspaces/fabric-lab/service/peers/org2.com/peer0.org2.com/peer0-data/lifecycle/
>>>>> └── chaincodes
>>>>>  └── basic_1.0.1f4749caf72871f38e43a65861a31f1708c541d306143287ecbfe068fa7dd5bb.tar.gz
>>>>> ```
>>>>
>>>>```
>
>
>>>>> 2. 檢查 peer0.org2.com 的 docker logs
>
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> docker logs -f peer0.org2.com
>>>>> ```
>
>>>>> `System Response:`
>
>>>>> ```bash
>>>>> 2023-11-12 06:57:59.396 UTC [lifecycle] InstallChaincode -> INFO 04b Successfully installed chaincode with package ID 'basic_1.0:1f4749caf72871f38e43a65861a31f1708c541d306143287ecbfe068fa7dd5bb'
>>>>> 2023-11-12 06:57:59.396 UTC [endorser] callChaincode -> INFO 04c finished chaincode: _lifecycle duration: 6688ms channel= txID=3abd53e6
>>>>> 2023-11-12 06:57:59.396 UTC [comm.grpc.server] 1 -> INFO 04d unary call completed grpc.service=protos.Endorser grpc.method=ProcessProposal grpc.peer_address=192.168.2.201:49782 grpc.code=OK grpc.call_duration=6.701520868s
>>>>> ```
>
>
>>>> 3. 執行 peer lifecycle chaincode queryinstalled 取得 chaincode 的 package id
>
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled -O json | jq -r '.installed_chaincodes[] | select(.label=="basic_1.0").package_id')
>>>>> ```
>
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> echo $CC_PACKAGE_ID 
>>>>> ```
>
>>>>> `System Response:`
>
>>>>> ```bash
>>>>> basic_1.0:1f4749caf72871f38e43a65861a31f1708c541d306143287ecbfe068fa7dd5bb
>>>>> ```
>
>
>>>> 4. Approve chaincode
>
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> peer lifecycle chaincode approveformyorg -C channel1 -n basic --version 1.0 --sequence 1 --orderer orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA --package-id $CC_PACKAGE_ID
>>>>> ```
>
>>>>> `System Response:`
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> 2023-11-12 07:19:56.483 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [f28e5b78e6e249288807b9fc4dbada61761abd1103a328a466eaf184ea49458d] committed with status (VALID) at peer0.org2.com:2051
>>>>> ```
>
>
>>>> 5. 檢查提交準備狀況 (chack commit readiness)
>
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> peer lifecycle chaincode checkcommitreadiness -C channel1  -n basic --version 1.0 --sequence 1 --orderer orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>>>> ```
>
>>>>> `System Response:`
>
>>>>> ```bash
>>>>> Chaincode definition for chaincode 'basic', version '1.0', sequence '1' on channel 'channel1' approval status by org:
>>>>> Org1MSP: true
>>>>> Org2MSP: true
>>>>> ```
>
>
>>>> 已達到 過半數的參與機構同意，執行 commit 提交到 orderer
>
>>>>> ***`[command]`***
>
>>>>> ```bash
>>>>> peer lifecycle chaincode commit -C channel1  -n basic --version 1.0 --sequence 1 --orderer orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA --peerAddresses peer0.org1.com:1051 --tlsRootCertFiles $PWD/../tlsca/tlsca.org1.com-cert.pem --peerAddresses peer0.org2.com:2051 --tlsRootCertFiles $PWD/../tlsca/tlsca.org2.com-cert.pem
>>>>> ```
>
>>>>> `System Response:`
>
>>>>> ```bash
>>>>> 2023-11-12 08:07:30.685 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [477baa7dee7a66b272367c8af4b6a4859c95c13ab62c242b2f2de38fca7c7b4a] committed with status (VALID) at peer0.org2.com:2051
>>>>> 2023-11-12 08:07:30.689 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [477baa7dee7a66b272367c8af4b6a4859c95c13ab62c242b2f2de38fca7c7b4a] committed with status (VALID) at peer0.org1.com:1051
>>>>> ```
>
### 14. 與 channel1 互動

### 15. 加入新 Organization (Org3MSP, org3.com) 到現有的 Application Channel

> 操作步驟:
>
> 1. 生成 org3 加密文件
>
>> 1. 啟動 docker-compose.yaml
>> 2. 登錄以及註冊 org3.com 的 MSP, TLS 加密文件
>> 3. 複製 channelMSP/peerOrganizations/org3/com 到 config/organizations/peerOrganizations/org3.com
>
>
> 2. 產生新機構 (Org3MSP) 的機構文件 (org3.json)
> 3. 由 channel 原有的成員機構取得 channel config block (config_block.pb)
> 4. 執行 update config 程序
>
>> 1. 將 config_block.pb 轉換成 json 文件 (config_block.json)
>> 2. 由 config_block.json 擷取生成 config 內容 (config.json)
>> 3. 將 org3.json 文件加到 config.json 中，產生 config_modified.json
>> 4. 將 config.json 轉換成 pb 檔案格式 (config.pb)
>> 5. 將 config_modified.json 轉換成 pb 檔案格式 (config_modified.pb)
>> 6. 將 original (config.pb) 與 updated (config_modified.pb) 計算更新差異 (config_update.pb)
>> 7. 將 config_update.pb 轉換成 json 檔案格式 (config_update.json)
>> 8. 將 config_update.json 加上 "信封" (envelope) 成為 config_update_in_envelope.json
>> 9. config_update_in_envelope.json 轉換成　pb 檔案格式
>
>
> 5. 執行 peer channel signconfigtx, 簽章、背書
> 6. 提交給其他機構執行簽章背書，當達到 Channel Admin Policy (MAJORITY)，提交到 orderer 節點

實作:

> 1. 生成 org3 加密文件
>
>> 1. 啟動 org3.com 的 ca.org3.com, tls.org3.com 的 docker instances
>
>>    請參考 6. 啟動 fabric-ca-server
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/ca
>>> docker-compose -f docker-compose-org3.yaml up -d
>>> ```
>
>
>> 2. 登錄以及註冊 org3.com 的 MSP, TLS 加密文件
>
>>    請參閱 7. 登錄以及註冊所有加密材料說明
>
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/ca/msp
>>> cp ../msp-template/peer.json org3.json
>>> ```
>
>>> 1. 修改org3.json
>
>>>> 1. org1 -> org3
>>>> 2. 1054 -> 3054, 1154 -> 3154
>>>> 3. caServer.secret 必須與 前一步驟中的 config/org3.com/ca/fabric-ca-server-config.yaml 的 pass 相同
>>>> 4. tlsServer.secret 必須與 前一步驟中的 config/org3.com/tls/fabric-ca-server-config.yaml 的 pass 相同
>
>
>>> ```bash
>>> ../scripts/networkgen.sh -t organizations.json -p org3.json -O ../org3.json
>>> ```
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/ca
>>> ./scripts/enroll.sh org3.json
>>> ./scripts/crypto.sh org3.json
>>> ```
>
>
>> 3. 複製 channelMSP/peerOrganizations/org3/com 到 config/organizations/peerOrganizations/org3.com
>
>>> ***工作目錄: $HOME/workspaces/fabric-lab/workdir/config***
>>> ***`[command]`***
>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/config
>>> cp -a ../ca/channelMSP/peerOrganizations/org3.com organizations/peerOrganizations/
>>> ```
>
> 
>
> 2. 產生新機構 (Org3MSP) 的機構文件

>> **工作目錄: $HOME/workspaces/fabric-lab/config**
>
>> 1. 創建一新目錄  $HOME/workspaces/fabric-lab/config/org3
>> 2. 建立一檔案 configtx.yaml 內容如下:
>
>>> ```yaml
>>> Organizations:
>>>      - &Org3
>>>          Name: Org3MSP
>>>          ID: Org3MSP
>>>          MSPDir: ../organizations/peerOrganizations/org3.com/msp
>>>          Policies:
>>>              Readers:
>>>                  Type: Signature
>>>                  Rule: "OR('Org3MSP.admin', 'Org3MSP.peer', 'Org3MSP.client')"
>>>              Writers:
>>>                  Type: Signature
>>>                  Rule: "OR('Org3MSP.admin', 'Org3MSP.client')"
>>>              Admins:
>>>                  Type: Signature
>>>                  Rule: "OR('Org3MSP.admin')"
>>>              Endorsement:
>>>                  Type: Signature
>>>                  Rule: "OR('Org3MSP.peer')"
>>> ```
>
>
>> 3. 執行 configtxgen 產生 org3.json
>
>>> ```bash
>>> cd /home/hyperledger/workspaces/fabric-lab/workdir/config
>>> mkdir org3
>>> cd org3
>>> configtxgen -configPath $PWD -printOrg Org3MSP > org3.json
>>> ```
>

>3. 執行 update config 程序

>>擷取 application channel (channel1) 的 config block
>>>
>>1. 由 org1MSP(org1.com) 執行
>>>
>>***工作目錄: $HOME/workspaces/fabric-lab/workdir/org1-client***

>>> ***`[command]`***
>>>
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/org1-client
>>> source admin.env peer0 1051
>>> cd tmp
>>> peer channel fetch config config_block.pb -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>>> ```

> 4. 執行 update config 程序
>
>> ***工作目錄: $HOME/workspaces/fabric-lab/workdir/org1.com/tmp***
>
>> ***`[command]`***
>>
>> 1. 將 config_block.pb 轉換成 json 文件 (config_block.json)
>
>>    ```bash
>>    configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
>>    ```

>> 2. 由 config_block.json 擷取生成 config 內容 (config.json
>
>> ***`[command]`***
>>> ```bash
>>> jq .data.data[].payload.data.config config_block.json >conf
ig.json
>>>```
>> 3. 將 org3.json 文件加到 config.json 中，產生 config_modified.json
>
>> ***`[command]`***
>>> ```bash
>>> cp ../../config/org3/org3.json .
>>> jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups":{"Org3MSP":.[1]}}}}}' config.json org3.json >config_modified.json
>>> ```
>> 4. 將 config.json 轉換成 pb 檔案格式 (config.pb)
>
>> ***`[command]`***
>>> ```bash
>>> configtxlator proto_encode --input config.json --type common.Config --output config.pb
>>> ```

>> 5. 將 config_modified.json 轉換成 pb 檔案格式 (config_modified.pb)
>
>> ***`[command]`***
>>> ```bash
>>> configtxlator proto_encode --input config_modified.json --type common.Config --output config_modified.pb
>>> ```
>> 6. 將 original (config.pb) 與 updated (config_modified.pb) 計算更新差異 (config_update.pb)
>
>> ***`[command]`***
>>> ```bash
>>> configtxlator compute_update --channel_id channel1 --original config.pb --updated config_modified.pb --output config_update.pb
>>>```
>> 7. 將 config_update.pb 轉換成 json 檔案格式 (config_update.json)
>
>> ***`[command]`***
>>> ```bash
>>> configtxlator proto_decode --input config_update.pb --type 
common.ConfigUpdate --output config_update.json
>>> ```
>> 8. 將 config_update.json 加上 "信封" (envelope) 成為 config_update_in_envelope.json
>
>> ***`[command]`***
>>> ```bash
>>> echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}'|jq . > config_update_in_envelope.json
>>>```
>> 9. config_update_in_envelope.json 轉換成　pb 檔案格式
>
>> ***`[command]`***
>>> ```bash
>>> configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
>>> ```

> 5. 執行 peer channel signconfigtx, 簽章、背書
>
> ***`[command]`***
>> ```bash
>> peer channel signconfigtx -f config_update_in_envelope.pb
>> ```
>> `System Response:`
>> ```bash
>> 2023-11-14 06:45:38.811 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>> ```
> 6. 由 org2MSP(org2.com) 執行更新指令 (channel1 有二個機構參與，channel 的 admin policy 為 MAJORITY，在執行 channel 的管理 - 以新增 organization 為例，必須有足夠多的 endorse, 才能 channel update - 即 signconfigtx 以及 update channel 的機構總和要符合 channel admin policy)
>
>> ***工作目錄: $HOME/workspaces/fabric-lab/workdir/org2-client***
>
> ***`[command]`***
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/org2-client
>> source admin.env peer0 2051
>> ```
>> 切換工作目錄到 $HOME/workspaces/fabric-lab/workdir/org2-client/tmp
>>
> ***`[command]`***
>> ```bash
>> cd $HOME/workspaces/fabric-lab/workdir/org2-client/tmp
>> #
>> # 複製 剛才 org1.com 簽章的 config_update_in_envelope.pb 到 $HOME/workspaces/fabric-lab/workdir/org2-client/tmp
>> #
>> cp ../../org1-client/tmp/config_update_in_envelope.pb $PWD
>> #
>> ## 執行 channel update
>> #
>> peer channel update -f config_update_in_envelope.pb -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA
>> ```
>> `System Response:`
>> ```bash
>> 2023-11-14 07:01:30.685 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
>> 2023-11-14 07:01:30.693 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
>> ```

16. 啟動 org3.com peer node 以及加入 channel, 部署 chaincode

> 1. 部署, 啟動 peer0.org3.com, peer1.org3.com
>> 1. 複製 localMSP 到對應目錄
>
>> ***工作目錄: $HOME/workspaces/fabric-lab/service/peers***
>
>> ***`[command]`***
>> ```bash
>> cd $HOME/workspaces/fabric-lab/service/peers
>> # 執行 scripts/cpMSP.sh
>> ./scripts/cpMSP.sh
>>```
> **檢查 org3.com/{peer0.org3.com, peer1.org3.com} 是否有 MSP檔案, 目錄
>> ```bash
>> tree org3.com
>> ```
>> `System Response:`
>> ```bash
>> org3.com/
>> ├── peer0.org3.com
>> │   └── peer0.org3.com
>> │       ├── msp
>> │       │   ├── admincerts
>> │       │   ├── cacerts
>> │       │   │   └── ca.pem
>> │       │   ├── config.yaml
>> │       │   ├── keystore
>> │       │   │   └── priv_sk
>> │       │   ├── signcerts
>> │       │   │   └── peer0.org3.com-cert.pem
>> │       │   └── tlscacerts
>> │       │       └── tlsca.org3.com-cert.pem
>> │       └── tls
>> │           ├── ca.crt
>> │           ├── server.crt
>> │           └── server.key
>> └── peer1.org3.com
>>     └── peer1.org3.com
>>         ├── msp
>>         │   ├── admincerts
>>         │   ├── cacerts
>>         │   │   └── ca.pem
>>         │   ├── config.yaml
>>         │   ├── keystore
>>         │   │   └── priv_sk
>>         │   ├── signcerts
>>         │   │   └── peer1.org3.com-cert.pem
>>         │   └── tlscacerts
>>         │       └── tlsca.org3.com-cert.pem
>>         └── tls
>>             ├── ca.crt
>>             ├── server.crt
>>             └── server.key
>> ```
> 2. 修改 docker-compose.yaml, 將第 241 ~ 最後最前端註解移除
>
>> ***`[command]`***
>>>```bash
>>> sed -i '241,$ s/^# //' docker-compose.yaml 
>>>```
> 3. 啟動 peer 服務
>
>> ***`[command]`***
>>> ```bash
>>> docker-compose up -d peer0.org3.com peer1.org3.com
>>>```
> 4. 檢查　peer 服務是否啟動成功
>
>> ***`[command]`***
>>> ```bash
>>> docker-compose ps peer0.org3.com peer1.org3.com
>>> ```
>>> `System Response:`
>>> ```bash
>>>      Name            Command       State                                                Ports                                              
>>> -------------------------------------------------------------------------------------------------------------------------------------------
>>> peer0.org3.com   peer node start   Up      0.0.0.0:13051->13051/tcp,:::13051->13051/tcp, 0.0.0.0:3051->3051/tcp,:::3051->3051/tcp, 7051/tcp
>>> peer1.org3.com   peer node start   Up      0.0.0.0:13151->13151/tcp,:::13151->13151/tcp, 0.0.0.0:3151->3151/tcp,:::3151->3151/tcp, 7051/tcp
>>>```
>>
> 5. 部署 chaincode
>
>> ***工作目錄: $HOME/workspaces/fabric-lab/workdir/org3-client***
>>
>> ***`[command]`***
>>> ```bash
>>> #
>>> # 切換目錄
>>> #
>>> cd $HOME/workspaces/fabric-lab/workdir/org3-client
>>> #
>>> # 啟始環境部署配置
>>> #
>>> ./scripts/init.sh
>>> #
>>> # 初始化環境變數
>>> #
>>> source admin.env peer0 3051 
>>>```
>>> 切換工作目錄到 $HOME/workspaces/fabric-lab/workdir/org3-client/tmp
>
>> ***`[commaond]`***
>>> ```bash
>>> cd $HOME/workspaces/fabric-lab/workdir/org3-client/tmp
>>> # Fetch config block (必須是第一個 config block) 
>>> peer channel fetch 0 channel1_config.block -c channel1 -o orderer0.org4.com:4050 --tls --cafile $ORDERER_TLS_CA 
>>>```
