from app.models.prompts import EVALUATION_PROMPT
from app.services.ai_service import AiService


class ResponseEvaluationService:
    def __init__(self):
        self.ai_service = AiService()

    async def evaluate(
        self,
        question: str,
        response: str,
        examination_board_question1: str = "",
        examination_board_question2: str = "",
        examination_board_answers: str = "",
        question2: str = "",
    ) -> str:
        evaluation_prompt = EVALUATION_PROMPT.format(
            exam_question=question,
            exam_question2=question2,
            student_answer=response,
            examination_board_question1=examination_board_question1,
            examination_board_question2=examination_board_question2,
            examination_board_answer=examination_board_answers,
        )

        return await self.ai_service.ask(evaluation_prompt)
