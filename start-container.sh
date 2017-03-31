#!/bin/bash

# the default node number is 3
N=${1:-2}

sudo docker network create --driver=bridge hadoop

# start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                -p 8080:8080 \
                -p 19922:22\
                --name hadoop-master \
                --hostname hadoop-master \
                dockerhub.ygomi.com/spark:1.0 /usr/sbin/sshd -D&> /dev/null


# start hadoop slave container
i=1
while [ $i -le $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                dockerhub.ygomi.com/spark:1.0 /usr/sbin/sshd -D&> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container
sudo docker exec -it hadoop-master bash
