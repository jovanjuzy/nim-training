# Running NIM with LoRA Adapter

### Prerequisites
1. Any Linux Distributions
2. Docker
3. NVIDIA Container Toolkit
4. NVIDIA GPU (supported GPU -- refer to [support matrix](https://docs.nvidia.com/nim/large-language-models/latest/support-matrix.html))
5. Supported LoRA configuration (refer to [support matrix](https://docs.nvidia.com/nim/large-language-models/latest/support-matrix.html))

### Steps to deploy Llama 3 8B instruct LoRA
1. LoRA model has already been pre-downloaded in shared /opt/nim/loras directory.<br>
Copy over to local directory e.g. `~/xxx/nim/loras`


2. Prepare shell script to run Llama-3 8B NIM
- Change the following path to your local directory & specify NGC_API_KEY.
- Ensure `LOCAL_PEFT_DIRECTORY` points to your local LoRA adapters.
- GPU allocation -> add line to docker command e.g. --gpus device=0 (use device=0 if you're user 1; device=1 if user 2, etc)
- Port allocation -> user 1 as default port 8000, user 2 as 8001, etc.
```bash
# Set path to your LoRA model store
export LOCAL_PEFT_DIRECTORY=~/xxx/nim/loras

# Set these configurations
export NGC_API_KEY=<INSERT NGC API KEY>
export NIM_PEFT_REFRESH_INTERVAL=3600
export NIM_CACHE_PATH=~/xxx/nim/.cache
mkdir -p $NIM_CACHE_PATH # if you've not yet done so
chmod -R 755 $NIM_CACHE_PATH $LOCAL_PEFT_DIRECTORY

export NIM_PEFT_SOURCE=/home/nvs/loras
export CONTAINER_NAME=meta-llama3-8b-instruct

docker run -it --rm --name=$CONTAINER_NAME \
  --gpus all \
  --network=host \
  --shm-size=16GB \
  -e NGC_API_KEY \
  -e NIM_PEFT_SOURCE \
  -e NIM_PEFT_REFRESH_INTERVAL \
  -v NIM_CACHE_PATH:/opt/nim/.cache \
  -v LOCAL_PEFT_DIRECTORY:/tmp/loras \
  -u $(id -u):$(id -g) \
  -p 8000:8000 \
  nvcr.io/nim/meta/llama3-8b-instruct:latest
   ```

```
curl -X GET 'http://0.0.0.0:8000/v1/models'
```
- Check list of models for inference

## Additional Steps
- Ensure you're login to nvcr.io, provide sufficient credentials (NGC API Key).
- Run the NIM
- Send CuRL request:
```bash
curl -X 'POST' \
  'http://0.0.0.0:8000/v1/completions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
"model": "llama3-8b-instruct-lora_vnemo-math-v1",
"prompt": "John buys 10 packs of magic cards. Each pack has 20 cards and 1/4 of those cards are uncommon. How many uncommon cards did he get?",
"max_tokens": 128
}'
```

### References
Based on documentation: <https://docs.nvidia.com/nim/large-language-models/latest/peft.html> 