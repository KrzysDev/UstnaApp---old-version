from app.services.vector_db_service import VectorDBService

service = VectorDBService()

print(service.retrieve("Gdzie rozgrywa się akcja Antygony?", k=5))