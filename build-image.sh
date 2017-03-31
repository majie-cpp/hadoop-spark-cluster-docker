#!/bin/bash

echo ""

echo -e "\nbuild docker hadoop image\n"
# sudo docker build -t kiwenlau/hadoop:1.0 .
docker build -t dockerhub.ygomi.com/spark:1.0 .

echo ""
