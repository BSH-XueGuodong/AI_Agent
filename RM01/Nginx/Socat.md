# Socat Commands
## 1. Socat for LLM
- socat TCP-LISTEN:15800,reuseaddr,fork TCP:10.10.99.98:58000
- nohup socat TCP-LISTEN:15800,reuseaddr,fork TCP:10.10.99.98:58000 > /tmp/socat.log 2>&1 &

## 2. Socat for Embedding
- socat TCP-LISTEN:15880,reuseaddr,fork TCP:10.10.99.98:58080
- nohup socat TCP-LISTEN:15880,reuseaddr,fork TCP:10.10.99.98:58080 > /tmp/socat.log 2>&1 &

## 3. Socat for Reranker
- socat TCP-LISTEN:15881,reuseaddr,fork TCP:10.10.99.98:58081
- nohup socat TCP-LISTEN:15881,reuseaddr,fork TCP:10.10.99.98:58081 > /tmp/socat.log 2>&1 &