#!/bin/bash

# Copyright (c) 2024, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: MIT-0

# https://docs.nvidia.com/nim/large-language-models/latest/utilities.html

set -euo pipefail
source .env

mkdir -p $HOME/.cache/nim

docker run -it --rm \
  --gpus all \
  --shm-size=16GB \
  -u $(id -u) \
  nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2 \
  "list-model-profiles"
# Output:
echo "
SYSTEM INFO
- Free GPUs:
  -  [26b9:10de] (0) NVIDIA L40S (L40S) [current utilization: 0%]
  -  [26b9:10de] (1) NVIDIA L40S (L40S) [current utilization: 0%]
MODEL PROFILES
- Compatible with system and runnable:
  - 0494aafce0df9eeaea49bbca6b25fc3013d0e8a752ebcf191a2ddeaab19481ee (tensorrt_llm-l40s-bf16-tp2-latency)
  - a534b0f5e885d747e819fa8b1ad7dc1396f935425a6e0539cb29b0e0ecf1e669 (tensorrt_llm-l40s-bf16-tp2-throughput)
  - 3807be802a8ab1d999bf280c96dcd8cf77ac44c0a4d72edb9083f0abb89b6a19 (tensorrt_llm-l40s-bf16-tp1-throughput)
  - 6a3ba475d3215ca28f1a8c8886ab4a56b5626d1c98adbfe751025e8ff3d9886d (vllm-fp16-tp2)
  - 3bb4e8fe78e5037b05dd618cebb1053347325ad6a1e709e0eb18bb8558362ac5 (vllm-fp16-tp1)
  - With LoRA support:
    - 6b89dc22ba60a07df3051451b7dc4ef418d205e52e19cb0845366dc18dd61bd6 (tensorrt_llm-l40s-bf16-tp2-throughput-lora)
    - a95e5c7221dae587b4fc32448df265320ce79064a970297649d97a84eb9dc3ba (vllm-fp16-tp2-lora)
    - dfd9bee71abb7582246f7fb8c2aedd9119909b9639e1b4b0260ef6865545ede7 (vllm-fp16-tp1-lora)
- Incompatible with system:
  - 0bc4cc784e55d0a88277f5d1aeab9f6ecb756b9049dd07c1835035211fcfe77e (tensorrt_llm-h100-fp8-tp2-latency)
  - 2959f7f0dfeb14631352967402c282e904ff33e1d1fa015f603d9890cf92ca0f (tensorrt_llm-h100-fp8-tp1-throughput)
  - 4829bb6204dd994f8448ae7fb2cec9d4c6933c382f84463176a5b5cd76cb73c8 (tensorrt_llm-a100-fp16-tp2-latency)
  - e45b4b991bbc51d0df3ce53e87060fc3a7f76555406ed534a8479c6faa706987 (tensorrt_llm-a10g-bf16-tp4-latency)
  - 7f98797c334a8b7205d4cbf986558a2b8a181570b46abed9401f7da6d236955e (tensorrt_llm-h100-bf16-tp2-latency)
  - ba515cc44a34ae4db8fe375bd7e5ad30e9a760bd032230827d8a54835a69c409 (tensorrt_llm-a10g-bf16-tp2-throughput)
  - 7ea3369b85d7aee24e0739df829da8832b6873803d5f5aca490edad7360830c8 (tensorrt_llm-a100-bf16-tp1-throughput)
  - 9cff0915527166b2e93c08907afd4f74e168562992034a51db00df802e86518c (tensorrt_llm-h100-bf16-tp1-throughput)
  - ec13a06451be8a6e1d8aa4e7a6010f970e0d150a44ce6e6012149c9e60ae3529 (vllm-fp16-tp8)
  - 407c6c5d1e29be9929f41b9a2e3193359b8ebfa512353de88cefbf1e0f0b194e (vllm-fp16-tp4)
  - fcfdd389299632ae51e5560b3368d18c4774441ef620aa1abf80d7077b2ced2b (tensorrt_llm-a10g-bf16-tp4-throughput-lora)
  - a506c5bed39ba002797d472eb619ef79b1ffdf8fb96bb54e2ff24d5fc421e196 (tensorrt_llm-a100-bf16-tp1-throughput-lora)
  - 40543df47628989c7ef5b16b33bd1f55165dddeb608bf3ccb56cdbb496ba31b0 (tensorrt_llm-h100-bf16-tp1-throughput-lora)
  - d3711d1ebdbe7798834c684c01c10b1091ebef28d1e609b971ecbe6b8c02e05a (vllm-fp16-tp8-lora)
  - 678e6dbe53dd6fe7dc508d22eb0672743ba0b7e735007cfd0b0d2a9e05911fb9 (vllm-fp16-tp4-lora)
" &> /dev/null

docker run -it --rm \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2 \
  bash -c "
create-model-store \
    -p 0494aafce0df9eeaea49bbca6b25fc3013d0e8a752ebcf191a2ddeaab19481ee \
    -m /opt/nim/.cache/llama-3.1-8b-instruct:1.1.2__tensorrt_llm-l40s-bf16-tp2-latency
"

docker run -it --rm \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2 \
  bash -c "
create-model-store \
    -p 3807be802a8ab1d999bf280c96dcd8cf77ac44c0a4d72edb9083f0abb89b6a19 \
    -m /opt/nim/.cache/llama-3.1-8b-instruct:1.1.2__tensorrt_llm-l40s-bf16-tp1-throughput
"

docker run -it --rm \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2 \
  bash -c "
create-model-store \
    -p 6a3ba475d3215ca28f1a8c8886ab4a56b5626d1c98adbfe751025e8ff3d9886d \
    -m /opt/nim/.cache/llama-3.1-8b-instruct:1.1.2__vllm-fp16-tp2
"

docker run -it --rm \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2 \
  bash -c "
create-model-store \
    -p 3bb4e8fe78e5037b05dd618cebb1053347325ad6a1e709e0eb18bb8558362ac5 \
    -m /opt/nim/.cache/llama-3.1-8b-instruct:1.1.2__vllm-fp16-tp1
"

exit $?


################################################################################
### This is a document, not meant as executable.
################################################################################
du -shc $HOME/.cache/nim/ngc/hub/*
