#----------------------------------------------------------------------
# Dockerfile - icp-clis container image that include all ICP CLIs
#----------------------------------------------------------------------
FROM ubuntu:18.04

ARG MYCLUSTER_IP
ARG MYCLUSTER_TOKEN
ARG CA_CRT_FILE

COPY ${CA_CRT_FILE} ca.crt

RUN apt update && \
   apt upgrade -y && \
   apt -y install \
	curl \
   software-properties-common && \
   : "-------------------------------------------------------" && \
   : "# ICP CLI" && \
   : "-------------------------------------------------------" && \
   curl -kLo cloudctl-linux-amd64-3.1.2-1203 https://${MYCLUSTER_IP}:8443/api/cli/cloudctl-linux-amd64 && \
   chmod 755 cloudctl-linux-amd64-3.1.2-1203 && \
   mv cloudctl-linux-amd64-3.1.2-1203 /usr/local/bin/cloudctl && \
   : "-------------------------------------------------------" && \
   : "# Kubernetes CLI" && \
   : "-------------------------------------------------------" && \
   curl -kLo kubectl-linux-amd64-v1.12.4 https://${MYCLUSTER_IP}:8443/api/cli/kubectl-linux-amd64 && \
   chmod 755 kubectl-linux-amd64-v1.12.4 && \
   mv kubectl-linux-amd64-v1.12.4 /usr/local/bin/kubectl && \
   kubectl config set-cluster mycluster --server=https://${MYCLUSTER_IP}:8001 --insecure-skip-tls-verify=true && \
   kubectl config set-context mycluster-context --cluster=mycluster && \
   kubectl config set-credentials admin --token=${MYCLUSTER_TOKEN} && \
   kubectl config set-context mycluster-context --user=admin --namespace=cert-manager && \
   kubectl config use-context mycluster-context && \
   : "-------------------------------------------------------" && \
   : "# Docker" && \
   : "-------------------------------------------------------" && \
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
   add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" && \
   apt -y update && \
   apt -y install docker-ce docker-ce-cli containerd.io && \
   mkdir -p /etc/docker/certs.d/mycluster.icp\:8500 && \
   mv ca.crt /etc/docker/certs.d/mycluster.icp\:8500/ca.crt && \ 
   : "-------------------------------------------------------" && \
   : "# Helm CLI" && \
   : "-------------------------------------------------------" && \
   curl -kLo helm-linux-amd64-v2.9.1.tar.gz https://${MYCLUSTER_IP}:8443/api/cli/helm-linux-amd64.tar.gz && \
   tar -xvzf ./helm-linux-amd64-v2.9.1.tar.gz && \
   chmod 755 ./linux-amd64/helm && \
   mv ./linux-amd64/helm /usr/local/bin/helm && \
   rm -rf ./linux-amd64 ./helm-linux-amd64-v2.9.1.tar.gz && \
   : "-------------------------------------------------------" && \
   : "# Cloud Foundry CLI (cf)" && \
   : "-------------------------------------------------------" && \
   curl https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - && \
   echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list && \
   apt -y update && \
   apt -y install cf-cli && \
   : "-------------------------------------------------------" && \
   : "# Istio CLI (istioctl)" && \
   : "-------------------------------------------------------" && \
   curl -kLo istioctl-linux-amd64-v1.0.2 https://${MYCLUSTER_IP}:8443/api/cli/istioctl-linux-amd64 && \
   chmod 755 istioctl-linux-amd64-v1.0.2 && \
   mv istioctl-linux-amd64-v1.0.2 /usr/local/bin/istioctl && \
   : "-------------------------------------------------------" && \
   : "# others " && \
   : "-------------------------------------------------------" && \
   mkdir ~/workspace

ENTRYPOINT [""]
CMD ["/bin/bash"]
