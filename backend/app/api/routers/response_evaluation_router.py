import json
from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import EvaluationRequest
from app.services.response_evaluation_service import ResponseEvaluationService

router = APIRouter(prefix="/response-evaluation", tags=["response-evaluation"])


def get_evaluation_service() -> ResponseEvaluationService:
    return ResponseEvaluationService()


@router.post("/")
def evaluate_response(
    request: EvaluationRequest,
    evaluation_service: ResponseEvaluationService = Depends(get_evaluation_service)
):
    """
    Evaluates the oral Polish matura exam response.
    Returns a parsed JSON evaluation or a fallback structure.
    """

    try:
        evaluation = evaluation_service.evaluate(
            question=request.question1,
            response=request.response, 

            examination_board_question1=request.examination_board_question1,
            examination_board_question2=request.examination_board_question2,

            examination_board_answers=request.examination_board_answers,  

            question2=request.question2,
        )

        # Clean markdown if present
        cleaned_evaluation = evaluation.strip()

        if cleaned_evaluation.startswith("```json"):
            cleaned_evaluation = cleaned_evaluation[7:]
        elif cleaned_evaluation.startswith("```"):
            cleaned_evaluation = cleaned_evaluation[3:]

        if cleaned_evaluation.endswith("```"):
            cleaned_evaluation = cleaned_evaluation[:-3]

        cleaned_evaluation = cleaned_evaluation.strip()

        try:
            parsed_json = json.loads(cleaned_evaluation)
            return parsed_json

        except json.JSONDecodeError:
            return {
                "score": 0,
                "summary": "Nie udało się sparsować oceny jako poprawny format JSON. Surowy wynik: " + evaluation,
                "errors": []
            }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Błąd podczas oceniania odpowiedzi: {str(e)}"
        )