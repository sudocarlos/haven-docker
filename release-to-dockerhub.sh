set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=sudocarlos
# image name
IMAGE=haven
# platforms
PLATFORM=linux/amd64
# bump version
version=`awk -F "=" '/TAG=/{print $NF}' Dockerfile`
echo "Building version: $version"
# run build
docker buildx build -t $USERNAME/$IMAGE:latest -t $USERNAME/$IMAGE:$version --push .
# tag it
git add -A
git commit -m "haven-docker $version"
git tag -a "dockerhub-$version" -m "haven-docker $version"
git push
git push --tags