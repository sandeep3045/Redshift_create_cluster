# ===========================================================================
# Configuration File for Redshift Creation/Deletion/Listing clusters
# ===========================================================================

REDSHIFT_CLUSTER_TYPE=multi-node
REDSHIFT_DB="perf-test"
REDSHIFT_DB_USER=sys_admin
REDSHIFT_DB_PASSWORD=pass
REDSHIFT_SCHEMA=perf
REDSHIFT_PORT=5439
REDSHIFT_AZ=us-east-1b
DATE_STAMP=`date +%s`
LOGFILE=/tmp/redshift_provision_${DATE_STAMP}.log
REGION=`/usr/local/bin/aws configure list |grep region| head -1 | awk '{print $2}'|sed 's/<//'`
EC2_BLOCK_DEVICE_MAPPING="[{\"DeviceName\":\"/dev/xvda\",\"Ebs\":{\"VolumeSize\":40,\"DeleteOnTermination\":true}}]"
EC2_TAG="ResourceType=instance,Tags=[{Key=Name,Value=perf-test}]"
EC2_STATE=`aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query 'Reservations[*].Instances[*].[State.Name]' --output text`
REDSHIFT_VPC_SECURITY_GROUP_ID="sg-00qwerty00 sg-00asdfg00"
#REDSHIFT_IAM_ROLE_ARN="arn:aws:iam::000000000:role/Redshift" "arn:aws:iam::000000000:role/Role"
EC2_IMAGE_ID=ami-00abcd00
EC2_SUBNET_ID=subnet-0abcd0
EC2_KEY_NAME=keypair
EC2_INSTANCE_TYPE=t2.medium
EC2_IAM_INST_PROFILE=arn:aws:iam::00000000:instance-profile/ec2
EC2_SECURITY_GROUP="sg-00qwerty00 sg-00asdfg00"
REDSHIFT_PARAMETER_GROUP=`/usr/local/bin/aws redshift describe-clusters |grep ParameterGroupName|awk '{print $2}'|sed 's/"//g'|sed 's/,//'| head -1`
EC2_INSTANCE_ID=`/usr/local/bin/aws ec2 describe-instances --filters 'Name=tag:Name,Values=perf-test'|grep InstanceId| awk '{print $2}'|sed 's/"//g'|sed 's/,//'`
#REDSHIFT_VPC_SECURITY_GROUP_ID=`/usr/local/bin/aws redshift describe-clusters |grep VpcSecurityGroupId |awk '{print $2}'|sed 's/"//g' |head -2`
REDSHIFT_SUBNETGROUP=`/usr/local/bin/aws redshift describe-clusters --region $REGION |grep ClusterSubnetGroupName |head -1 |awk '{print $2}'|sed 's/"//g'|sed 's/,//'`
REDSHIFT_IAM_ROLE_ARN=`/usr/local/bin/aws redshift describe-clusters --region $REGION |grep IamRoleArn |awk '{print $2}'|sed 's/"//g'|sed 's/,//' | tail -2`
#EC2_IMAGE_ID=`/usr/local/bin/aws ec2 describe-instances --region $REGION |grep ImageId |awk '{print $2}'|sed 's/"//g'|sed 's/,//'|tail -1`
#EC2_SUBNET_ID=`/usr/local/bin/aws ec2 describe-instances --region $REGION |grep SubnetId |awk '{print $2}'|sed 's/"//g'|sed 's/,//'|tail -1`
#EC2_IAM_INST_PROFILE=`/usr/local/bin/aws ec2 describe-instances --region $REGION |grep Arn |awk '{print $2}'|sed 's/"//g'|sed 's/,//'|tail -1`
#EC2_SECURITY_GROUP=`/usr/local/bin/aws ec2 describe-instances --region $REGION |grep GroupId |awk '{print $2}'|sed 's/"//g'|sort --unique|tail -2`
#REDSHIFT_CLUSTER_IDENTIFIER=testcluster
