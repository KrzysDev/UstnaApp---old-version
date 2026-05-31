# pyrefly: ignore [missing-import]

from pydantic import BaseModel

class EvaluationRequest(BaseModel):
    examination_board_question1: str
    examination_board_question11_answer: str
    examination_board_question2: str
    examination_board_question12_answer: str
    question1: str
    response1: str
    question2: str
    response2: str