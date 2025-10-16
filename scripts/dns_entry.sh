#!/bin/bash

DOMAIN="vijaydurai.fun"
HOSTED_ZONE_ID="Z001220415FTGILNV1E5J"
NEW_RECORD_NAME="$(hostname).${DOMAIN}"
NEW_IP_ADDRESS="$(dig +short myip.opendns.com @resolver1.opendns.com)"
TTL=60

# Add the new record to the existing set

NEW_RECORD='{
  "Action": "UPSERT",
  "ResourceRecordSet": {
    "Name": "'"$NEW_RECORD_NAME"'",
    "Type": "A",
    "TTL": '$TTL',
    "ResourceRecords": [
      {
        "Value": "'"$NEW_IP_ADDRESS"'"
      }
    ]
  }
}'


# Create a temporary JSON file for the change batch

echo "{\"Changes\": [$NEW_RECORD]}" > change-batch.json

# Use AWS CLI to change resource record sets

aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --change-batch file://change-batch.json

# Clean up the temporary JSON file

rm -f change-batch.json

