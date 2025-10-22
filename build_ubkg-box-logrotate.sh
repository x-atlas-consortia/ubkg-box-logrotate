#!/bin/bash
# -------------------------
# Unified Biomedical Knowledge Graph (UBKG)
# Builds and pushes the ubkg-box-logrotate component of a UBKGBox multi-container application

if [ "$1" = "build" ]; then
  docker compose -f docker-compose.yml -p ubkg-box-logrotate build
elif [ "$1" = "push" ]; then
  # buildx uses docker-compose.yml to publish in multiple architectures
  docker buildx bake -f docker-compose.yml --push
fi