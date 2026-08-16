"""Discovery Lab — developer-only backend.

Ingests pseudonymised events from the iOS app and exposes aggregated metrics
and a recommendation debugger. This is NOT part of the end-user app.
"""

import os
import sqlite3
import uuid
from datetime import datetime, timezone

from fastapi import FastAPI, Request
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

DB_PATH = os.environ.get("DRIFT_DB", os.path.join(os.path.dirname(__file__), "drift.db"))
DASHBOARD = os.path.join(os.path.dirname(__file__), "..", "dashboard", "index.html")

app = FastAPI(title="Discovery Lab")


def conn():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    return con


def init_db():
    con = conn()
    con.execute(
        """
        CREATE TABLE IF NOT EXISTS events (
            id TEXT PRIMARY KEY,
            anonymous_user_id TEXT NOT NULL,
            session_id TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            track_id TEXT NOT NULL,
            artist_id TEXT NOT NULL,
            type TEXT NOT NULL,
            completion_ratio REAL,
            source TEXT NOT NULL,
            context TEXT NOT NULL
        )
        """
    )
    con.commit()
    con.close()


init_db()


class EventIn(BaseModel):
    anonymous_user_id: str
    session_id: str
    track_id: str
    artist_id: str
    type: str
    completion_ratio: float | None = None
    source: str = "ourPlayer"
    context: dict | None = None


@app.post("/ingest")
def ingest(event: EventIn):
    con = conn()
    con.execute(
        """
        INSERT INTO events (id, anonymous_user_id, session_id, timestamp, track_id,
                            artist_id, type, completion_ratio, source, context)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            str(uuid.uuid4()),
            event.anonymous_user_id,
            event.session_id,
            datetime.now(timezone.utc).isoformat(),
            event.track_id,
            event.artist_id,
            event.type,
            event.completion_ratio,
            event.source,
            str(event.context or {}),
        ),
    )
    con.commit()
    con.close()
    return {"ok": True}


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/metrics")
def metrics():
    con = conn()
    total = con.execute("SELECT COUNT(*) FROM events").fetchone()[0]
    users = con.execute("SELECT COUNT(DISTINCT anonymous_user_id) FROM events").fetchone()[0]
    by_type = {
        row["type"]: row["c"]
        for row in con.execute("SELECT type, COUNT(*) AS c FROM events GROUP BY type")
    }
    con.close()
    return {
        "totalEvents": total,
        "users": users,
        "byType": by_type,
    }


@app.get("/events")
def events(limit: int = 50):
    con = conn()
    rows = con.execute("SELECT * FROM events ORDER BY timestamp DESC LIMIT ?", (limit,)).fetchall()
    con.close()
    return [dict(row) for row in rows]


@app.get("/")
def dashboard():
    return FileResponse(DASHBOARD)


@app.exception_handler(404)
async def not_found(request: Request, exc):
    return JSONResponse({"error": "not found"}, status_code=404)
