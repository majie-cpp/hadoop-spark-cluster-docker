#!/bin/bash

echo ""

echo -e "\nbuild docker hadoop image\n"
docker build -t dockerhub.ygomi.com/spark:1.0 .

echo ""
