#!/bin/bash
export REGION='us-west-2'

if [ "$REGION" == "us-east-1" ]; then
    export env="prod"
else
    export env="qa"
fi

MEMSQL_PREFIX="${memsql:-memsql}"
export MASTER_AGG_ROLE="${MEMSQL_PREFIX}_master_aggregator"
export CHILD_AGG_ROLE="${MEMSQL_PREFIX}_child_aggregator"
export LEAF_ROLE="${MEMSQL_PREFIX}_leaf"
export LEAF_COUNT=${WORKER_COUNT:-2}
export AZ=${MEMSQL_AZ:-${REGION}a}

#master aggregators
knife ec2 server create -r "role[${MASTER_AGG_ROLE}]" -i ~/.ssh/key-pair-2.pem -E ${env} -S key-pair-2 -N ${MASTER_AGG_ROLE//_/-}-01 -f r3.xlarge -g sg-c47151f7 -Z "$AZ" -I ami-5189a661

#child aggregators
knife ec2 server create -r "role[${CHILD_AGG_ROLE}]" -i ~/.ssh/key-pair-2.pem -E ${env} -S key-pair-2 -N ${CHILD_AGG_ROLE//_/-}-01 -f r3.xlarge -g sg-c47151f7 -Z "$AZ" -I ami-5189a661

sleep 10

knife ec2 server create -r "role[${CHILD_AGG_ROLE}]" -i ~/.ssh/key-pair-2.pem -E ${env} -S key-pair-2 -N ${CHILD_AGG_ROLE//_/-}-02 -f r3.xlarge -g sg-c47151f7 -Z "$AZ" -I ami-5189a661

for (( c=1; c<=$LEAF_COUNT; c++ )); do
  sleep 10
  knife ec2 server create -r "role[${LEAF_ROLE}]" -i ~/.ssh/key-pair-2.pem -E ${env} -S key-pair-2 -N $(printf "%s%02d" "${LEAF_ROLE//_/-}"-0$c) -f r3.xlarge -g sg-c47151f7 -Z "$AZ" -I ami-5189a661
done

