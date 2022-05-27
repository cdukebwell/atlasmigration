#!/bin/bash

lookbackDate=`date -d "1 hours ago" +"%Y-%m-%dT%H:%M:%S%z"`
echo $lookbackDate

while IFS= read -r c
do
	echo "Queuing...${c}"
	mongodump \
	--config=/home/ubuntu/aws-prod-cs \
	--username=root \
	-d fhir_prod \
	-c $c \
	--gzip --archive \
	--query="{\"meta.lastUpdated\":{\"\$gte\":{\"\$date\":\"${lookbackDate}\"}}}" \
| mongorestore \
	--config=/home/ubuntu/atlas-prod-cs \
	--username=root \
	--stopOnError \
	--numInsertionWorkersPerCollection=10 \
	--nsFrom="fhir_prod.*" \
	--nsTo="fhir.*" \
	--gzip --archive 2> /tmp/mongosync-prod-$c-$lookbackDate.error.log
done < "/home/ubuntu/collections.txt"

