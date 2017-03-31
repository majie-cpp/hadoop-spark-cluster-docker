#!/bin/bash

# Uploading spark jars onto HDFS. 
# This way the spark jars are shared in HDFS to avoid 
# distributing spark jars each time an application is launched
# refer to the spark doc of spark.yarn.jars for details.
# spark.yarn.jars MUST be set into $SPARK_HOME/conf/spark-defaults.conf
# in Dockerfile.
echo "Starting hadoop cluster ..."
~/start-hadoop.sh
echo "hadoop cluster started."
jps
echo "Uploading spark jars on to hdfs:///spar_jars ..."
hdfs dfs -mkdir /spark_jars && \
hdfs dfs -put $SPARK_HOME/jars/* /spark_jars
echo "Uploading jars done."
$SPARK_HOME/sbin/start-all.sh
jps
