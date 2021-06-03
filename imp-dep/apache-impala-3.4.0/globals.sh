export CLUSTER_NAME="namenode"
export HADOOP_CLASSPATH=":/opt/hadoop/jars/gcs-connector-hadoop2-latest.jar:/opt/spark/jars/gcs-connector-hadoop2-latest.jar"
export HADOOP_COMMON_HOME="/opt/hadoop"
export HADOOP_CONF_DIR="/opt/hadoop/conf"
export HADOOP_CONF_DIR_dfs_namenode_name_dir="file:///var/lib/hadoop-hdfs/cache/hdfs/dfs/name"
export HADOOP_HDFS_HOME="/opt/hadoop"
export HADOOP_HOME="/opt/hadoop"
export HADOOP_MAPRED_HOME="/opt/hadoop"
export HADOOP_VERSION="3.2.2"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/hadoop/bin:/opt/impala/bin:/opt/impala/shell"
export HIVE_HOME="/opt/hive/"
### Impala
export THRIFT_HOME="/opt/impala/toolchain/thrift-0.9.3-p7"
export IMPALA_HOME="/opt/impala"

# Add directories containing dynamic libraries required by the daemons that
# are not on the system library paths.
export LD_LIBRARY_PATH=/opt/impala/lib
LD_LIBRARY_PATH+=:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/
LD_LIBRARY_PATH+=:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/

# Add directory with optional plugins that can be mounted for the container.
LD_LIBRARY_PATH+=:/opt/impala/lib/plugins

# Configs should be first on classpath
export CLASSPATH=/opt/impala/conf
# Append all of the jars in /opt/impala/lib to the classpath.
for jar in /opt/impala/lib/*.jar
do
  CLASSPATH+=:$jar
done
#echo "CLASSPATH: $CLASSPATH"
#echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

# Default to 2GB heap. Allow overriding by externally-set JAVA_TOOL_OPTIONS.
#export JAVA_TOOL_OPTIONS="-Xmx2g $JAVA_TOOL_OPTIONS"

