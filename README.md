In order to deploy an Apache Impala, you need these components: Apache Zookeeper, PostgresSQL (or MySQL), Apache Hadoop and Apache Metastore.

* you can also add Hue. but the hue.ini file should be external and mounted to the docker container. Here is an example:

* docker run --net=host --name hue -v /opt/hue/conf/hue.ini:/usr/share/hue/desktop/conf/hue.ini --restart always -d gethue/hue:latest

* Hue should be run after all the Impala cluster is set. Hue should run on "namenode" instance.


The Apache Impala was compiled from here:
 
https://downloads.apache.org/impala/3.4.0/apache-impala-3.4.0.tar.gz

The Metastore and Hadoop were taken from Apache download as well:

https://downloads.apache.org/hadoop/common/hadoop-3.2.2/hadoop-3.2.2.tar.gz

https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz

* Hive server2 is not working (bug?) it doesn't bind port 10000. However, The Impala needs Metastore to work.

If you wish you use your own xml conf directory, you can mount it this way:

-v /your/conf:/opt/hadoop/conf

-v /your/conf:/opt/hive/conf

-v /your/conf:/opt/impala/conf

In order to deploy the cluster, please follow the below step by step.


How to run Apache Impala 3.4.0 cluster
==============================
This implementation was tested using Google cloud platform.

Four instances are needed. using Ubuntu Distro. It can be run on Centos as well (mind the pkg installation). Make sure the selinux is disabled and instances/servers are resolved (e.g. a datanode can ping namenode by its name) :

1* namenode should be called “namenode” (because of hadoop xml build-in files). It runs Zookeeper, Postgres, Namenode, Metastore, Statestored and Catalogd (Impala).

3* datanodes with 5 formatted disks (mount on /data0 .. /data4). It runs Datanode and Impalad (Impala server and shell). 


# Run on namenode instance:

ETH0=`ip addr show ens4 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

apt update

apt -y install docker.io

#### ZOOKEEPER
docker run --net=host --name zookeeper --restart always -d zookeeper
#### POSTGRES
docker run --name postgresql --net=host -e POSTGRES_PASSWORD=mypassword -e POSTGRES_USER=hiveuser -e POSTGRES_DB=metastore --restart always -v /var/lib/postgresql/data:/var/lib/postgresql/data -d postgres:9.6.2-alpine


#### NAMENODE
docker run --net=host --name namenode -v /var/lib/hadoop-hdfs/cache/hdfs/dfs/name:/var/lib/hadoop-hdfs/cache/hdfs/dfs/name --restart always -d yarivgraf/apache-hadoop-3.2.2:latest /run-namenode.sh

docker exec namenode /provision-namenode.sh
#### METASTORE
docker run --net=host --name provision -d yarivgraf/apache-metastore-3.1.2:latest /opt/hive/bin/schematool -initSchema -dbType postgres -userName hiveuser -passWord 'mypassword'
docker run --net=host --name metastore --restart always -d yarivgraf/apache-metastore-3.1.2:latest /run-metastore.sh
#### STATESTORED
docker run --net=host --name statestored -e IP=$ETH0 -v /opt/impala/logs:/opt/impala/logs --restart always -d yarivgraf/apache-impala-3.4.0:latest /entrypoint_statestored.sh

#### CATALOGD
docker run --net=host --name catalogd -e IP=$ETH0 -v /opt/impala/logs:/opt/impala/logs --restart always -d yarivgraf/apache-impala-3.4.0:latest /entrypoint_catalogd.sh
 


# Run on datanode instances (3):

apt update

apt -y install docker.io


NAMENODE_IP=`host namenode| gawk  '{ print $4 }'`
#### DATANODE
docker run --net=host --name datanode --restart always -v /var/run/hadoop-hdfs:/var/run/hadoop-hdfs -v /data0:/data0 -v /data1:/data1 -v /data2:/data2 -v /data3:/data3 -v /data4:/data4 -d yarivgraf/apache-hadoop-3.2.2:latest /run-datanode.sh
#### IMPALAD
docker run --net=host --name impalad -e IP=$NAMENODE_IP --restart always -v /var/run/hadoop-hdfs:/var/run/hadoop-hdfs -v /opt/impala/logs:/opt/impala/logs -d yarivgraf/apache-impala-3.4.0:latest  /entrypoint_impalad.sh



You can access the hadoop namenode:  http://namenode_ip:50070

To get impala shell (on datanodes):

docker exec -it impalad bash

After get into bash, run:

$ . /etc/profile.d/globals.sh

$ impala_shell.sh

## All docker images can be found here:

https://hub.docker.com/u/yarivgraf

### Due to space issues, Binaries of Apache Impala are missing. the complete image can be found here:

https://hub.docker.com/r/yarivgraf/apache-impala-3.4.0

