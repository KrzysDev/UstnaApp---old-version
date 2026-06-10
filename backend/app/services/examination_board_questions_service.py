from app.services.ai_service import AiService
from app.models.prompts import EXAMINATION_BOARD_QUESTIONS_PROMPT


class ExaminationBoardQuestionsService:
    def __init__(self, ai_service: AiService):
        self.ai_service = ai_service

    def generate_questions(
        self,
        topic_1: str,
        topic_2: str,
        student_answer: str
    ) -> str:

        prompt = EXAMINATION_BOARD_QUESTIONS_PROMPT.format(
            topic_1=topic_1,
            topic_2=topic_2,
            student_answer=student_answer
        )

        return self.ai_service.ask(prompt)