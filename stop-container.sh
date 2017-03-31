# the default node number is 3
N=${1:-4}
echo "stop hadoop-master container..."
sudo docker container stop hadoop-master
# stop hadoop slave container
i=1
while [ $i -le $N ]
do
	echo "stop hadoop-slave$i container..."
	sudo docker container stop hadoop-slave$i
	i=$(( $i + 1 ))
done 
docker container ls
echo "done"
