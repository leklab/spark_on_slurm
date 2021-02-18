#!/bin/bash

#Wrapper script to create Spark cluster

while getopts n:m:c:t: flag
do
    case "${flag}" in
        n) nodes=${OPTARG};;
        m) mem=${OPTARG};;
        c) cpus=${OPTARG};;
        t) time=${OPTARG};;
    esac
done

echo "Starting a Spark cluster with the following resources:"
echo "nodes: ${nodes:-1}"
echo "mem: ${mem:-4G}"
echo "cpus: ${cpus:-4}"
echo "time: ${time:-1h}"

rm spark_details.txt

sbatch --nodes=${nodes:-1} --mem-per-cpu=${mem:-4G} --cpus-per-task=${cpus:-4} --ntasks-per-node=1 --export=time=${time:-1h} create-spark-cluster.cmd 

sleep 10

cat spark_details.txt


