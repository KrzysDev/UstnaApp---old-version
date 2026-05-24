from app.services.embeddings_service import EmbeddingsService

service = EmbeddingsService()

print(service.create_embedding("Unity is a game engine used for creating games."))