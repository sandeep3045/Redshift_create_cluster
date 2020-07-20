#!/bin/bash
#############################################
# Created: Sandeep Sharma
# Date   : 20-Jul-2020
#############################################
#-----------------------------------------------------------------------
#Functions for redshift operation

source ./redshift_config.sh

create_cluster()
{
# ----------------------------------------------------------------------------------
# Function for creating redshift cluster
# Accepts 3 argument:
#       Cluster name []
#       Number of Nodes [2,4,6,8]
#       Number of Nodes [dc2.large,dc2.8xlarge,ds2.xlarge,ds2.8xlarge,ra3.4xlarge]
#----------------------------------------------------------------------
#----------------------------------------------------------------------------------
REDSHIFT_CLUSTER_IDENTIFIER=$1
REDSHIFT_NUM_NODES=$2
REDSHIFT_NODE_TYPE=$3

        echo "INFO: Creating Redshift cluster $REDSHIFT_CLUSTER_IDENTIFIER" >> $LOGFILE 2>&1
        #echo "REDSHIFT_CLUSTER_IDENTIFIER=$REDSHIFT_CLUSTER_IDENTIFIER" >> redshift_config.sh

        /usr/local/bin/aws redshift create-cluster \
                --db-name $REDSHIFT_DB \
                --cluster-identifier $REDSHIFT_CLUSTER_IDENTIFIER \
                --cluster-type $REDSHIFT_CLUSTER_TYPE \
                --node-type $REDSHIFT_NODE_TYPE \
                --master-username $REDSHIFT_DB_USER \
                --master-user-password $REDSHIFT_DB_PASSWORD \
                --number-of-nodes $REDSHIFT_NUM_NODES \
                --no-publicly-accessible \
                --vpc-security-group-ids $REDSHIFT_VPC_SECURITY_GROUP_ID \
                --iam-roles $REDSHIFT_IAM_ROLE_ARN \
                --cluster-subnet-group-name $REDSHIFT_SUBNETGROUP \
                --availability-zone $REDSHIFT_AZ \
                --cluster-parameter-group-name $REDSHIFT_PARAMETER_GROUP \
                --automated-snapshot-retention-period 1 \
                --manual-snapshot-retention-period 1  >> $LOGFILE 2>&1

# Waiting for cluster to be available
        echo "INFO: Waiting for cluster $REDSHIFT_CLUSTER_IDENTIFIER to be available" >> $LOGFILE 2>&1
        /usr/local/bin/aws redshift wait cluster-available --cluster-identifier $REDSHIFT_CLUSTER_IDENTIFIER >> $LOGFILE 2>&1
        #sleep 10

        ENDPOINT=`/usr/local/bin/aws redshift describe-clusters --cluster-identifier $REDSHIFT_CLUSTER_IDENTIFIER --query "Clusters[*].Endpoint.Address" --output text`

        echo "INFO: Redshift cluster is created. Endpoint: $ENDPOINT Port: $REDSHIFT_PORT" >> $LOGFILE 2>&1

#---------------------------------------------------------------------------------------------------------
# EC2 Create has been moved into different block
#---------------------------------------------------------------------------------------------------------
#  echo "INFO: Creating EC2 Instance" >> $LOGFILE 2>&1
#       /usr/local/bin/aws ec2 run-instances \
#                               --image-id $EC2_IMAGE_ID \
#                               --instance-type t2.medium \
#                               --count 1 \
#                               --subnet-id $EC2_SUBNET_ID \
#                               --key-name $EC2_KEY_NAME \
#                                --iam-instance-profile Arn=$EC2_IAM_INST_PROFILE \
#                               --security-group-ids $EC2_SECURITY_GROUP \
#                                --block-device-mappings $EC2_BLOCK_DEVICE_MAPPING \
#                               --tag-specifications $EC2_TAG >> $LOGFILE 2>&1

#        EC2_INST=`/usr/local/bin/aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], PrivateIpAddress, State.Name]" --output text`

#       EC2_STATE='aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text'

#        while [ "$EC2_STATE" != "running" ]
#        do
#                EC2_STATE=`aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text | tail -1`
#                echo "EC2 Instance is in State: $EC2_STATE" >> $LOGFILE 2>&1

#        done

#        echo "INFO: EC2-Instance created: $EC2_INST" >> $LOGFILE 2>&1

}

list_cluster()
{
        LIST=`/usr/local/bin/aws redshift describe-clusters |grep ClusterIdentifier|awk '{print $2}'|sed 's/"//g'|sed 's/,//'`
        echo "INFO: List of Running Redshift cluster:$LIST" >> $LOGFILE 2>&1
}

delete_cluster()
{
# ----------------------------------------------------------------------------------
# Function for deleting redshift cluster
# Accepts 1 argument: Cluster name []
#  ----------------------------------------------------------------------------------
        cluster=$1
        /usr/local/bin/aws redshift describe-clusters --cluster-identifier "$cluster" >> $LOGFILE 2>&1
        cluster_exists="$?"

        if [[ "$cluster_exists" != "0" ]]; then
                echo "INFO: Could not find $cluster. It may already be deleted." >> $LOGFILE 2>&1
                exit 0
        fi
        if [[ -z "${EC2_INSTANCE_ID}" ]]; then

                echo "INFO: Could not find Instance perf-test. It may already be deleted." >> $LOGFILE 2>&1
                #exit 0
        else
                echo "INFO: Deleting instance perf-test: $EC2_INSTANCE_ID" >> $LOGFILE 2>&1
                /usr/local/bin/aws ec2 terminate-instances \
                        --region ${REGION} \
                        --instance-ids ${EC2_INSTANCE_ID} >> $LOGFILE 2>&1

                EC2_STATE=`aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text | tail -1`

                while [ "$EC2_STATE" != "terminated" ]
                do
                        EC2_STATE=`aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text | tail -1`
                        echo "INFO: EC2 Instance is in State: $EC2_STATE" >> $LOGFILE 2>&1

                done

                echo "INFO: EC2-Instance perf-test is Terminated" >> $LOGFILE 2>&1

        fi
        echo "INFO: Deleting redshift cluster: $cluster" >> $LOGFILE 2>&1

        /usr/local/bin/aws redshift delete-cluster --cluster-identifier $cluster --skip-final-cluster-snapshot >> $LOGFILE 2>&1

        echo "INFO: waiting for cluster to be deleted" >> $LOGFILE 2>&1

        deleted="$?"
        if [[ "$deleted" -eq 0 ]]; then
                /usr/local/bin/aws redshift wait cluster-deleted --cluster-identifier $cluster
                echo "INFO: Redshift cluster $cluster has been deleted" >> $LOGFILE 2>&1
        else
                echo "Could not delete $cluster. It may have already been deleted." >> $LOGFILE 2>&1
                exit 1
        fi
sleep 5
}
create_instance()
{
# ----------------------------------------------------------------------------------
# Function for Creating EC2 Instance
#
# ----------------------------------------------------------------------------------

        echo "INFO: Creating EC2 Instance" >> $LOGFILE 2>&1

        /usr/local/bin/aws ec2 run-instances \
                                --image-id $EC2_IMAGE_ID \
                                --instance-type t2.medium \
                                --count 1 \
                                --subnet-id $EC2_SUBNET_ID \
                                --key-name $EC2_KEY_NAME \
                                --iam-instance-profile Arn=$EC2_IAM_INST_PROFILE \
                                --security-group-ids $EC2_SECURITY_GROUP \
                                --block-device-mappings $EC2_BLOCK_DEVICE_MAPPING \
                                --tag-specifications $EC2_TAG >> $LOGFILE 2>&1

        EC2_INST=`/usr/local/bin/aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], PrivateIpAddress, State.Name]" --output text`

        EC2_STATE=`aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text | tail -1`

        while [ "$EC2_STATE" != "running" ]
        do
                EC2_STATE=`aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text | tail -1`
                echo "INFO: EC2 Instance is in State: $EC2_STATE" >> $LOGFILE 2>&1

        done

        echo "INFO: EC2-Instance created: $EC2_INST" >> $LOGFILE 2>&1
exit 0
}
