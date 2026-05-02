# API Documentation - Smart Meeting Minutes Generator

## Base URL
- Flask Backend: `http://localhost:5000`
- Bot Server: `http://localhost:3000`

## Authentication

Protected endpoints require Firebase ID token in the Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

---

## Flask Backend

### Health Check
```
GET /api/health
```
Response: `{ "ok": true, "service": "minutes-generator" }`

### Generate Minutes (no auth required for backwards compatibility)
```
POST /api/generate-minutes
Content-Type: multipart/form-data
  - audio: file (required)
  - meeting_id: string (optional, default "unknown")

Optional: Authorization: Bearer <token> (saves to Firestore if uid present)
```
Response:
```json
{
  "success": true,
  "meeting_id": "meeting123",
  "filename": "meeting123_20250210_120000.m4a",
  "file_size": 1234567,
  "transcription_done": true,
  "minutes": {
    "meeting_date": "2025-02-10",
    "participants": [{"name": "Speaker 1"}],
    "topics": [{"title": "Topic 1", "summary": "..."}],
    "decisions": [{"text": "..."}],
    "action_items": [{"task": "...", "owner": "...", "deadline": "..."}],
    "summary": "...",
    "transcript": [{"start": 0.0, "end": 2.5, "speaker": "Speaker 1", "text": "..."}],
    "metadata": {}
  },
  "message": "Recording saved. Minutes generated."
}
```

### Create Meeting (auth required)
```
POST /api/meetings
Authorization: Bearer <token>
Content-Type: application/json
{
  "room_name": "my-room",
  "title": "Project Sync"
}
```
Response: `{ "success": true, "meeting_id": "...", "room_name": "my-room" }`

### Update Meeting Status (auth required)
```
PATCH /api/meetings/<meeting_id>/status
Authorization: Bearer <token>
Content-Type: application/json
{
  "status": "live" | "bot_joining" | "recording" | "processing" | "completed" | "failed"
}
```

### Get Meeting (auth required)
```
GET /api/meetings/<meeting_id>
Authorization: Bearer <token>
```
Response: Meeting document with minutes if completed.

### Save Recording (legacy)
```
POST /api/save-recording
Content-Type: multipart/form-data
  - audio: file
  - meeting_id: string
```
Response: `{ "success": true, "filename": "..." }`

---

## Bot Server

### Health
```
GET /api/health
```
Response: `{ "ok": true, "service": "bot-server", "active": 0 }`

### Start Recording
```
POST /api/start-recording
Content-Type: application/json
{
  "room_name": "jitsi-room-name",
  "meeting_id": "meeting123",
  "participants": [{"id": "p1", "name": "Alice"}],
  "authToken": "<firebase_id_token>",
  "backendBaseUrl": "http://PC_IP:5000"
}
```
Response: `{ "success": true, "room_name": "...", "meeting_id": "..." }`

### Stop Recording
```
POST /api/stop-recording
Content-Type: application/json
{
  "room_name": "jitsi-room-name",
  "participants": [{"id": "p1", "name": "Alice"}],
  "authToken": "<firebase_id_token>",
  "backendBaseUrl": "http://PC_IP:5000"
}
```
Response: `{ "success": true, "recording_path": "/path/to/file.webm" }`

---

## Environment Variables

### Flask Backend
| Variable | Description |
|----------|-------------|
| GOOGLE_APPLICATION_CREDENTIALS | Path to Firebase service account JSON |
| FIREBASE_PROJECT_ID | Firebase project ID |
| WHISPER_MODEL | Whisper model (tiny, base, small, medium, large) |
| OPENAI_API_KEY | For LLM summary generation |
| PYANNOTE_AUTH_TOKEN | For speaker diarization (HuggingFace) |

### Bot Server
| Variable | Description |
|----------|-------------|
| JITSI_SERVER_URL | Jitsi server (default https://meet.jit.si) |
| BOT_HEADLESS | true/false for browser visibility |
| BOT_RECORD_DURATION | Recording duration in seconds |
| BOT_PORT | Server port (default 3001) |
