from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from datetime import datetime

app = FastAPI()

@app.get("/")
async def root(request: Request):
    client_ip = request.client.host
    now = datetime.utcnow().isoformat() + "Z"
    return JSONResponse(
        {
            "timestamp": now,
            "ip": client_ip,
        }
    )

