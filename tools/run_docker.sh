#!/usr/bin/env bash
project_name="cpp_base_project"

# Build the docker environment
docker build -t ${project_name} --network=host .

# Run the compilation for the first time
docker run --rm -it \
   --user=$(id -u) \
   --volume="$(pwd)/..:/home/project" \
   --workdir=/home/project \
   ${project_name}:latest ./release.sh

# Start a bash shell for the user
docker run --rm -it \
   --user=$(id -u) \
   --env="DISPLAY" \
   --volume="/etc/group:/etc/group:ro" \
   --volume="/etc/passwd:/etc/passwd:ro" \
   --volume="/etc/shadow:/etc/shadow:ro" \
   --volume="/etc/sudoers.d:/etc/sudoers.d:ro" \
   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
   --volume="$(pwd)/..:/home/project" \
   --workdir=/home/project/build/Docker_Release \
   ${project_name}:latest
