set -e

result_find=$(curl $API_BASE_URL/periodic-tasks/find\?name=taskname)

curl -X DELETE $API_BASE_URL/periodic-tasks/taskname/

result_create=$(curl -X POST -H "Content-Type: application/json" \
    -d "{\"status\": \"asdfdd\", \"name\": \"taskname\", \"task\": \"hello\", \"schedule\": \"* * * * *\"}" \
    $API_BASE_URL/periodic-tasks/)
echo $result_create | grep "taskname"

task_id=$(echo $result_create | jq .id)
result_latest=$(curl $API_BASE_URL/periodic-tasks/latest)
echo $result_latest | grep "\"id\":$task_id"

result_create=$(curl -X POST -H "Content-Type: application/json" \
    -d "{\"status\": \"asdfdd\", \"name\": \"taskname-2\", \"task\": \"hello\", \"schedule\": \"* * * * *\"}" \
    $API_BASE_URL/periodic-tasks/)
echo $result_create | grep "taskname-2"

# DELETE /periodic-tasks/taskname

curl -X DELETE $API_BASE_URL/periodic-tasks/taskname-2/

# UPDATE via POST /periodic-tasks

curl -X POST -H "Content-Type: application/json" \
    -d "{\"status\": \"asdfdd\", \"name\": \"taskname\", \"task\": \"hello2\", \"schedule\": \"2 * * * *\", \"resource_id\": \"333\", \"scheduler_id\": \"444\"}" \
    $API_BASE_URL/periodic-tasks/

result_find=$(curl $API_BASE_URL/periodic-tasks/find\?name=taskname)
echo $result_find | grep '"task":"hello2"'
echo $result_find | grep '333'
echo $result_find | grep '444'
