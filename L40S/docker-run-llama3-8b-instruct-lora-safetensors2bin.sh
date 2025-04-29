#!/bin/bash

# Copyright (c) 2024, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: MIT-0

set -euo pipefail

mkdir -p $HOME/.cache/nim/loras/

####
# These are already in .bin, but I need somewhere to record the CLIs, so here it is.
####
aria2c --auto-file-renaming=false \
    https://huggingface.co/AdithyaSK/LLama3-Gaja-Hindi-8B-Instruct-alpha/resolve/main/adapter_model.bin \
    -o adapter_model.bin \
    -d $HOME/.cache/nim/loras/LLama3-Gaja-Hindi-8B-Instruct-alpha/

aria2c --auto-file-renaming=false \
    https://huggingface.co/AdithyaSK/LLama3-Gaja-Hindi-8B-Instruct-alpha/resolve/main/adapter_config.json \
    -d $HOME/.cache/nim/loras/LLama3-Gaja-Hindi-8B-Instruct-alpha/
####


aria2c --auto-file-renaming=false \
    https://huggingface.co/shibing624/llama-3-8b-instruct-262k-chinese-lora/resolve/main/adapter_model.safetensors \
    -o adapter_model.safetensors \
    -d $HOME/.cache/nim/loras/llama-3-8b-instruct-262k-chinese-lora/

aria2c --auto-file-renaming=false \
    https://huggingface.co/shibing624/llama-3-8b-instruct-262k-chinese-lora/resolve/main/adapter_config.json \
    -d $HOME/.cache/nim/loras/llama-3-8b-instruct-262k-chinese-lora/

mkdir -p $HOME/.cache/nim/loras/llama-3-8b-instruct-262k-chinese-lora-bin/
cp $HOME/.cache/nim/loras/llama-3-8b-instruct-262k-chinese-lora{,-bin}/adapter_config.json

#docker run -itd --name=llama3-8b-instruct \
docker run -it --rm  \
  --shm-size=16GB \
  -v "$HOME/.cache/nim/loras:/opt/nim/.cache/loras" \
  -u $(id -u) \
  nvcr.io/nim/meta/llama3-8b-instruct:1.0.3 python -c "
# https://github.com/huggingface/diffusers/issues/3283#issuecomment-2336982418

from safetensors.torch import load_file
import torch

lora_model_path = '/opt/nim/.cache/loras/llama-3-8b-instruct-262k-chinese-lora/adapter_model.safetensors'
bin_model_path  = '/opt/nim/.cache/loras/llama-3-8b-instruct-262k-chinese-lora-bin/adapter_model.bin'
torch.save(load_file(lora_model_path), bin_model_path)
"

exit $?
