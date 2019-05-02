# icp-clis
Dockerfile for all in one IBM Cloud Private (ICP) CLI runtimes image.
It includes all ICP CLIs setup:
- ICP CLI (cloudctl)
- Kubernetes CLI (kubectl)
- Docker (docker)
- Helm CLI (helm)
- Cloud Foundry CLI (cf)
- Istio CLI (istiocli)

# Assumptions
- ICP Version 3.1.2 is assumed. Other version must support different CLI versions.
- Tested on macOS 10.14.4 (Mojave) only. Other environments might cause error.
- Below names were hardcoded in `Dockerfile`. Modify it if they don't match your value.
    - Cluster name: mycluster.icp
    - Cluster account: admin

# Setup
1. Clone this repository and cd into the directory
```
git clone https://github.com/naomizenge/icp-clis.git 
cd icp-clis
```

2. Get ca.crt file

Docker setup [requires](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_images/configuring_docker_cli.html) ca.crt file. 
Get ca.crt by issuing following command:
```
scp root@<cluster_CA_domain>:/etc/docker/certs.d/<cluster_CA_domain>\:8500/ca.crt ./ca.crt
```
or, contact system administrator

Ref: [Configuring authentication for the Docker CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_images/configuring_docker_cli.html)

3. Get Token

Kubernetes CLI setup [requires](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/install_kubectl.html) token. Get it by following steps:
  1. Login ICP dashboard 
  2. Select user icon, click Configure Client. You'll see token in one of lines.

Ref: [Installing the Kubernetes CLI (kubectl)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/install_kubectl.html)

4. Run Docker build
Run `docker image build` with specifying Cluster IP, Token and ca.crt file name with path:

```
docker image build \
    --build-arg MYCLUSTER_IP= "192.168.27.100" \
    --build-arg MYCLUSTER_TOKEN="abcabc..." \
    --build-arg CA_CRT_FILE="./ca.crt" \
    -t nzenge/icp-clis:1.0 .
```

, or you may run `./build.sh` after local variables modification.

# Run
Run docker container with following command:
```
docker container run \
    -v ${PWD}:/workspace \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --add-host mycluster.icp:"192.168.27.100" \
    --add-host api.apps.kube.cf.icp.net:"192.168.27.100" \
    --add-host uaa.apps.kube.cf.icp.net:"192.168.27.100" \
    --add-host doppler.apps.kube.cf.icp.net:"192.168.27.100" \
    --add-host ssh.apps.kube.cf.icp.net:"192.168.27.100" \
    --rm -it --name myicp nzenge/icp-clis:1.0
```

, or you may run `./run.sh` after local variable modification.

# Troubleshooting
## Q: kubectl returns error: You must be logged in to the server
```
root@46d9ac5bb482:/# kubectl version
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.4", GitCommit:"f49fa022dbe63faafd0da106ef7e05a29721d3f1", GitTreeState:"clean", BuildDate:"2018-12-14T07:10:00Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```
A: As message says, you have to log in to ICP server first with `cloudctl` command.
```
root@46d9ac5bb482:/# cloudctl login -a https://mycluster.icp:8443 -u <user> -p <password> -n default --skip-ssl-validation
Authenticating...
OK

Targeted account mycluster Account (id-mycluster-account)

Targeted namespace default

Configuring kubectl ...
Property "clusters.mycluster" unset.
Property "users.mycluster-user" unset.
Property "contexts.mycluster-context" unset.
Cluster "mycluster" set.
User "mycluster-user" set.
Context "mycluster-context" created.
Switched to context "mycluster-context".
OK

Configuring helm: /root/.helm
OK
root@46d9ac5bb482:/# kubectl version
Client Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.4", GitCommit:"f49fa022dbe63faafd0da106ef7e05a29721d3f1", GitTreeState:"clean", BuildDate:"2018-12-14T07:10:00Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.4+icp-ee", GitCommit:"d03f6421b5463042d87aa0211f116ba4848a0d0f", GitTreeState:"clean", BuildDate:"2019-01-17T13:14:09Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
root@46d9ac5bb482:/# 

```

## Q: helm version fails to retrieve server information
```
root@46d9ac5bb482:/# helm version
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Error: cannot connect to Tiller
```
A: You have to add `--tls` option to Helm commands that access the server through Tiller.
```
root@46d9ac5bb482:/# helm version --tls
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1+icp", GitCommit:"8ddf4db6a545dc609539ad8171400f6869c61d8d", GitTreeState:"clean"}
root@46d9ac5bb482:/# 
```

## Q; docker login returns error: Service Unavailable, or, Client.Timeout exceeded while awaiting headers
```
root@b4055f512e92:/# docker login mycluster.icp:8500
Username: admin
Password: 
Error response from daemon: Get https://mycluster.icp:8500/v2/: Service Unavailable
```
or
```
root@7ec99293c23e:/# docker login mycluster.icp:8500 
Username: admin
Password: 
Error response from daemon: Get https://mycluster.icp:8500/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
root@7ec99293c23e:/# 
```
A: Check your host's /etc/hosts and "mycluster.icp" should be in there. Notice: Not in the container's /etc/hosts. Your host's (e.g. Your Mac's) /etc/hosts.
```
192.168.27.100  mycluster.icp 
```
