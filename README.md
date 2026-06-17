# UstnaApp – AI‑powered oral‑exam assistant for Polish Matura

## Project overview
UstnaApp is a full‑stack application that helps high‑school students prepare for the **Polish oral matura**.  It combines a modern **Flutter** frontend with a **FastAPI** backend powered by large‑language‑model (LLM) services.  The system can:
- provide an official question bank (CKE) with searchable topics and texts,
- simulate an oral exam where the user records an answer via microphone,
- automatically transcribe the audio, retrieve relevant knowledge from a vector store, and generate a **detailed grading report** based on the official matura criteria.

The backend uses a **RAG (retrieval‑augmented generation)** pipeline: the user’s answer is turned into semantic queries, relevant fragments are fetched from a knowledge base, re‑ranked, synthesized, and finally evaluated by the LLM.

---

## Key features
| Feature | Description |
|---|---|
| **Question bank** | Browse official CKE questions and obligatory literature references. |
| **Exam simulation** | Randomly select a pair of topics, record an answer, and receive instant feedback. |
| **AI grading** | Uses a custom prompt chain to produce a JSON‑structured score (`score`, `summary`, `errors`). |
| **Audio transcription** | Powered by `speech_recognition` (Google Speech API) to turn recorded wav files into text. |
| **Vector‑DB lookup** | Knowledge is stored in Qdrant (or any compatible vector DB) and queried with semantic search. |
| **Rate limiting** | FastAPI‑Limiter protects the public endpoints (5 requests per minute per IP). |
| **Google‑Sign‑In** | Frontend authenticates users via Supabase + Google OAuth. |

---

## Backend (FastAPI)
- **Main entry point**: `backend/app/main.py`
- **Endpoints** (prefixes):
  - `/transcribing` – upload audio, return transcription (Speech recognition)
  - `/response-evaluation` – evaluate a student's answer, returns JSON score
  - `/examination-board-questions` – generate two follow‑up questions for the examiner
  - `/set-of-questions` – return a random set of official tasks
- **LLM integration** (`app/services/ai_service.py`):
  - Uses **Ollama** (local or hosted) when `AI_TESTING=true`
  - Falls back to **OpenRouter** (e.g., Gemini) in production
- **Vector DB** (Qdrant)
- **Rate limiting** handled by `app/utils/limiter.py`
- **Environment variables** (see `.env.example`):
  - `REDIS_URL` – Redis instance for rate limiting
  - `OLLAMA_API_KEY` – key for Ollama API (testing mode)
  - `OPENROUTER_API_KEY` – key for production LLM endpoint
  - `SITE_URL`, `SITE_NAME` – optional metadata for OpenRouter

---

## Frontend (Flutter)
- Entry point: `frontend/ustnaapp/lib/main.dart`
- Uses **Supabase Flutter** for authentication and **Google Sign‑In**.
- UI is built with **Google Fonts (Outfit)** and a dark theme.
- Core screens:
  - `login_screen.dart` – Google OAuth login
  - `dashboard_screen.dart` (not shown) – main navigation after login
  - `exam_provider.dart` – state management for fetching questions, uploading audio, and displaying the AI report.
- Assets include several decorative PNGs (`flutter_01.png` … `flutter_05.png`).

---

### Getting started locally
### 1. Clone the repository
```bash
git clone <repo-url>
cd UstnaApp
```

### 2. Set up the backend
```bash
cd backend
python -m venv venv
source venv/bin/activate   # on Windows: venv\Scripts\activate
pip install -r requirements.txt
```
Create a `.env` file (copy from `.env.example` if present) and set the required keys:
```dotenv
REDIS_URL=redis://localhost:6379
OLLAMA_API_KEY=your_ollama_key   # for testing mode
OPENROUTER_API_KEY=your_openrouter_key   # for production
AI_TESTING=true   # set to false to use OpenRouter
```
Start Redis and Qdrant (Docker example):
```bash
docker run -d --name redis -p 6379:6379 redis:7-alpine
docker run -d --name qdrant -p 6333:6333 qdrant/qdrant
```
Run the API server:
```bash
uvicorn app.main:app --reload
```
The documentation is available at <http://127.0.0.1:8000/docs>.

### 3. Set up the Flutter frontend
```bash
cd ../frontend/ustnaapp
flutter pub get
flutter run   # selects a device or emulator
```
The app will automatically point to the backend at `http://127.0.0.1:8000` (adjust `baseUrl` in `exam_provider.dart` if needed).

---

## Testing & linting
Backend:
```bash
pytest   # runs unit & integration tests (if any)
flake8 .  # style check
```
Frontend:
```bash
flutter test
flutter analyze
```

*Happy studying and good luck on your matura!*
