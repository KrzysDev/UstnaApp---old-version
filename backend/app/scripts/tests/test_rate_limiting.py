import asyncio
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


async def send_request(client):
    return await client.post("/response-evaluation/", json={"text": "test"})


@pytest.mark.asyncio
async def test_rate_limit():
    transport = ASGITransport(app=app)

    async with AsyncClient(
        transport=transport,
        base_url="http://test"
    ) as client:

        tasks = [send_request(client) for _ in range(10)]

        responses = await asyncio.gather(*tasks)

        status_codes = [r.status_code for r in responses]

        print(status_codes)

        assert 429 in status_codes