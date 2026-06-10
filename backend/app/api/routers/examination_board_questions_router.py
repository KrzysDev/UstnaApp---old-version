from app.models.schemas import ExaminationBoardQuestionsRequest
from app.services.examination_board_questions_service import ExaminationBoardQuestionsService
from app.services.ai_service import AiService

from fastapi import APIRouter

router = APIRouter(prefix="/examination-board-questions", tags=["examination-board-questions"])

ai_service = AiService()
examination_board_questions_service = ExaminationBoardQuestionsService(ai_service=ai_service)

@router.post("/")
def get_examination_board_questions(request: ExaminationBoardQuestionsRequest):
    return examination_board_questions_service.generate_questions(
        request.topic_1,
        request.topic_2,
        request.student_answer
    )