#!/bin/bash

# ===========================================================================
# Redshift Main script
# Main script call the function and config scripts to perform below opearion
# [-c: Create Redshift, -d: Delete, -l: List, -h: Help, -e: Create EC2, -s: Create Schema]
# ===========================================================================


# Sourcing redshift funtion file
source ./redshift_func.sh
source ./create_schema.sh

command=$1

if [[ -z "${command}" ]]; then
echo "Command not provided"
sh redshift_main.sh -h
exit 1
fi

if [[ "${command}" == "-h" ]]; then
echo '
Please follow the below usage of the script

Usage:
------
sh redshift_main.sh <c/l/d/e/s> <Clustername> <NumOfNode> <NodeType>

Example:
--------
-> sh redshift_main.sh -c testcluster 2 dc2.8xlarge #-c to create cluster needs 3 input <Clustername> <NumOfNode> <NodeType>

-> sh redshift_main.sh -d testcluster               #-d to delete_cluster needs 1 input <Clustername>

-> sh redshift_main.sh -l                           #-l to List all Redshift cluster

-> sh redshift_main.sh -e                           #-e to Create EC2 'perf-test' instance

-> sh redshift_main.sh -s                           #-s to Create Schema and load DDL
'
exit 0;
fi

if [[ "${command}" == "-c" ]]; then
        create_cluster $2 $3 $4

elif [[ "${command}" == "-d" ]]; then
        delete_cluster $2

elif [[ "${command}" == "-l" ]]; then
        list_cluster

elif [[ "${command}" == "-e" ]]; then
        create_instance

elif [[ "${command}" == "-s" ]]; then
        create_schema
else
        echo "Command not supported ${command} "
        echo "supported command [-c: Create Redshift, -d: Delete, -l: List, -h: Help, -e: Create EC2, -s: Create Schema]"

fi

