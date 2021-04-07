#!/bin/bash
echo "$(hostname -i) $CLUSTER_NAME" >> /etc/hosts
namedir=`echo $HADOOP_CONF_DIR_dfs_namenode_name_dir | perl -pe 's#file://##'`
if [ ! -d $namedir ]; then
  echo "Namenode name directory not found: $namedir"
  exit 2
fi

if [ -z "$CLUSTER_NAME" ]; then
  echo "Cluster name not specified"
  exit 2
fi

if [ ! -d $namedir/current ]; then
  echo "Formatting namenode name directory: $namedir"
  $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format $CLUSTER_NAME -force
fi

$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode
