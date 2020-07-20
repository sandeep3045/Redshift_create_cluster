#!/bin/bash
# ===========================================================================
# Function to create schema and connect PSQL database
# ===========================================================================

create_schema()
{
 dbname=$REDSHIFT_DB
 scname=$REDSHIFT_SCHEMA
 host=`/usr/local/bin/aws ec2 describe-instances --filter "Name=tag:Name,Values=perf-test" --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], PrivateIpAddress, State.Name]" --output text | awk '{print $2}'| tail -1`

endp=`/usr/local/bin/aws redshift describe-clusters --cluster-identifier $REDSHIFT_CLUSTER_IDENTIFIER --query "Clusters[*].Endpoint.Address" --output text`
sshpass -p 'abcde' scp ddl.sql liquibase@$host:/home/liquibase

sshpass -p 'abcde' ssh -o StrictHostKeyChecking=no -l liquibase $host  <<EOF1
echo "export PGCLIENTENCODING=UTF8" > dbconfig.cfg
echo "export PGHOST=$endp" >> dbconfig.cfg
echo "export PGPORT=5439" >> dbconfig.cfg
echo "export PGDATABASE=perf-test" >> dbconfig.cfg
echo "export PGUSER=sys_admin" >> dbconfig.cfg
echo "export PGPASSWORD=pass">> dbconfig.cfg
. dbconfig.cfg
psql -c "create schema $scname"
if [ $? -eq 0 ]
then
echo "INFO: Schema created."
fi
psql  <<EOF
\i /home/liquibase/ddl.sql
EOF
echo "INFO: Tables are created."
EOF1

}
