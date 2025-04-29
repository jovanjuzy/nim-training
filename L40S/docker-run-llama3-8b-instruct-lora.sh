#!/bin/bash

# Copyright (c) 2024, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: MIT-0

## Exercise: cache the base model before endpoint deployment.

# https://developer.nvidia.com/blog/deploy-multilingual-llms-with-nvidia-nim
# https://docs.nvidia.com/nim/large-language-models/latest/peft.html

# Pre-requisites: you've downloaded the lora adapters.
# See:
# - docker-run-llama3-8b-instruct-lora-download-to-cache.sh
# - docker-run-llama3-8b-instruct-lora-safetensors2bin.sh
# - the `ngc registry ...` command to download the math adapters.

set -euo pipefail
source .env

declare -a LORA_ARGS=(
  -e NIM_PEFT_SOURCE=/opt/nim/.cache/loras
  -e NIM_PEFT_REFRESH_INTERVAL=3600
  -e NIM_MAX_LORA_RANK=64

  ####
  ## Choose one of these L40S (tp=1) LoRA profiles. By defualt, trt backend is chosen.
  #-e NIM_MODEL_PROFILE="388140213ee9615e643bda09d85082a21f51622c07bde3d0811d7c6998873a0b"   # (tensorrt_llm-l40s-fp16-tp1-throughput-lora)
  #-e NIM_MODEL_PROFILE="8d3824f766182a754159e88ad5a0bd465b1b4cf69ecf80bd6d6833753e945740"   # (vllm-fp16-tp1-lora)
  #
  # Other images: list-model-profiles to show all the profiles compatible with the available GPU.
  ####
)

#docker run -itd --name=llama3-8b-instruct \
  #--gpus all \
  #-u root \
  #-p 8001:8000 \
docker run -it --rm  \
  --gpus 'device=1' \
  --shm-size=16GB \
  -v "$HOME/.cache/nim:/opt/nim/.cache" \
  -u $(id -u) \
  -p 8000:8000 \
  -e NGC_API_KEY \
  "${LORA_ARGS[@]}" \
  nvcr.io/nim/meta/llama3-8b-instruct:1.0.3 "$@"

exit $?


################################################################################
### This is a document, not meant as executable.
################################################################################
curl -s http://0.0.0.0:8000/v1/models | jq

curl -s -X 'POST' \
  'http://0.0.0.0:8000/v1/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
"model": "meta/llama3-8b-instruct",
"prompt": "介绍一下机器学习",
"max_tokens": 512
}' | jq

curl -s -X 'POST' \
  'http://0.0.0.0:8000/v1/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
"model": "LLama3-Gaja-Hindi-8B-Instruct-alpha",
"prompt": "मैं अपने समय प्रबंधन कौशल को कैसे सुधार सकता हूँ? मुझे पांच बिंदु बताएं और उनका वर्णन करें।",
"max_tokens": 512
}' | jq

curl -s -X 'POST' \
  'http://0.0.0.0:8000/v1/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
"model": "llama-3-8b-instruct-262k-chinese-lora",
"prompt": "介绍一下机器学习",
"max_tokens": 512
}' | bat -pp -l json

curl -s -X 'POST' \
  'http://0.0.0.0:8000/v1/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
"model": "llama-3-8b-instruct-262k-chinese-lora-bin",
"prompt": "介绍一下机器学习",
"max_tokens": 512
}' | jq


## See also:
# https://github.com/vllm-project/vllm/issues/6250
