#!/bin/bash

# Copyright (c) 2024, NVIDIA CORPORATION. All rights reserved.
# SPDX-License-Identifier: MIT-0

# No need for API key??

mkdir -p $HOME/.cache/nim/

# docker run -itd --name=nv-embedqa-e5-v5 \
docker run -it --rm \
  --gpus all \
  --shm-size=16GB \
  -v "$HOME/.cache/nim:/opt/nim/.cache" \
  -u $(id -u) \
  -p 7000:8000 \
  nvcr.io/nim/nvidia/nv-embedqa-e5-v5:1.0.1
