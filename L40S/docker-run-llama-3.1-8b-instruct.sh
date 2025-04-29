#!/bin/bash

# Copyright (c) 2024, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: MIT-0

set -euo pipefail
source .env

mkdir -p $HOME/.cache/nim

#docker run -itd --name=llama-3.1-8b-instruct \
  #-u root \
docker run -it --rm \
  --gpus all \
  --shm-size=16GB \
  -v "$HOME/.cache/nim:/opt/nim/.cache" \
  -p 8000:8000 \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2 \
  "$@"

exit $?


################################################################################
### This is a document, not meant as executable.
################################################################################
curl -s http://0.0.0.0:8000/v1/models | jq

curl -X 'POST' \
    'http://0.0.0.0:8000/v1/models' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
"model": "meta/llama-3.1-8b-instruct",
"prompt": "Once upon a time",
"max_tokens": 64
}' | jq

# Genai-perf:
# - nvcr.io/nvidia/tritonserver:24.08-py3-sdk
# - https://docs.nvidia.com/nim/benchmarking/llm/latest/step-by-step.html
#   * From: https://docs.nvidia.com/nim/large-language-models/latest/benchmarking.html
