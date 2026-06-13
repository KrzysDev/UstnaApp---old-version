import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from fastapi.testclient import TestClient
from app.main import app
from app.api.routers.response_evaluation_router import get_evaluation_service

# client initialized in context manager within tests

class MockEvaluationService:
    async def evaluate(
        self,
        question: str,
        response: str,
        examination_board_question1: str = "",
        examination_board_question2: str = "",
        examination_board_answers: str = "",
        question2: str = ""
    ) -> str:
        # Mock successful evaluation JSON string
        return """
        {
            "score": 85,
            "summary": "Bardzo dobra wypowiedź.",
            "errors": []
        }
        """

def get_mock_service():
    return MockEvaluationService()

app.dependency_overrides[get_evaluation_service] = get_mock_service

def test_evaluation_success():
    payload = {
        "question1": "Pytanie 1",
        "question2": "Pytanie 2",
        "response": "Odpowiedz 1",
        "examination_board_question1": "Pytanie komisji 1",
        "examination_board_question2": "Pytanie komisji 2",
        "examination_board_answers": "Odpowiedz komisji 1"
    }
    with TestClient(app) as client:
        response = client.post("/response-evaluation/", json=payload)
    print("STATUS CODE:", response.status_code)
    print("RESPONSE TEXT:", response.text)
    assert response.status_code == 200
    data = response.json()
    assert data["score"] == 85
    assert data["summary"] == "Bardzo dobra wypowiedź."
    assert data["errors"] == []
    print("[OK] Test evaluation success passed!")

class MockEvaluationServiceInvalidJSON:
    async def evaluate(self, *args, **kwargs) -> str:
        return "To nie jest poprawny JSON"

def get_mock_service_invalid_json():
    return MockEvaluationServiceInvalidJSON()

def test_evaluation_fallback():
    app.dependency_overrides[get_evaluation_service] = get_mock_service_invalid_json
    payload = {
        "question1": "Pytanie 1",
        "question2": "",
        "response": "Odpowiedz 1",
        "examination_board_question1": "",
        "examination_board_question2": "",
        "examination_board_answers": ""
    }
    with TestClient(app) as client:
        response = client.post("/response-evaluation/", json=payload)
    print("STATUS CODE:", response.status_code)
    print("RESPONSE TEXT:", response.text)
    assert response.status_code == 200
    data = response.json()
    assert data["score"] == 0
    assert "Nie udało się sparsować oceny" in data["summary"]
    print("[OK] Test evaluation fallback passed!")

if __name__ == "__main__":
    print("=== RUNNING API EVALUATION TESTS ===")
    try:
        test_evaluation_success()
        test_evaluation_fallback()
        print("=== ALL EVALUATION TESTS PASSED! ===")
    except AssertionError as e:
        print(f"\n[FAIL] Assertion failed!")
        sys.exit(1)
    except Exception as e:
        print(f"\n[FAIL] Unexpected error: {e}")
        sys.exit(1)
