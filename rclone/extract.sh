docker build -t rclone-arm64 .
docker create --name extract rclone-arm64
docker cp extract:/rclone-arm64 ./rclone
docker rm extract
docker image rm rclone-arm64