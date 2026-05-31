from fastapi import APIRouter
from app.models.schemas import EvaluationRequest
from app.services.response_evaluation_service import ResponseEvaluationService

router = APIRouter(
    prefix="/response-evaluation",
    tags=["response-evaluation"]
)

service = ResponseEvaluationService()

@router.post("/")
def evaluate_response(evaluation: EvaluationRequest):
    response = service.evaluate(
        question=evaluation.question,
        response=evaluation.response,
        examination_board_question1=evaluation.examination_board_question1,
        examination_board_question11_answer=evaluation.examination_board_question11_answer,
        examination_board_question2=evaluation.examination_board_question2,
        examination_board_question12_answer=evaluation.examination_board_question12_answer,
        question2=evaluation.question2,
        response2=evaluation.response2,
    )

    return response