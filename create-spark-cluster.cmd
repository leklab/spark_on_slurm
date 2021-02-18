#!/bin/bash
#SBATCH --output=sparkjob-%j.out

#Multi-node script taken from Stanford website https://www.sherlock.stanford.edu/docs/software/using/spark/

## --------------------------------------
## 0. Preparation
## --------------------------------------

#load the Spark module
#module load spark

export SPARK_HOME=/gpfs/ycga/project/lek/shared/tools/spark-2.4.3-bin-hadoop2.7
export PATH=$PATH:/gpfs/ycga/project/lek/shared/tools/spark-2.4.3-bin-hadoop2.7/bin
export PATH=$PATH:/gpfs/ycga/project/lek/shared/tools/spark-2.4.3-bin-hadoop2.7/sbin

module -q load GCC/5.4.0-2.26

# identify the Spark cluster with the Slurm jobid
export SPARK_IDENT_STRING=$SLURM_JOBID

# prepare directories
export SPARK_WORKER_DIR=${SPARK_WORKER_DIR:-$HOME/.spark/worker}
export SPARK_LOG_DIR=${SPARK_LOG_DIR:-$HOME/.spark/logs}
#export SPARK_LOCAL_DIRS=${SPARK_LOCAL_DIRS:-/tmp/spark}
export SPARK_LOCAL_DIRS=${SPARK_LOCAL_DIRS:-/tmp/${USER}/spark}
mkdir -p $SPARK_LOG_DIR $SPARK_WORKER_DIR

export SPARK_WORKER_OPTS="-Dspark.worker.cleanup.enabled=true -Dspark.worker.cleanup.interval=60 -Dspark.worker.cleanup.appDataTtl=60"

## --------------------------------------
## 1. Start the Spark cluster master
## --------------------------------------

start-master.sh
sleep 3
MASTER_URL=$(grep -Po '(?=spark://).*' \
             $SPARK_LOG_DIR/spark-${SPARK_IDENT_STRING}-org.*master*.out)

MASTER_UI_PORT=$(grep -Po 'MasterUI.*' \
             $SPARK_LOG_DIR/spark-${SPARK_IDENT_STRING}-org.*master*.out)


## --------------------------------------
## 2. Start the Spark cluster workers
## --------------------------------------

# get the resource details from the Slurm job
export SPARK_WORKER_CORES=${SLURM_CPUS_PER_TASK:-1}
export SPARK_MEM=$(( ${SLURM_MEM_PER_CPU:-4096} * ${SLURM_CPUS_PER_TASK:-1} ))M
export SPARK_DAEMON_MEMORY=$SPARK_MEM
export SPARK_WORKER_MEMORY=$SPARK_MEM
export SPARK_EXECUTOR_MEMORY=$SPARK_MEM

# start the workers on each node allocated to the tjob
export SPARK_NO_DAEMONIZE=1
srun  --output=$SPARK_LOG_DIR/spark-%j-workers.out --label \
      start-slave.sh ${MASTER_URL} &

d=`date`

echo "$d: started Spark cluster master: ${MASTER_URL}" >> spark_details.txt
echo "$d: Spark Master UI  port: ${MASTER_UI_PORT}" >> spark_details.txt
echo "$d: SLURM_JOB_ID: ${SLURM_JOBID}" >> spark_details.txt 

sleep ${time}

## --------------------------------------
## 4. Clean up
## --------------------------------------

# stop the workers
scancel ${SLURM_JOBID}.0

# stop the master
stop-master.sh


