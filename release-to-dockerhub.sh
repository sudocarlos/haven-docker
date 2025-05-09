set -ex
# SET THE FOLLOWING VARIABLES
USERNAME=sudocarlos # docker hub username
IMAGE=haven # image name
PLATFORM=linux/amd64 # platforms
VERSION=`awk -F "=" '/TAG=/{print $NF}' Dockerfile` # bump version

# run build
echo "Building version: $VERSION"
docker buildx build --no-cache -t $USERNAME/$IMAGE:latest -t $USERNAME/$IMAGE:$VERSION --push .

# tag it
git add -A
git commit -m "haven-docker $VERSION"
git tag -a "dockerhub-$VERSION" -m "haven-docker $VERSION"
git push
git push --tags