from app.models.prompts import CONTEXT_SYNTHESIS_PROMPT
from app.services.ai_service import AiService
from app.services.vector_db_service import VectorDBService
from app.models.prompts import *

class ResponseEvaluationService:
    def __init__(self):
        self.ai_service = AiService()
        self.vector_db_service = VectorDBService()

    def evaluate(
        self,
        question: str,
        response: str,
        examination_board_question1: str = "",
        examination_board_question2: str = "",
        examination_board_answers: str = "",
        question2: str = ""
    ) -> str:

        print("Generating retrieval queries...")

        retrieval_queries = self.ai_service.ask(
            RETRIEVAL_QUERY_GENERATION_PROMPT.format(
                exam_question=question,
                exam_question2=question2,
                student_answer=response,
                examination_board_question1=examination_board_question1,
                examination_board_question2=examination_board_question2,
                examination_board_questions_answer=examination_board_answers,
            )
        )

        print("Retrieving documents...")

        documents = self.vector_db_service.retrieve(
            retrieval_queries
        )

        print("Reranking / synthesizing context...")

        reranked_context = self.ai_service.ask(
            CONTEXT_SYNTHESIS_PROMPT.format(
                exam_question=question,
                exam_question2=question2,
                student_answer=response,
                filtered_chunks=documents,
                examination_board_question1=examination_board_question1,
                examination_board_question2=examination_board_question2,
                examination_board_questions_answer=examination_board_answers,
            )
        )

        print("Evaluating...")

        evaluation_prompt = EVALUATION_PROMPT.format(
            exam_question=question,
            exam_question2=question2,
            student_answer=response,
            rag_context=reranked_context,
            examination_board_question1=examination_board_question1,
            examination_board_question2=examination_board_question2,
            examination_board_answer=examination_board_answers,
        )

        return self.ai_service.ask(evaluation_prompt)