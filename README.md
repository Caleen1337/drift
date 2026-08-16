# Drift — Music Discovery Client for iOS

Drift is a **discovery-first** music client. It does not try to predict what you
will click next; it tries to find music you don't know yet but will probably love.

The core idea:

```
Spotify (data)  ─┐
                 ├─>  our discovery engine  ──>  ▶ Play here  (YouTube Music)
YouTube (audio) ─┘                              └─>  ↗ Open in Spotify
```

## Why

Spotify / YouTube Music optimise for engagement. Drift optimises for discovery:

```
RELEVANCE + NOVELTY + DIVERSITY + SERENDIPITY + CONTEXT - FATIGUE
```

## Repositories / projects this is based on

- [Metrolist](https://github.com/Metrolist-org/metrolist) — YouTube Music playback
  layer (GPL-3.0). Used as the playback foundation; not reimplemented from scratch.
- [Meld](https://github.com/meld-app/meld) — Spotify ↔ YouTube Music integration,
  fuzzy matching, match cache, manual override, queue scoring.
- [Flow / FlowNeuro](https://github.com/Flow-Neuro/Flow) — local preference /
  recommendation profile that learns from behaviour.

See `docs/` for the full plan, architecture, event schema and UX.

## Structure

```
music-discovery/
├── Core/          # portable Swift package — all discovery logic, no UI
├── iOS/           # SwiftUI app (sideloadable IPA via XcodeGen + AltStore/Sideloadly)
├── admin/         # developer-only dashboard (FastAPI) for monitoring & experiments
├── ml/            # model training pipeline (LightFM and friends)
└── docs/          # PLAN / ARCHITECTURE / EVENTS / UX
```

## Building without a Mac (GitHub Actions)

You do **not** need a Mac. Push this repo to GitHub and CI will:

1. Run the Core tests on Linux (`swift test`).
2. Build an unsigned `Drift.ipa` on a macOS runner (XcodeGen + `xcodebuild`).

Download the artifact from the Actions tab. To install it on your iPhone you must
sign it with your own Apple ID / developer certificate (e.g. via AltStore,
Sideloadly, or a signing service). The unsigned IPA is the portable build output.

## Developing on Linux (Arch)

The discovery engine in `Core/` is pure Swift and runs anywhere. The test
suite is already green (7 tests).

```bash
# Option A (recommended, one command, needs password):
yay -S swift-bin

# Option B (no root — downloads swift-bin + libxml2-legacy locally):
bash scripts/install-swift-linux.sh
source scripts/swift-env.sh

cd Core
swift test
```

## Building the iOS app on a Mac

1. `brew install xcodegen`
2. `xcodegen generate`
3. Open `Drift.xcodeproj`, select your signing team, build.
4. Sideload the IPA with AltStore / Sideloadly / TrollStore.

## Credentials you must provide

- **Spotify**: register an app at developer.spotify.com → `client_id` + `redirect_uri`.
- **YouTube Music**: an Innertube `WEB_REMIX` API key (passed to `InnertubeClient`).
- **Playback**: integrate the Metrolist-derived stream layer behind `StreamResolver`.

## License

GPL-3.0. See `LICENSE`.
