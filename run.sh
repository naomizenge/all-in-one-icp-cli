#!/usr/bin/env bash
#----------------------------------------------------------------------
# run.sh - Run Docker container of icp-clis
#----------------------------------------------------------------------

# Specifies your ICP cluster IP (e.g. "192.168.27.100")
MYCLUSTER_IP=""

if [ "$MYCLUSTER_IP" == "" ]; then
    echo "ERROR: MYCLUSTER_IP is not set in buiid.sh. Specify your ICP cluster IP address."
    exit 1
fi

docker container run \
       -v ${PWD}:/workspace \
       -v /var/run/docker.sock:/var/run/docker.sock \
       --add-host mycluster.icp:$MYCLUSTER_IP \
       --add-host api.apps.kube.cf.icp.net:$MYCLUSTER_IP \
       --add-host uaa.apps.kube.cf.icp.net:$MYCLUSTER_IP \
       --add-host doppler.apps.kube.cf.icp.net:$MYCLUSTER_IP \
       --add-host ssh.apps.kube.cf.icp.net:$MYCLUSTER_IP \
       --rm -it --name myicp nzenge/icp-clis:1.0
exit $?
