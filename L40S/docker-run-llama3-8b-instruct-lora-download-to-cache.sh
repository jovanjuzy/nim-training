#!/bin/bash

# Copyright (c) 2024, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: MIT-0

## NOTE: to run download-to-cache, llama3 container requires --gpus all, but llama-3.1 doesn't.

set -euo pipefail
source .env

mkdir -p $HOME/.cache/nim

docker run -it --rm \
  --gpus all \
  --shm-size=16GB \
  -u $(id -u) \
  nvcr.io/nim/meta/llama3-8b-instruct:1.0.3 \
  "list-model-profiles"
# Output:
echo "
SYSTEM INFO
- Free GPUs:
  -  [26b9:10de] (0) NVIDIA L40S (L40S) [current utilization: 1%]
  -  [26b9:10de] (1) NVIDIA L40S (L40S) [current utilization: 1%]
MODEL PROFILES
- Compatible with system and runnable:
  - f59d52b0715ee1ecf01e6759dea23655b93ed26b12e57126d9ec43b397ea2b87 (tensorrt_llm-l40s-fp8-tp2-latency)
  - 09e2f8e68f78ce94bf79d15b40a21333cea5d09dbe01ede63f6c957f4fcfab7b (tensorrt_llm-l40s-fp8-tp1-throughput)
  - 24199f79a562b187c52e644489177b6a4eae0c9fdad6f7d0a8cb3677f5b1bc89 (tensorrt_llm-l40s-fp16-tp2-latency)
  - d8dd8af82e0035d7ca50b994d85a3740dbd84ddb4ed330e30c509e041ba79f80 (tensorrt_llm-l40s-fp16-tp1-throughput)
  - 19031a45cf096b683c4d66fff2a072c0e164a24f19728a58771ebfc4c9ade44f (vllm-fp16-tp2)
  - 8835c31752fbc67ef658b20a9f78e056914fdef0660206d82f252d62fd96064d (vllm-fp16-tp1)
  - With LoRA support:
    - 388140213ee9615e643bda09d85082a21f51622c07bde3d0811d7c6998873a0b (tensorrt_llm-l40s-fp16-tp1-throughput-lora)
    - c5ffce8f82de1ce607df62a4b983e29347908fb9274a0b7a24537d6ff8390eb9 (vllm-fp16-tp2-lora)
    - 8d3824f766182a754159e88ad5a0bd465b1b4cf69ecf80bd6d6833753e945740 (vllm-fp16-tp1-lora)
- Incompatible with system:
  - dcd85d5e877e954f26c4a7248cd3b98c489fbde5f1cf68b4af11d665fa55778e (tensorrt_llm-h100-fp8-tp2-latency)
  - 30b562864b5b1e3b236f7b6d6a0998efbed491e4917323d04590f715aa9897dc (tensorrt_llm-h100-fp8-tp1-throughput)
  - a93a1a6b72643f2b2ee5e80ef25904f4d3f942a87f8d32da9e617eeccfaae04c (tensorrt_llm-a100-fp16-tp2-latency)
  - e0f4a47844733eb57f9f9c3566432acb8d20482a1d06ec1c0d71ece448e21086 (tensorrt_llm-a10g-fp16-tp2-latency)
  - 879b05541189ce8f6323656b25b7dff1930faca2abe552431848e62b7e767080 (tensorrt_llm-h100-fp16-tp2-latency)
  - 751382df4272eafc83f541f364d61b35aed9cce8c7b0c869269cea5a366cd08c (tensorrt_llm-a100-fp16-tp1-throughput)
  - c334b76d50783655bdf62b8138511456f7b23083553d310268d0d05f254c012b (tensorrt_llm-a10g-fp16-tp1-throughput)
  - cb52cbc73a6a71392094380f920a3548f27c5fcc9dab02a98dc1bcb3be9cf8d1 (tensorrt_llm-h100-fp16-tp1-throughput)
  - 9137f4d51dadb93c6b5864a19fd7c035bf0b718f3e15ae9474233ebd6468c359 (tensorrt_llm-a10g-fp16-tp2-throughput-lora)
  - cce57ae50c3af15625c1668d5ac4ccbe82f40fa2e8379cc7b842cc6c976fd334 (tensorrt_llm-a100-fp16-tp1-throughput-lora)
  - 3bdf6456ff21c19d5c7cc37010790448a4be613a1fd12916655dfab5a0dd9b8e (tensorrt_llm-h100-fp16-tp1-throughput-lora)
" &> /dev/null

# tensorrt_llm-l40s-fp16-tp1-throughput-lora
docker run -it --rm \
  --gpus all \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama3-8b-instruct:1.0.3 \
  bash -c "
download-to-cache -p 388140213ee9615e643bda09d85082a21f51622c07bde3d0811d7c6998873a0b
"

# vllm-fp16-tp2-lora
docker run -it --rm \
  --gpus all \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama3-8b-instruct:1.0.3 \
  bash -c "
download-to-cache -p c5ffce8f82de1ce607df62a4b983e29347908fb9274a0b7a24537d6ff8390eb9
"

# vllm-fp16-tp1-lora
docker run -it --rm \
  --gpus all \
  -v "$HOME/.cache/nim:/opt/nim/.cache:rw" \
  -u $(id -u) \
  -e NGC_API_KEY \
  nvcr.io/nim/meta/llama3-8b-instruct:1.0.3 \
  bash -c "
download-to-cache -p 8d3824f766182a754159e88ad5a0bd465b1b4cf69ecf80bd6d6833753e945740
"

exit $?


################################################################################
### This is a document, not meant as executable.
################################################################################
du -shc $HOME/.cache/nim/ngc/hub/*
