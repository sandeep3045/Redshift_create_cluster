# Redshift_create_cluster
This script is used for performing below functionality in AWS redshift

Redshift_main.sh is main script which calls other script

Redshift_func.sh contains functions for Listing/creating/deleting Redshift Cluster and EC2 Instance

Redshift_config.sh contains all the variables needed for creating cluster and EC2

#-------------------------------------------
# Syntax for running script
#-------------------------------------------
-> sh redshift_main.sh -c testcluster 2 dc2.8xlarge #-c to create cluster needs 3 input <Clustername> <NumOfNode> <NodeType>

-> sh redshift_main.sh -d testcluster               #-d to delete cluster needs 1 input <Clustername>

-> sh redshift_main.sh -l                           #-l to List all Redshift cluster

-> sh redshift_main.sh -e                           #-e to Create EC2 'perf-test' instance

-> sh redshift_main.sh -s                           #-s to Create Schema and load DDL

