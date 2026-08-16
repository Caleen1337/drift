"""Train a LightFM hybrid recommender from canonical events.

Reads events from the Discovery Lab SQLite DB, builds a user/track interaction
matrix, trains LightFM and saves the model.

Run:
    pip install -r requirements.txt
    python train_lightfm.py --db ../admin/backend/drift.db --out model/
"""

import argparse
import sqlite3
import os

import numpy as np

try:
    from lightfm import LightFM
    from lightfm.data import Dataset
    HAS_LIGHTFM = True
except ImportError:
    HAS_LIGHTFM = False


def load_interactions(db_path: str):
    con = sqlite3.connect(db_path)
    rows = con.execute(
        "SELECT anonymous_user_id, track_id, type FROM events"
    ).fetchall()
    con.close()

    # Coarse, tunable feedback weights per event type.
    weights = {
        "liked": 1.0,
        "playCompleted": 0.6,
        "replayed": 0.8,
        "openedInSpotify": 0.2,
        "skipped": -0.5,
        "disliked": -1.0,
    }
    data = []
    for user, track, typ in rows:
        w = weights.get(typ, 0.1)
        data.append((user, track, w))
    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", required=True)
    parser.add_argument("--out", default="model/")
    parser.add_argument("--epochs", type=int, default=20)
    args = parser.parse_args()

    if not HAS_LIGHTFM:
        raise SystemExit("Install lightfm first: pip install -r requirements.txt")

    interactions = load_interactions(args.db)
    if not interactions:
        raise SystemExit("No events found in DB.")

    dataset = Dataset()
    users = sorted({u for u, _, _ in interactions})
    tracks = sorted({t for _, t, _ in interactions})
    dataset.fit(users, tracks)
    (interactions_matrix, weights_matrix) = dataset.build_interactions(
        [(u, t, w) for u, t, w in interactions]
    )

    model = LightFM(loss="warp")
    model.fit(interactions_matrix, sample_weight=weights_matrix, epochs=args.epochs, num_threads=4)

    os.makedirs(args.out, exist_ok=True)
    np.save(os.path.join(args.out, "user_embeddings.npy"), model.user_embeddings)
    np.save(os.path.join(args.out, "item_embeddings.npy"), model.item_embeddings)
    print(f"Trained model saved to {args.out}")


if __name__ == "__main__":
    main()
