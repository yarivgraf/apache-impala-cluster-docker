#!/bin/bash

$HADOOP_HOME/bin/hdfs dfs -mkdir /tmp
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -mkdir /spark-logs
$HADOOP_HOME/bin/hdfs dfs -mkdir /raw
$HADOOP_HOME/bin/hdfs dfs -chmod 777 /raw
$HADOOP_HOME/bin/hdfs dfs -chmod 777 /spark-logs
$HADOOP_HOME/bin/hdfs dfs -chmod 777 /tmp
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /user

