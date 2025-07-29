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
log "Starting Reranker auto-run script"

# 检查挂载点
check_mount

# 检查模型文件夹
check_model_dir "/home/rm01/cfe/auto/reranker"

# 执行 text-embeddings-router
log "Launching text-embeddings-router for Reranker"
/home/rm01/.cargo/bin/text-embeddings-router \
    --model-id /home/rm01/cfe/auto/reranker \
    --port 58081 \
    --hostname 0.0.0.0 \
    --prometheus-port 58181 || {
    log "ERROR: Failed to start text-embeddings-router for Reranker"
    exit 1
}

log "Reranker server started successfully"