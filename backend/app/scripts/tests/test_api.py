import sys
import os

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

try:
    from fastapi.testclient import TestClient
    from app.main import app
    from app.api.routers.question_router import QuestionsManager
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

client = TestClient(app)

def test_health_check():
    print("Testing root endpoint / ...")
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["app"] == "UstnaApp API"
    assert data["status"] == "running"
    print("[OK] Root endpoint is working!")

def test_get_all_questions_list():
    print("\nTesting list endpoint /api/questions/ ...")
    response = client.get("/api/questions/")
    assert response.status_code == 200
    data = response.json()
    assert "count" in data
    assert "questions" in data
    assert data["count"] == 76
    assert len(data["questions"]) == 76
    assert data["questions"][0].startswith("1. ")
    print(f"[OK] Successfully loaded {data['count']} questions in JSON format!")

def test_get_all_questions_string():
    print("\nTesting text endpoint /api/questions/all ...")
    response = client.get("/api/questions/all")
    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/plain")
    text = response.text
    # Should contain 76 non-empty lines
    lines = [line for line in text.split("\n") if line.strip()]
    assert len(lines) == 76
    assert lines[0].startswith("1. Motyw cierpienia")
    print("[OK] Successfully loaded all questions as a single string!")

def test_get_question_by_index():
    print("\nTesting index endpoint /api/questions/{index} ...")
    # Test valid index (first question)
    response = client.get("/api/questions/1")
    assert response.status_code == 200
    data = response.json()
    assert data["index"] == 1
    assert data["question"].startswith("1. Motyw cierpienia")

    # Test valid index (last question)
    response = client.get("/api/questions/76")
    assert response.status_code == 200
    data = response.json()
    assert data["index"] == 76
    assert "Podróży z Herodotem" in data["question"]

    # Test invalid index (too low)
    response = client.get("/api/questions/0")
    assert response.status_code == 404
    assert "Nie znaleziono pytania o indeksie 0" in response.json()["detail"]

    # Test invalid index (too high)
    response = client.get("/api/questions/77")
    assert response.status_code == 404
    assert "Nie znaleziono pytania o indeksie 77" in response.json()["detail"]

    print("[OK] Fetching by index is working correctly with bounds validation!")

if __name__ == "__main__":
    print("=== RUNNING API VERIFICATION TESTS ===")
    try:
        test_health_check()
        test_get_all_questions_list()
        test_get_all_questions_string()
        test_get_question_by_index()
        print("\n=== ALL TESTS PASSED SUCCESSFULLY! ===")
    except AssertionError as e:
        print(f"\n[FAIL] Assertion failed!")
        sys.exit(1)
    except Exception as e:
        print(f"\n[FAIL] Unexpected error: {e}")
        sys.exit(1)

