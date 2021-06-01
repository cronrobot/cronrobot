set -e

curl localhost:8000/api/ok | grep status
curl localhost:8000/api/ok | grep ok

echo "all good"