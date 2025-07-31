from fastapi import FastAPI
from pydantic import BaseModel
from sentence_transformers import CrossEncoder
from typing import List
import uvicorn

# ✅ 选择模型
MODEL_NAME = "Alibaba-NLP/gte-reranker-modernbert-base"

# ✅ 加载模型（支持自定义架构）
model = CrossEncoder(
    MODEL_NAME,
    trust_remote_code=True,
    model_kwargs={"torch_dtype": "auto"}
)

# ✅ 启动 FastAPI 服务
app = FastAPI()

# ✅ 请求结构
class RerankRequest(BaseModel):
    model: str
    query: str
    documents: List[str]

# ✅ Rerank 接口（符合 Dify 要求）
@app.post("/v1/rerank")
def rerank(req: RerankRequest):
    pairs = [(req.query, doc) for doc in req.documents]
    scores = model.predict(pairs)
    sorted_results = sorted(enumerate(scores), key=lambda x: x[1], reverse=True)

    response = {
        "object": "rerank.result",
        "model": req.model,
        "results": [
            {
                "index": int(idx),
                "relevance_score": float(score),
                "document": req.documents[idx]
            }
            for idx, score in sorted_results
        ]
    }

    print("✅ 返回结果:", response)  # 调试用
    return response

# ✅ 启动服务
if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=40099, reload=True)