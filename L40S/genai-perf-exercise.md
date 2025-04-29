This guide assumes you've completed the lesson on deploying a NIM LLM endpoint.

You'll need multiple terminals, let's call them terminal A, B, C, and so on.

```bash
###############################################################################
# 000: Get triton container which provides genai-perf CLI
###############################################################################
/usr/bin/time docker pull nvcr.io/nvidia/tritonserver:24.08-py3-sdk
# ...
# Digest: sha256:af34153227000b64d1ed4faf9612570a44d414ab8aa0e1dc143f18c19d71a5a7
# Status: Downloaded newer image for nvcr.io/nvidia/tritonserver:24.08-py3-sdk
# nvcr.io/nvidia/tritonserver:24.08-py3-sdk
# 0.33user 0.25system 6:36.35elapsed 0%CPU (0avgtext+0avgdata 26624maxresident)k
# 0inputs+0outputs (0major+3924minor)pagefaults 0swaps

docker images | grep 'nvcr.io/nvidia/tritonserver'
# nvcr.io/nvidia/tritonserver              24.08-py3-sdk                  8f810f2f8b66   3 months ago   14.2GB


###############################################################################
# 010: Terminal A: Start triton container
###############################################################################
docker run -it --rm nvcr.io/nvidia/tritonserver:24.08-py3-sdk /bin/bash


###############################################################################
# 020: Terminal A: Inside genai-perf the triton container: login to HF
# Under container, `root@xxxx:...# ` denotes a command line.
###############################################################################
huggingface-cli login
# Paste your HF Key
# Choose N on the git question

# Cache the tokenizer. This is also a way to validate your access to the HF
# llama artifacts. If you fail on this step, make sure you have setup your HF
# credentials, and you've been approved to access llama3 artifacts.
python3 -c 'from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3.1-8B-Instruct")
'

###############################################################################
# 030: Terminal B: Start a NIM LLM endpoint
###############################################################################
# If you haven't cached the model artifacts (~16 GB), it may take 20+ minutes
# for the NIM container to start (depending on our internet speed). Expect more
# time if the docker image is not yet in your local registry.
./docker-run-llama-3.1-8b-instruct.sh
# ...
# INFO 12-03 13:10:59.52 server.py:214] Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)


###############################################################################
# 040: Terminal C: connect the triton & NIM containers.
###############################################################################
# Identify the container ids
docker ps -a
# CONTAINER ID   IMAGE                                          ...
# ef5d43ed0421   nvcr.io/nim/meta/llama-3.1-8b-instruct:1.1.2   ...
# c5cd18efc017   nvcr.io/nvidia/tritonserver:24.08-py3-sdk      ...

# Put both containers in the same network
docker network create hahanet
docker network connect hahanet c5cd18efc017  # genai-perf
docker network connect hahanet ef5d43ed0421  # endpoint

# Verify that the network includes both containers.
# NOTE: if you don't have bat cli (i.e., the syntax highlighter), just drop the
#       '| bat ...' part. You can also use jq to syntax highlight the json.
#
# IMPORTANT: take note the ip address of the NIM container
docker network inspect hahanet | bat -l json -pp
# ...
#         "Containers": {
#             ...
#             "ef5d43ed04217c68e3af7b20ad962d5300ee828f27f1b3a14128a6ed641e054b": {
#                 "Name": "busy_bartik",
#                 ...
#                 "IPv4Address": "172.18.0.3/16",
#                 ...
#             }
#         },
# ...

# Please note that from this point onwards, both containers NO LONGER have
# internet access. They can only talk between themselves. Hence, it's very
# important that the tritonserver container has cached the llama3 tokenizers.


###############################################################################
# 050: Terminal A: and here we go...
# We're under the triton container.
###############################################################################
# Adapted from https://docs.nvidia.com/nim/benchmarking/llm/latest/step-by-step.html#step-3-setting-up-genai-perf-and-warming-up-benchmarking-a-single-use-case
# NOTE: we change to llama-3.1, and use a newer container, so please beware
#       that the genai-perf command has slight changes.
export INPUT_SEQUENCE_LENGTH=200
export INPUT_SEQUENCE_STD=10
export OUTPUT_SEQUENCE_LENGTH=200
export CONCURRENCY=10
export MODEL=meta/llama-3.1-8b-instruct

# IMPORTANT: -u <IP_ADDRESS_OF_NIM_CONTAINER>, so change that line to match
#            your actual ip address
genai-perf \
    profile \
    -m $MODEL \
    --endpoint-type chat \
    --service-kind openai \
    --streaming \
    -u 172.18.0.3:8000 \
    --synthetic-input-tokens-mean $INPUT_SEQUENCE_LENGTH \
    --synthetic-input-tokens-stddev $INPUT_SEQUENCE_STD \
    --concurrency $CONCURRENCY \
    --output-tokens-mean $OUTPUT_SEQUENCE_LENGTH \
    --extra-inputs max_tokens:$OUTPUT_SEQUENCE_LENGTH \
    --extra-inputs min_tokens:$OUTPUT_SEQUENCE_LENGTH \
    --extra-inputs ignore_eos:true \
    --tokenizer meta-llama/Meta-Llama-3-8B-Instruct \
    -- \
    -v \
    --max-threads=256


###############################################################################
# 050: Clean-up network
###############################################################################
# Goto the respetive terminals, and exit all containers
#
# After all container stop, remove the network with one of these options.
docker network rm -f hahanet   # Delete the specific network(s)
```
