#!/bin/bash

# Configuration
DOMAIN="vijaydurai.fun"
HOSTED_ZONE_ID="Z001220415FTGILNV1E5J"
RECORD_NAME="$(hostname).${DOMAIN}"
TTL=60

# 1. Get Current Public IP (Using curl for better compatibility)
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)

if [ -z "$CURRENT_IP" ]; then
    echo "[ERROR] Could not determine public IP."
    exit 1
fi

# 2. Get Registered IP from Route53
# We add a trailing dot to the record name as Route53 stores it that way
REGISTERED_IP=$(aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Name == '${RECORD_NAME}.'] .ResourceRecords[0].Value" \
    --output text)

echo "----------------------------------------"
echo "DNS Update Check for: $RECORD_NAME"
echo "Current Public IP   : $CURRENT_IP"
echo "Route53 Registered  : $REGISTERED_IP"
echo "----------------------------------------"

# 3. Compare and Update
if [ "$CURRENT_IP" == "$REGISTERED_IP" ]; then
    echo "[SUCCESS] IP addresses match. No update needed."
    exit 0
fi

echo "[INFO] IP Mismatch or Record Missing. Initiating Update..."

# 4. Create Change Batch JSON
cat > change-batch.json <<EOF
{
  "Comment": "Auto-update via Terraform User Data",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "A",
        "TTL": $TTL,
        "ResourceRecords": [
          {
            "Value": "$CURRENT_IP"
          }
        ]
      }
    }
  ]
}
EOF

# 5. Execute Update
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch file://change-batch.json

# 6. Cleanup
rm -f change-batch.json
echo "[SUCCESS] Update request submitted successfully."
