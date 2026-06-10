# pyrefly: ignore [missing-import]

from pydantic import BaseModel
from typing import Literal
from fastapi import File
import speech_recognition as sr


class EvaluationRequest(BaseModel):
    question1: str
    question2: str

    response: str

    examination_board_question1: str
    examination_board_question2: str

    examination_board_answers: str

class ExaminationBoardQuestionsRequest(BaseModel):
    topic_1: str
    topic_2: str
    student_answer: str

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