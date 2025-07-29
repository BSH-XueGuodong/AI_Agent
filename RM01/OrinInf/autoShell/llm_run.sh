#!/bin/bash

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查 /home/rm01/cfe 挂载点
check_mount() {
    local mount_point="/home/rm01/cfe"
    local max_attempts=60
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if command -v mountpoint >/dev/null 2>&1 && mountpoint -q "$mount_point" || findmnt "$mount_point" >/dev/null 2>&1; then
            log "Mount point $mount_point is mounted"
            return 0
        else
            log "Mount point $mount_point not mounted, attempt $attempt/$max_attempts"
            sleep 5
            ((attempt++))
        fi
    done
    log "ERROR: Mount point $mount_point not mounted after $max_attempts attempts"
    exit 1
}

# 检查模型文件夹是否为空
check_model_dir() {
    local model_dir="$1"
    log "Checking model directory: $model_dir"
    if [ -d "$model_dir" ]; then
        local file_count
        file_count=$(find "$model_dir" -maxdepth 1 -type f | wc -l)
        log "Found $file_count files in $model_dir"
        if [ "$file_count" -eq 0 ]; then
            log "Model directory $model_dir is empty, skipping execution"
            exit 0
        else
            log "Model directory $model_dir contains $file_count files, proceeding"
            return 0
        fi
    else
        log "ERROR: Model directory $model_dir does not exist"
        ls -ld /home/rm01/cfe /home/rm01/cfe/auto 2>&1 | while read -r line; do log "$line"; done
        exit 1
    fi
}

# 主执行逻辑
log "Starting LLM auto-run script"

# 检查挂载点
check_mount

# 检查模型文件夹
check_model_dir "/home/rm01/cfe/auto/llm"

# 设置环境变量并执行 vLLM
log "Setting up environment for vLLM"
export PATH="/home/rm01/miniconda3/bin:$PATH"
export TORCH_CUDA_ARCH_LIST=8.7
source /home/rm01/miniconda3/etc/profile.d/conda.sh

log "Activating conda environment vllm085p1"
conda activate vllm085p1 || {
    log "ERROR: Failed to activate conda environment vllm085p1"
    exit 1
}

log "Launching vLLM server"
vllm serve "/home/rm01/cfe/auto/llm" \
    --port 58000 \
    --gpu-memory-utilization=0.75 \
    --max-model-len=32768 \
    --served-model-name "RM-01 LLM" \
    --enable-prefix-caching \
    --enable-chunked-prefill \
    --block-size=16 \
    --max_num_batched_tokens 512 || {
    log "ERROR: Failed to start vLLM server"
    exit 1
}

log "vLLM server started successfully"