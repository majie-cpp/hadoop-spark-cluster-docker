FROM ubuntu:14.04

MAINTAINER Ma Jie <majie.cpp@gmail.com>

WORKDIR /root

# install openssh-server, openjdk and wget
#RUN apt-get update && apt-get install -y openssh-server openjdk-7-jdk wget
RUN apt-get update && apt-get install -y openssh-server wget

# install hadoop 2.7.2
# RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
#    tar -xzvf hadoop-2.7.2.tar.gz && \
#    mv hadoop-2.7.2 /usr/local/hadoop && \
#    rm hadoop-2.7.2.tar.gz

#install JDK1.7
COPY jdk-7u80-linux-x64.tar.gz ./
RUN mkdir -p /usr/lib/jvm
RUN tar xvf jdk-7u80-linux-x64.tar.gz && mv jdk1.7.0_80 /usr/lib/jvm/jdk1.7.0_80
ENV JAVA_HOME /usr/lib/jvm/jdk1.7.0_80
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
#RUN $HADOOP_HOME/etc/hadoop/hadoop-env.sh
#RUN $HADOOP_HOME/sbin/start-dfs.sh
#RUN $HADOOP_HOME/sbin/start-yarn.sh
RUN cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
RUN echo spark.yarn.jars hdfs:///spark_jars/* >> $SPARK_HOME/conf/spark-defaults.conf
#!! temporarily change the core-site to localhost
# backup it
#RUN cp $HADOOP_HOME/etc/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml.bak
#RUN sed s/hadoop-master/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/core-site.xml > /tmp/core-site.xml
#RUN cp /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
#RUN /usr/sbin/sshd
#RUN $HADOOP_HOME/bin/hdfs dfsadmin -safemode leave && \
#    $HADOOP_HOME/bin/hdfs/hdfs dfs -mkdir /spark_jars && \
#    $HADOOP_HOME/bin/hdfs/hdfs dfs -put $SPARK_HOME/jars/* /spark_jars
# restore it
#RUN cp $HADOOP_HOME/etc/hadoop/core-site.xml.bak $HADOOP_HOME/etc/hadoop/core-site.xml

COPY config/slaves $SPARK_HOME/conf/slaves
RUN cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
RUN echo "export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" >> $SPARK_HOME/conf/spark-env.sh
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $SPARK_HOME/conf/spark-env.sh
RUN echo "export LD_LIBRARY_PATH=/usr/bin/bigdata/jdk1.6.0_45/jre/lib/amd64/server:/usr/bin/bigdata/jdk1.6.0_45/jre/lib/amd64:/usr/bin/bigdata/jdk1.6.0_45/jre/../lib/amd64:/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib:$HADOOP_HOME/lib/native" >> $SPARK_HOME/conf/spark-env.sh

RUN mkdir /var/run/sshd
EXPOSE 22  
CMD ["/usr/sbin/sshd" "-D"] 

