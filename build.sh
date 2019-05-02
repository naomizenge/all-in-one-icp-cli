#!/usr/bin/env bash
#----------------------------------------------------------------------
# build.sh - Build Docker image of icp-clis
#----------------------------------------------------------------------

# Specifies your ICP cluster IP (e.g. "192.168.27.100")
MYCLUSTER_IP=""

# Get token from ICP dashboard by
# 1) Login ICP dashboard 
# 2) Select user icon, click Configure Client. You'll see token in one of lines.
MYCLUSTER_TOKEN=""

# Get ca.crt by issuing following command:
#   scp root@<cluster_CA_domain>:/etc/docker/certs.d/<cluster_CA_domain>\:8500/ca.crt ca.crt
# or, contact system administrator, and put it on the same directory.
CA_CRT_FILE="./ca.crt"


if [ "$MYCLUSTER_IP" == "" ]; then
    echo "ERROR: MYCLUSTER_IP is not set in buiid.sh. Specify your ICP cluster IP address."
    exit 1
fi
if [ "$MYCLUSTER_TOKEN" == "" ]; then
    echo "ERROR: cluster token is not set in build.sh. Get token by"
    echo "1) Login ICP dashboard"
    echo "2) Select user icon, click Configure Client. You'll see token in one of lines."
    echo ", and set it to MYCLUSTER_TOKEN in build.sh."
    exit 2
fi
if [ ! -f $CA_CRT_FILE ]; then
    echo "ERROR: CA_CRT_FILE (File ca.crt = $CA_CRT_FILE does not exist."
    echo "Get ca.crt by issuing following command:"
    echo "    scp root@<cluster_CA_domain>:/etc/docker/certs.d/<cluster_CA_domain>\:8500/ca.crt ca.crt"
    echo "or, contact system administrator, and put it on the same directory."
    exit 3
fi

docker image build \
--build-arg MYCLUSTER_IP=$MYCLUSTER_IP \
--build-arg MYCLUSTER_TOKEN=$MYCLUSTER_TOKEN \
--build-arg CA_CRT_FILE=$CA_CRT_FILE \
-t nzenge/icp-clis:1.0 .
RC=$?
if [ $RC -ne 0 ]; then
    echo "ERROR: dockage image build failed. RC = $RC"
    exit $RC
fi

exit 0