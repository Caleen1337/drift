# Plan projektu — Drift

## Cel

Nie robimy „kolejnego Spotify z innym kolorem”. Robimy **warstwę discovery**,
która używa katalogu/playbacku YouTube Music oraz danych Spotify, ale ma **własny
mózg rekomendacyjny**.

Różnica:

- Spotify/YouTube = źródła muzyki i danych
- nasz system = decyzja, czego użytkownik ma posłuchać

## Fundamenty (ustalone w rozmowie)

| Projekt | Co bierzemy |
|---|---|
| **Metrolist** (GPL-3.0) | warstwa playbacku YouTube Music — **nie wycinamy jej**, forknąć i modyfikować |
| **Meld** (fork Metrolist) | Spotify integration, Spotify→YouTube matching, fuzzy, cache, manual override, queue scoring |
| **Flow / FlowNeuro** (GPL-3.0) | lokalny profil preferencji uczący się z zachowania |
| **LightFM** | hybrydowy recommender (implicit feedback + metadata) — V2 |
| **Aurral** | tryby discovery (Safe/Balanced/Deep), blokowanie, „more like this” |
| **CLAP + FAISS** | audio embeddings + similarity — V3 |
| **Graph/GNN** | discovery po grafie muzycznym — później |

## Architektura V1

```
SPOTIFY (historia / biblioteka / kontekst)
        │
        ▼
EVENT ENGINE  ──>  surowy strumień zdarzeń (training store)
        │
        ├── FlowNeuro (profil gustu)
        ├── Meld baseline (scoring)
        └── OUR RERANKER (novelty + diversity + serendipity + fatigue)
                        │
                        ▼
                 DISCOVERY FEED
                 ❤️  👎  ▶ Play here / ↗ Spotify
```

## V1 — konkretny zakres

1. **Playback foundation** — player iOS, provider YouTube Music (port Metrolist),
   queue, background audio, search, metadata, matching, cache.
2. **Spotify** — login, profil, historia, top tracks/artists, playlisty,
   matching, „Open in Spotify”.
3. **Discovery** — Meld baseline + profil Flow + reranker + ❤️/👎 + sygnały skip +
   wyjaśnienia „Why this?”.
4. **Discovery 2.0** — novelty, diversity, fatigue, exploration, mosty między
   artystami, kontekst sesji.
5. **Developer Lab** — podgląd zdarzeń, debugger modelu, inspektor profilu,
   replay rekomendacji, A/B.

## Roadmap modeli

- **V1** — reguły + Meld baseline + profil w stylu FlowNeuro.
- **V2** — LightFM / hybrydowy recommender.
- **V3** — content-aware (audio embeddings + metadata embeddings).
- **V4** — model sekwencyjny/sesyjny.
- **V5** — globalny model + warstwa personalizacji per user.

## Dane

Zbieramy surowe zdarzenia (nie tylko like/dislike):

```
PLAY_STARTED, PLAY_10/25/50/75/90, PLAY_COMPLETED, SKIPPED,
LIKED, DISLIKED, REPLAYED, SEARCHED, ARTIST_OPENED, ALBUM_OPENED,
QUEUE_ADDED, RECOMMENDATION_CLICKED, OPENED_IN_SPOTIFY
```

Panel deweloperski (osobny, tylko Ty) — monitoring, modele, A/B, eksperymenty.

## Open source i licencje

- Metrolist i Flow = GPL-3.0 → nasz projekt dystrybuowany jako GPL-3.0.
- README jawnie wskazuje projekty bazowe i autorów.
- Dane użytkowników nigdy do repo; pseudonimizacja; opt-in.
