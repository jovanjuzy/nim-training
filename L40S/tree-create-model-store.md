```console
$ cd ~/.cache/nim

$ tree --matchdirs -I ngc
.
├── llama-3.1-8b-instruct:1.1.2__tensorrt_llm-l40s-bf16-tp1-throughput
│   ├── checksums.blake3
│   ├── config.json
│   ├── generation_config.json
│   ├── LICENSE.txt
│   ├── model.safetensors.index.json
│   ├── NOTICE.txt
│   ├── special_tokens_map.json
│   ├── tokenizer_config.json
│   ├── tokenizer.json
│   ├── tool_use_config.json
│   └── trtllm_engine
│       ├── checksums.blake3
│       ├── config.json
│       ├── LICENSE.txt
│       ├── metadata.json
│       ├── NOTICE.txt
│       └── rank0.engine
├── llama-3.1-8b-instruct:1.1.2__tensorrt_llm-l40s-bf16-tp2-latency
│   ├── checksums.blake3
│   ├── config.json
│   ├── generation_config.json
│   ├── LICENSE.txt
│   ├── model.safetensors.index.json
│   ├── NOTICE.txt
│   ├── special_tokens_map.json
│   ├── tokenizer_config.json
│   ├── tokenizer.json
│   ├── tool_use_config.json
│   └── trtllm_engine
│       ├── checksums.blake3
│       ├── config.json
│       ├── LICENSE.txt
│       ├── metadata.json
│       ├── NOTICE.txt
│       ├── rank0.engine
│       └── rank1.engine
├── llama-3.1-8b-instruct:1.1.2__vllm-fp16-tp1
│   ├── checksums.blake3
│   ├── config.json
│   ├── generation_config.json
│   ├── LICENSE.txt
│   ├── model-00001-of-00004.safetensors
│   ├── model-00002-of-00004.safetensors
│   ├── model-00003-of-00004.safetensors
│   ├── model-00004-of-00004.safetensors
│   ├── model.safetensors.index.json
│   ├── NOTICE.txt
│   ├── special_tokens_map.json
│   ├── tokenizer_config.json
│   ├── tokenizer.json
│   └── tool_use_config.json
├── llama-3.1-8b-instruct:1.1.2__vllm-fp16-tp2
│   ├── checksums.blake3
│   ├── config.json
│   ├── generation_config.json
│   ├── LICENSE.txt
│   ├── model-00001-of-00004.safetensors
│   ├── model-00002-of-00004.safetensors
│   ├── model-00003-of-00004.safetensors
│   ├── model-00004-of-00004.safetensors
│   ├── model.safetensors.index.json
│   ├── NOTICE.txt
│   ├── special_tokens_map.json
│   ├── tokenizer_config.json
│   ├── tokenizer.json
│   └── tool_use_config.json
└── tree-download-to-cache.md

6 directories, 62 files
```
