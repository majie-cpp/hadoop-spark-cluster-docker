o. Please note:
You will need to manually download the following packages before you build the docker images:
    hadoop-2.7.3.tar.gz
    jdk-8u121-linux-x64.tar.gz
    spark-2.1.0-bin-hadoop2.7.tgz 
They need to be placed in the same folder as Dockerfile

o. Build the docker image:
build-image.sh

o. Start the containers
start-container.sh
By default, 1 master 2 slaves docker containers are started.
To add more slaves, run the script: resize-cluster.sh [slaves num] 

o. Stop the containers
stop-container.sh

o. Start Hadoop, Spark on master nodes
Enter the bash of the master node, and run:
start-spark.sh 

This script calls start-hadoop.sh to start hadoop/yarn first, then spark cluster.
hadoop cluster can be start seperately by executing start-hadoop.sh



