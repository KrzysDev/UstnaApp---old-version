import os
from fastapi import Depends
from fastapi_limiter.depends import RateLimiter


def rate_limit(times: int, seconds: int):
    if not os.getenv("REDIS_URL"):
        return []
    return [Depends(RateLimiter(times=times, seconds=seconds))]