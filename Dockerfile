FROM ubuntu:14.04

MAINTAINER Ma Jie <majie.cpp@gmail.com>

WORKDIR /root

# install openssh-server, wget
RUN apt-get update && apt-get install -y openssh-server wget

#install JDK
#COPY jdk-7u80-linux-x64.tar.gz ./
COPY jdk-8u121-linux-x64.tar.gz ./
RUN mkdir -p /usr/lib/jvm
#RUN tar xvf jdk-7u80-linux-x64.tar.gz && mv jdk1.7.0_80 /usr/lib/jvm/jdk1.7.0_80
RUN tar xvf jdk-8u121-linux-x64.tar.gz && mv jdk1.8.0_121 /usr/lib/jvm/jdk1.8.0_121
#ENV JAVA_HOME /usr/lib/jvm/jdk1.7.0_80
ENV JAVA_HOME /usr/lib/jvm/jdk1.8.0_121
ENV PATH $PATH:$JAVA_HOME/bin

# install & configure hadoop 2.7.3
# set environment variable for hadoop
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 
COPY hadoop-2.7.3.tar.gz ./
RUN tar xvf hadoop-2.7.3.tar.gz && mv hadoop-2.7.3 /usr/local/hadoop && \
    rm ./hadoop-2.7.3.tar.gz
RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/start-spark.sh ~/start-spark.sh

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x ~/start-spark.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x $HADOOP_HOME/etc/hadoop/hadoop-env.sh


# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

#install spark
COPY spark-2.1.0-bin-hadoop2.7.tgz ./
RUN tar xvf spark-2.1.0-bin-hadoop2.7.tgz && mv spark-2.1.0-bin-hadoop2.7 /usr/local/spark && \
    rm ./spark-2.1.0-bin-hadoop2.7.tgz
ENV SPARK_HOME /usr/local/spark
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin
#uploading spark jars onto hadoop
RUN cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
RUN echo spark.yarn.jars hdfs:///spark_jars/* >> $SPARK_HOME/conf/spark-defaults.conf

COPY config/slaves $SPARK_HOME/conf/slaves
RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
RUN echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> $SPARK_HOME/conf/spark-env.sh
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $SPARK_HOME/conf/spark-env.sh
RUN echo "export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server/:$JAVA_HOME/jre/../lib/amd64:/lib64:/lib:/usr/lib:$HADOOP_HOME/lib/native" >> $SPARK_HOME/conf/spark-env.sh

RUN mkdir /var/run/sshd
EXPOSE 22  
CMD ["/usr/sbin/sshd" "-D"] 

