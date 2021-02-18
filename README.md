# Creating Apache Spark cluster on Slum

## Usage
```
./create-spark-cluster -n nodes -m memory -c cpus -t time

nodes - integer (default: 1)
memory - integer, needs to end with K, M or G. eg. 4G (default: 4G)
cpus - integer (default: 4)
toime - integer, needs to end with s, m or h. eg. 30m (default: 1h)

```

## Output

Will output to spark_details.txt file and print to screen after sleeping.  
Example output:
```
Thu Feb 18 17:17:49 EST 2021: started Spark cluster master: spark://c15n10.ruddle.hpc.yale.internal:7077
Thu Feb 18 17:17:49 EST 2021: Spark Master UI  port: MasterUI' on port 8080.
Thu Feb 18 17:17:49 EST 2021: SLURM_JOB_ID: 11198281
```

## Connection
There are three possible connections when running hail on a Spark cluster:  
1. Connection to the Spark Master node UI
```
#ssh tunnel to local port 8020
ssh -f -N -L 8020:c15n10:4040 netid@ruddle.hpc.yale.edu

#Access using your browser by going to
http://localhost:8020
```
  
2. Hail connection to the Spark Master node
```
hl.init(master='spark://c15n10.ruddle.hpc.yale.internal:7077')

Running on Apache Spark version 2.4.1
SparkUI available at http://c13n10.ruddle.hpc.yale.internal:4040
Welcome to
     __  __     <>__
    / /_/ /__  __/ /
   / __  / _ `/ / /
  /_/ /_/\\_,_/_/_/   version 0.2.61-3c86d3ba497a
LOGGING: writing to /gpfs/ycga/home/ml2529/hail-20210218-1721-0.2.61-3c86d3ba497a.log
```

3. Connection to the Hail (application) Spark UI  
```
#ssh tunnel to local port 8021
ssh -f -N -L 8021:c13n10:4040 netid@ruddle.hpc.yale.edu

#Access using your browser by going to
http://localhost:8021
```

##TO DO
Make the output of the script more user friendly and fault tolerant



