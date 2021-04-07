FROM docker-hadoop-3.2.2

ARG HADOOP_VERSION=3.2.2
# ENV
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    HADOOP_VERSION=3.2.2 \
    HIVE_VERSION=3.1.2 \
    PATH=$PATH:/opt/hadoop/bin:/opt/hive/bin \
    CLUSTER_NAME=namenode \
    HADOOP_HOME=/opt/hadoop \
    HIVE_HOME=/opt/hive \
    HADOOP_CONF_DIR=/opt/hadoop/conf \
    HADOOP_MAPRED_HOME=/opt/hadoop \
    HADOOP_COMMON_HOME=/opt/hadoop \
    HADOOP_HDFS_HOME=/opt/hadoop \
    YARN_HOME=/opt/hadoop \
    HADOOP_CONF_DIR_dfs_namenode_name_dir=file:///var/lib/hadoop-hdfs/cache/hdfs/dfs/name 

# JAVA 
RUN apt-get update && \
	apt-get install -y wget libssl-dev libncurses5-dev cron libsqlite3-dev libreadline-dev libtk8.5 libgdm-dev libdb4o-cil-dev libpcap-dev zlib1g-dev libffi-dev build-essential vim host procps iputils-ping openjdk-8-jdk curl wget ca-certificates-java && \
	apt-get clean && \
        update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;
	
# Install hive
RUN mkdir -p /opt && \
    cd /opt && \
    curl https://downloads.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz | \
    tar -zx apache-hive-3.1.2-bin/ && \
    ln -s apache-hive-3.1.2-bin hive && \
    rm /opt/hive/lib/guava-19.0.jar && \
    ln -s /usr/share/java/postgresql-jdbc4.jar /opt/hive/lib/postgresql-jdbc.jar && \
    ln -s /usr/share/java/postgresql-jdbc4.jar /opt/hive/lib/postgresql-jdbc4.jar && \
    mkdir -p /opt/hive/conf && \
    mkdir -p /opt/hadoop/conf;

COPY hdfs-site.xml core-site.xml mapred-site.xml yarn-site.xml /opt/hadoop/conf/
COPY hive-site.xml hadoop-hive.env /opt/hive/conf/
COPY guava-27.0-jre.jar /opt/hive/lib/
COPY postgresql-jdbc4.jar /usr/share/java/
COPY run-metastore.sh /
