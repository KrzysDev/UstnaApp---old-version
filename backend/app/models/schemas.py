# pyrefly: ignore [missing-import]

from pydantic import BaseModel
from typing import Literal


class EvaluationRequest(BaseModel):
    examination_board_question1: str
    examination_board_question11_answer: str
    examination_board_question2: str
    examination_board_question12_answer: str
    question1: str
    response1: str
    question2: str
    response2: str


class Question(BaseModel):
    question: str
    question_type: Literal["text", "image"]
    image_path: str = None


class SetOfQuestionsResponse(BaseModel):
    question1: Question
    question2: Question