import os
import redis.asyncio as redis
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi_limiter import FastAPILimiter

from app.api.routers import (
    transcribing_router,
    response_evaluation_router,
    examination_board_questions_router,
    set_of_questions_router,
    set_of_questions_router,
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    redis_url = os.getenv("REDIS_URL")

    print("REDIS_URL =", redis_url)

    r = redis.from_url(redis_url)
    await FastAPILimiter.init(r)

    print("RATE LIMITER INIT DONE")

@app.on_event("shutdown")
async def shutdown():
    if FastAPILimiter.redis:
        await FastAPILimiter.close()

app.include_router(transcribing_router.router)
app.include_router(response_evaluation_router.router)
app.include_router(examination_board_questions_router.router)
app.include_router(set_of_questions_router.router)
app.include_router(set_of_questions_router.router)