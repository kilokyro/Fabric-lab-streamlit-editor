# Hyperledger Fabric 實作

## 環境準備

### Windows 11/10

1. 安裝 Ubuntu 於 VMWare 環境
2. 安裝 Ubuntu 於 VirtualBox
3. 使用 WSL2
   1. 安裝 docker-desktop
4. 安裝VSCode

### Mac OSX

1. 安裝 docker-desktop
2. 安裝 vscode

### Ubuntu

1. 安裝 vscode

## 下載課程材料

### 使用 vscode 連線到工具環境

1. remote ssh
2. WSL2
3. 開啟本端資料夾

### 下載

```bash
mkdir $HOME/workspaces
cd $HOME/workspaces
git clone --recursive https://gitlab.com/cshuangtw/fabric-lab.git
```

### 安裝套件

```bash
cd $HOME/workspaces/fabric-lab
./env-deploy.sh
```

### 重新開機

> 套用所有變更， 請先重新開機

### 測試安裝結果

```bash
cd $HOME/workspaces/fabric-lab/fabric-samples/test-network
./network.sh up createChannel -c channel1 -s couchdb -ca
```

```docker
docker ps
CONTAINER ID   IMAGE                               COMMAND                   CREATED          STATUS          PORTS                                                                                                NAMES
0ff4a2623c87   hyperledger/fabric-tools:latest     "/bin/bash"               19 seconds ago   Up 18 seconds                                                                                                        cli
e7bea861e60c   hyperledger/fabric-peer:latest      "peer node start"         20 seconds ago   Up 19 seconds   0.0.0.0:7051->7051/tcp, :::7051->7051/tcp, 0.0.0.0:9444->9444/tcp, :::9444->9444/tcp                 peer0.org1.example.com
d68acf0d5f43   hyperledger/fabric-peer:latest      "peer node start"         20 seconds ago   Up 19 seconds   0.0.0.0:9051->9051/tcp, :::9051->9051/tcp, 7051/tcp, 0.0.0.0:9445->9445/tcp, :::9445->9445/tcp       peer0.org2.example.com
50cbfab22d0a   couchdb:3.1.1                       "tini -- /docker-ent…"   21 seconds ago   Up 19 seconds   4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp, :::7984->5984/tcp                                        couchdb1
353cf7a40249   hyperledger/fabric-orderer:latest   "orderer"                 21 seconds ago   Up 19 seconds   0.0.0.0:7050->7050/tcp, :::7050->7050/tcp, 0.0.0.0:9443->9443/tcp, :::9443->9443/tcp                 orderer.example.com
f64ee0982d6d   couchdb:3.1.1                       "tini -- /docker-ent…"   21 seconds ago   Up 19 seconds   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp, :::5984->5984/tcp                                        couchdb0
43dbfc1f7a60   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   25 seconds ago   Up 23 seconds   0.0.0.0:8054->8054/tcp, :::8054->8054/tcp, 7054/tcp, 0.0.0.0:18054->18054/tcp, :::18054->18054/tcp   ca_org2
67def3a16305   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   25 seconds ago   Up 23 seconds   0.0.0.0:7054->7054/tcp, :::7054->7054/tcp, 0.0.0.0:17054->17054/tcp, :::17054->17054/tcp             ca_org1
6eebb1476ed3   hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   25 seconds ago   Up 23 seconds   0.0.0.0:9054->9054/tcp, :::9054->9054/tcp, 7054/tcp, 0.0.0.0:19054->19054/tcp, :::19054->19054/tcp   ca_orderer
```

### 停止 shudown network

```
./network.sh down
```

## Fabric-CA

### Fabric-ca server 啟動

> **工作目錄: $HOME/workspaces/fabric-lab/ca**
>
> ```bassh
> docker-compose up -d
> ```

### Fabric-ca client

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/ca**
>
> 1. 複製目錄 msp-template 到 msp
> 2. 將 orderer.json 更名 *org4.json*
> 3. 將 peer.json 更名 *org1.json*
> 4. 將 msp-template/peer.json 複製到 msp 目錄並更名為 *org2.json*
> 5. 將 msp-template/peer.json 複製到 msp 目錄並更名為 *org3.json*
> 6. 依序修改檔案
>
>    *org1.json
> 
>    2054 -> 1054
> 
>    2154 -> 1154
> 
>    caServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org1.com/ca/fabric-ca-server-config.yaml 的 pass: 相同
> 
>    tlsServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org1.com/tls/fabric-ca-server-config.yaml 的 pass: 相同
>
>    ![1698995165285](image/README/1698995165285.png)
>
>    *org2.json*
> 
>    org1.com -> org2.com
> 
>    caServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org2.com/ca/fabric-ca-server-config.yaml 的 pass: 相同
> 
>    tlsServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org2.com/tls/fabric-ca-server-config.yaml 的 pass: 相同
>
>    *org3.com*
> 
>    org1.com -> org3.com
> 
>    2054 -> 3054
> 
>    2154 -> 3154
> 
>    caServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org3.com/ca/fabric-ca-server-config.yaml 的 pass: 相同
> 
>    tlsServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org3.com/tls/fabric-ca-server-config.yaml 的 pass: 相同
>
>    org4.com
> 
>    caServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org4.com/ca/fabric-ca-server-config.yaml 的 pass: 相同
> 
>    tlsServer.secret  修改 和 $HOME/workspaces/fabric-lab/ca/config/org4.com/tls/fabric-ca-server-config.yaml 的 pass: 相同
>
> ***PS:***

> ```bash
>  find ../../../ca/config/*/*/fabric-ca-server-config.yaml|xargs grep pass:
> ```

### 執行 ../scripts/networkgen.sh 生成  network.json

```bash
../scripts/networkgen.sh -t organizations.json -o org4.jsom -p org1.json -p org2.json -p org3.json -O ../network.json
```
### 生成加密文件

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/ca**
>
> *註冊 fabric-ca server 的 admin 帳號*
> ```bash
> ./scripts/enroll.sh ./network.json 
> ```
> *registry & enroll 所有的檵構，參與個體的加密材料*
> ```bash
> ./scripts/crypto.sh ./network.json
> ```

## 創世塊 (Genesis Block)

> **工作目錄: $HOME/workspaces/fabric-lab/workdir/config**
> 1. 將 $HOME/workspaces/fabric-lab/workdir/ca/channelMSP 複製到 $HOME/workspaces/fabric-lab/workdir/config/organizations
>    ```bash
>    cp -a $HOME/workspaces/fabric-lab/workdir/ca/channelMSP $HOME/workspaces/fabric-lab/workdir/config/organizations
>    ```
> 2. 