#!/bin/bash

lookbackDate=`date -d "10 minutes ago" +"%Y-%m-%dT%H:%M:%S%z"`
echo $lookbackDate

while IFS= read -r c
do
	echo "Queuing...${c}"
	mongoexport \
	--config=/home/ubuntu/aws-prod-cs \
	--username=root \
	-d fhir_prod \
	-c $c \
	--jsonFormat=canonical \
	--query="{\"meta.lastUpdated\":{\"\$gte\":{\"\$date\":\"${lookbackDate}\"}}}" \
	| mongoimport \
	--config=/home/ubuntu/atlas-prod-cs \
	--username=pa-prod-service \
	-d fhir \
	-c $c \
	--mode=upsert \
	--stopOnError
done < "/home/ubuntu/collections.txt"
