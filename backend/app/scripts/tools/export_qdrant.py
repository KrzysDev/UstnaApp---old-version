import json
import os

from qdrant_client import QdrantClient
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())


def export_collection(collection_name: str = "UstnApp") -> list[dict]:
    client = QdrantClient(
        url=os.getenv("QDRANT_URL"),
        api_key=os.getenv("QDRANT_API_KEY"),
    )

    all_points = []
    offset = None

    print(f"Downloading from collection '{collection_name}'...")

    while True:
        results, next_offset = client.scroll(
            collection_name=collection_name,
            limit=100,
            offset=offset,
            with_payload=True,
            with_vectors=True,
        )

        for point in results:
            all_points.append({
                "id": point.id if not hasattr(point.id, '__dict__') else str(point.id),
                "payload": point.payload,
                "vector": point.vector,
            })

        print(f"  Downloaded {len(all_points)} points...")

        if next_offset is None:
            break
        offset = next_offset

    print(f"Downloaded {len(all_points)} points.")
    return all_points


def main():
    data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
    os.makedirs(data_dir, exist_ok=True)

    output_path = os.path.join(data_dir, "qdrant_export.json")

    points = export_collection()

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(points, f, ensure_ascii=False, indent=2)

    print(f"Data saved to: {os.path.abspath(output_path)}")


if __name__ == "__main__":
    main()
