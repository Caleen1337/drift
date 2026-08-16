# ML pipeline

Canonical events (from the app / Discovery Lab) → interaction matrix → model.

## Roadmap

- **V1** — rules + Meld baseline + FlowNeuro profile (already in `Core/`).
- **V2** — LightFM hybrid recommender (`train_lightfm.py`).
- **V3** — content-aware (CLAP audio embeddings + FAISS similarity).
- **V4** — sequence/session model.
- **V5** — global model + per-user personalization layer.

## Train

```bash
cd ml
pip install -r requirements.txt
python train_lightfm.py --db ../admin/backend/drift.db --out model/
```

> Data separation note: user profiles stay on-device. Only pseudonymised,
> opt-in events are used for global model training.
