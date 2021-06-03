#!/bin/bash

# update instane and get git repo
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

apt update
apt -y install docker.io
NAMENODE=`curl -s http://metadata.google.internal/computeMetadata/v1/instance/attributes/namenode -H 'Metadata-Flavor: Google'`
NAMENODE_IP=`host $NAMENODE| gawk  '{ print $4 }'`
git clone https://github.com/yarivgraf/apache-impala-cluster-docker.git

# Format and mount disks
cd ~/apache-impala-cluster-docker/systemd/
mv * /etc/systemd/system/
systemctl enable data0.mount data1.mount data2.mount data3.mount data4.mount
for i in /dev/sd[b-f]; do mkfs.xfs $i ; done
systemctl start data0.mount data1.mount data2.mount data3.mount data4.mount

#### DATANODE
cd ~/apache-impala-cluster-docker/imp-dep/apache-hadoop-3.2.2/
sed -i -- "s/changeme/$NAMENODE/g" *
docker run --net=host --name namenode -v ~/apache-impala-cluster-docker/imp-dep/apache-hadoop-3.2.2:/opt/hadoop/conf -v /var/lib/hadoop-hdfs/cache/hdfs/dfs/name:/var/lib/hadoop-hdfs/cache/hdfs/dfs/name --restart always -d yarivgraf/apache-hadoop-3.2.2:latest /run-namenode.sh

docker run --net=host --name datanode --restart always -v ~/apache-impala-cluster-docker/imp-dep/apache-hadoop-3.2.2:/opt/hadoop/conf -v /var/run/hadoop-hdfs:/var/run/hadoop-hdfs -v /data0:/data0 -v /data1:/data1 -v /data2:/data2 -v /data3:/data3 -v /data4:/data4 -d yarivgraf/apache-hadoop-3.2.2:latest /run-datanode.sh


#### IMPALAD
cd ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf
sed -i -- "s/changeme/$NAMENODE/g" *
docker run --net=host --name impalad -v ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf:/opt/impala/conf -e IP=$NAMENODE_IP --restart always -v /var/run/hadoop-hdfs:/var/run/hadoop-hdfs -v /opt/impala/logs:/opt/impala/logs -d yarivgraf/apache-impala-3.4.0:latest  /entrypoint_impalad.sh

