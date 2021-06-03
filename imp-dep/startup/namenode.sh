#!/bin/bash

# update instane and get git repo
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

ETH0=`ip addr show ens4 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
apt update
apt -y install docker.io
cd ~
ME=`hostname`
git clone https://github.com/yarivgraf/apache-impala-cluster-docker.git
cd apache-impala-cluster-docker/imp-dep/apache-hadoop-3.2.2/

#### ZOOKEEPER
docker run --net=host --name zookeeper --restart always -d zookeeper

#### POSTGRES
docker run --name postgresql --net=host -e POSTGRES_PASSWORD=mypassword -e POSTGRES_USER=hiveuser -e POSTGRES_DB=metastore --restart always -v /var/lib/postgresql/data:/var/lib/postgresql/data -d postgres:latest


#### NAMENODE
sed -i -- "s/changeme/$ME/g" *
docker run --net=host --name namenode -v ~/apache-impala-cluster-docker/imp-dep/apache-hadoop-3.2.2:/opt/hadoop/conf -v /var/lib/hadoop-hdfs/cache/hdfs/dfs/name:/var/lib/hadoop-hdfs/cache/hdfs/dfs/name --restart always -d yarivgraf/apache-hadoop-3.2.2:latest /run-namenode.sh

docker exec namenode /provision-namenode.sh


#### METASTORE
cd ~/apache-impala-cluster-docker/imp-dep/apache-metastore-3.1.2
sed -i -- "s/changeme/$ME/g" *
docker run --net=host --name provision -v ~/apache-impala-cluster-docker/imp-dep/apache-metastore-3.1.2:/opt/hadoop/conf -v ~/apache-impala-cluster-docker/imp-dep/apache-metastore-3.1.2:/opt/hive/conf -d yarivgraf/apache-metastore-3.1.2:latest /opt/hive/bin/schematool -initSchema -dbType postgres -userName hiveuser -passWord 'mypassword'

docker run --net=host --name metastore -v ~/apache-impala-cluster-docker/imp-dep/apache-metastore-3.1.2:/opt/hadoop/conf -v ~/apache-impala-cluster-docker/imp-dep/apache-metastore-3.1.2:/opt/hive/conf --restart always -d yarivgraf/apache-metastore-3.1.2:latest /run-metastore.sh

#### STATESTORED
cd ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf
sed -i -- "s/changeme/$ME/g" *
docker run --net=host --name statestored  -v ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf:/opt/impala/conf -e IP=$ETH0 -v /opt/impala/logs:/opt/impala/logs --restart always -d yarivgraf/apache-impala-3.4.0:latest /entrypoint_statestored.sh

#### CATALOGD
docker run --net=host --name catalogd ~/apache-impala-cluster-docker/imp-dep/apache-impala-3.4.0/conf:/opt/impala/conf -e IP=$ETH0 -v /opt/impala/logs:/opt/impala/logs --restart always -d yarivgraf/apache-impala-3.4.0:latest /entrypoint_catalogd.sh


