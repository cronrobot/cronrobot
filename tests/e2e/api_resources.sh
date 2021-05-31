
set -e

# create
resource_name="resource10"
to_create='{"name": "'"$resource_name"'", "reference_id": "11233", "data": "MYDATA"}'
result_create=$(curl -X POST -H "Content-Type: application/json" -d "$to_create" $API_BASE_URL/resources/)

created_resource_id=$(echo "$result_create" | jq .id)

# GET it
echo "getting $created_resource_id"
curl $API_BASE_URL/resources/$created_resource_id/ | grep "$resource_name"

# delete it
echo "deleting $created_resource_id"
curl -X DELETE $API_BASE_URL/resources/$created_resource_id/