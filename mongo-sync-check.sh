#!/bin/bash

while IFS= read -r c
do
	aws_collection_count=`mongosh mongodb://<connection string>/db --tls true --tlsCAFile rds-combined-ca-bundle.pem --quiet --eval "db.${c}.countDocuments()"`
	atlas_collection_count=`mongosh mongodb+srv://<clustername>.mongodb.net/db --quiet --eval "db.${c}.countDocuments()"`
	if [ $aws_collection_count -ne $atlas_collection_count ] ; then
		printf "AWS.%s %s \n" $c $aws_collection_count
		printf "ATLAS.%s  %s\n" $c $atlas_collection_count
	else
		printf "%s synced %s \n" $c $aws_collection_count
	fi
done < "collections.txt"
