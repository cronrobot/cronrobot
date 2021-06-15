set -e

result_find=$(curl $API_BASE_URL/periodic-tasks/find\?name=taskname)

if [ ! -z "${result_find}" ]; then
    task_to_delete=$(echo $result_find | jq .id)
    curl -X DELETE $API_BASE_URL/periodic-tasks/$task_to_delete/
fi

result_create=$(curl -X POST -H "Content-Type: application/json" \
    -d "{\"status\": \"asdfdd\", \"name\": \"taskname\", \"task\": \"hello\", \"schedule\": \"* * * * *\"}" \
    $API_BASE_URL/periodic-tasks/)
echo $result_create | grep "taskname"

task_id=$(echo $result_create | jq .id)
result_latest=$(curl $API_BASE_URL/periodic-tasks/latest)
echo $result_latest | grep "\"id\":$task_id"