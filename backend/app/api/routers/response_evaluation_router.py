import json
from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import EvaluationRequest
from app.services.response_evaluation_service import ResponseEvaluationService

router = APIRouter(prefix="/response-evaluation", tags=["response-evaluation"])


def get_evaluation_service() -> ResponseEvaluationService:
    return ResponseEvaluationService()


def _clean_json(raw: str) -> str:
    cleaned = raw.strip()
    if cleaned.startswith("```json"):
        cleaned = cleaned[7:]
    elif cleaned.startswith("```"):
        cleaned = cleaned[3:]
    if cleaned.endswith("```"):
        cleaned = cleaned[:-3]
    return cleaned.strip()


@router.post("/")
async def evaluate_response(
    request: EvaluationRequest,
    evaluation_service: ResponseEvaluationService = Depends(get_evaluation_service)
):
    try:
        evaluation = await evaluation_service.evaluate(    
            question=request.question1,
            response=request.response,
            examination_board_question1=request.examination_board_question1,
            examination_board_question2=request.examination_board_question2,
            examination_board_answers=request.examination_board_answers,
            question2=request.question2,
        )

        try:
            return json.loads(_clean_json(evaluation))
        except json.JSONDecodeError:
            return {
                "score": 0,
                "summary": f"Nie udało się sparsować oceny jako JSON. Surowy wynik: {evaluation}",
                "errors": []
            }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Błąd podczas oceniania odpowiedzi: {str(e)}")