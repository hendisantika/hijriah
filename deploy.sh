#!/bin/bash
ssh -p "${SERVER_PORT}" "${SERVER_USERNAME}"@"${SERVER_HOST}" -i ~/.ssh/id_rsa -t -t -o StrictHostKeyChecking=no << 'ENDSSH'
set -e
cd ~/hijriah
cat .env
set +a
source .env
start=$(date +"%s")
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
docker pull $AWS_ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

# Remove the old container whatever its state (running, stopped or being removed)
docker rm -f $CONTAINER_NAME 2>/dev/null || true
while [ "$(docker ps -qa -f name=^/${CONTAINER_NAME}$)" ]; do sleep 1; done

docker run -d --rm -p $APP_PORT:$APP_PORT --env-file .env --name $CONTAINER_NAME $AWS_ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

# Wait until the app answers, otherwise fail the deploy
for i in $(seq 1 60); do
    if curl -fsS -o /dev/null http://localhost:$APP_PORT/; then
        echo "App is up on port $APP_PORT"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "App did not become healthy" >&2
        docker logs --tail 50 $CONTAINER_NAME || true
        exit 1
    fi
    sleep 2
done

# Clean up old images only after the new container is running
docker image prune -af --filter "until=24h" || true

end=$(date +"%s")
echo "Deployed in : $((end - start))s"
exit
ENDSSH
