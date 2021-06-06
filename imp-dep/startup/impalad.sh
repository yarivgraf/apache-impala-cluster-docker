#!/bin/bash

# update instane and get git repo
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

apt update
apt -y install docker.io
NAMENODE=`curl -s http://metadata.google.internal/computeMetadata/v1/instance/attributes/namenode -H 'Metadata-Flavor: Google'`
NAMENODE_IP=`host $NAMENODE | gawk '{ print $4 }'`
ME=`hostname`
cd ~
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
docker run --net=host --name datanode --restart always -v ~/apache-impala-cluster-docker/imp-dep/apache-hadoop-3.2.2:/opt/hadoop/conf -v /var/run/hadoop-hdfs:/var/run/hadoop-hdfs -v /data0:/data0 -v /data1:/data1 -v /data2:/data2 -v /data3:/data3 -v /data4:/data4 -d yarivgraf/apache-hadoop-3.2.2:latest /run-datanode.sh


#### IMPALAD
cd ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf
sed -i -- "s/changeme/$NAMENODE/g" *
docker run --net=host --name impalad -v ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf:/opt/impala/conf -e IP=$NAMENODE_IP --restart always -v /var/run/hadoop-hdfs:/var/run/hadoop-hdfs -v /opt/impala/logs:/opt/impala/logs -d yarivgraf/apache-impala-3.4.0:latest /entrypoint_impalad.sh

#### CONSUL
docker run --net=host --name consul --restart always -v /root/apache-impala-cluster-docker/consul/config.json:/etc/config.json -v /tmp/consul:/consul/data -d consul:1.0.6 agent -config-dir /etc/config.json -advertise $ETH0 -retry-join=172.16.0.101 -retry-join=172.16.0.102 -retry-join=172.16.0.103 -node $ME -datacenter=gce1
#########  COLLECTD

### COLLECTD
cd ~/apache-impala-cluster-docker/imp-dep/collectd
sed -i -- "s/changeme/$ME.c.bamboo-antler-742.internal/g" *
docker run --rm --privileged -d --net=host -v ~/apache-impala-cluster-docker/imp-dep/collectd:/etc/collectd:ro -v /proc:/mnt/proc:ro --name=collectd fr3nd/collectd



