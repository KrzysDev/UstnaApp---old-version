# pyrefly: ignore [missing-import]

from pydantic import BaseModel
from typing import Literal
from fastapi import File


class EvaluationRequest(BaseModel):
    examination_board_question1: str
    examination_board_question11_answer: str
    examination_board_question2: str
    examination_board_question12_answer: str
    question1: str
    response1: str
    question2: str
    response2: str


from pydantic import BaseModel
from typing import Literal, Optional


class Question(BaseModel):
    question: str
    question_type: Literal["text", "image", "poem"]
    
    image_base64: Optional[str] = None      
    image_mime_type: Optional[str] = None          
    image_filename: Optional[str] = None


class SetOfQuestionsResponse(BaseModel):
    question1: Question
    question2: Question