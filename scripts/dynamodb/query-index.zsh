#!/bin/zsh

if ! command -v jq &>/dev/null; then
  echo "You need to install jq"
  exit 1
fi

if ! command -v aws &>/dev/null; then
  echo "You need to install aws-cli"
  exit 1
fi

export AWS_PROFILE=default
export AWS_PAGER=

ENVIRONMENT=staging

# INPUTS
ACCOUNT_ID="<ID>"
OUTPUT_FILE_NAME="result.json"

# DynamoDB params
TABLE="$ENVIRONMENT-some_name"
INDEX="someIndex"

HK="usr#$ACCOUNT_ID"
RK="setting#"

EXPRESSION_ATTRIBUTE_VALUES=$(jq -n \
                  --arg hk "$HK" \
                  --arg rk "$RK" \
                  '{":hk":{"S": $hk }, ":rk":{"S": $rk}}' )

aws dynamodb query --table $TABLE \
                   --index-name $INDEX \
                   --key-condition-expression "GSI1HK = :hk and begins_with(GSI1RK,:rk)" \
                   --expression-attribute-values "$EXPRESSION_ATTRIBUTE_VALUES"  \
                   --query 'Items[*]' >> "$OUTPUT_FILE_NAME"