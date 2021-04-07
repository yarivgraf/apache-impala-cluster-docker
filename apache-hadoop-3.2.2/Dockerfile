FROM ubuntu:16.04

ARG HADOOP_VERSION=3.2.2
# ENV
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    HADOOP_VERSION=3.2.2 \
    PATH=$PATH:/opt/hadoop/bin \
    CLUSTER_NAME=namenode \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/conf \
    HADOOP_MAPRED_HOME=/opt/hadoop \
    HADOOP_COMMON_HOME=/opt/hadoop \
    HADOOP_HDFS_HOME=/opt/hadoop \
    YARN_HOME=/opt/hadoop \
    HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/opt/hadoop/jars/gcs-connector-hadoop2-latest.jar:/opt/spark/jars/gcs-connector-hadoop2-latest.jar \
    HADOOP_CONF_DIR_dfs_namenode_name_dir=file:///var/lib/hadoop-hdfs/cache/hdfs/dfs/name 

# JAVA 
RUN apt-get update && \
	apt-get install -y wget libssl-dev libncurses5-dev cron libsqlite3-dev libreadline-dev libtk8.5 libgdm-dev libdb4o-cil-dev libpcap-dev zlib1g-dev libffi-dev build-essential vim host procps iputils-ping openjdk-8-jdk curl wget ca-certificates-java && \
	apt-get clean && \
        update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;
	

# Install hadoop
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | \
    tar -zx hadoop-${HADOOP_VERSION}/ && \
    ln -s hadoop-${HADOOP_VERSION} hadoop && \
    echo Hadoop ${HADOOP_VERSION} native libraries installed in /opt/hadoop/lib/native && \
    mkdir -p /opt/hadoop/jars && \
    mkdir -p /var/lib/hadoop-hdfs/cache/hdfs/dfs/name && \
    mkdir -p /var/lib/hadoop-hdfs/cache/hdfs/dfs/data{0..4} && \
    mkdir -p /var/run/hadoop-hdfs && \
    mkdir -p /opt/hadoop/conf && \
    touch /var/log/cron.log && \
    touch /opt/hadoop/conf/dfs.exclude

COPY hdfs-site.xml core-site.xml mapred-site.xml yarn-site.xml /opt/hadoop/conf/


COPY run-namenode.sh run-datanode.sh provision-namenode.sh /
