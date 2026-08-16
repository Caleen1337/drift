# Discovery Lab — developer panel

Developer-only dashboard (FastAPI + static HTML) for monitoring the app and
running model experiments. Not shipped to end users.

## Run

```bash
cd admin/backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8080
```

Open http://127.0.0.1:8080

## Endpoints

- `POST /ingest` — ingest a pseudonymised event
- `GET /metrics` — aggregated counts
- `GET /events?limit=50` — recent events
- `GET /health`
