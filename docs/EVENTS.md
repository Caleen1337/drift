# Schemat zdarzeń

## `PlaybackEvent`

| Pole | Typ | Opis |
|---|---|---|
| `id` | UUID | unikalne |
| `anonymousUserId` | String | pseudonimizowany id |
| `sessionId` | String | sesja |
| `timestamp` | Date | czas |
| `trackId` | String | kanoniczny id utworu |
| `artistId` | String | |
| `recommendationId` | String? | gdy zdarzenie dotyczy rekomendacji |
| `position` | Int? | pozycja w feedzie |
| `type` | EventType | zob. niżej |
| `completionRatio` | Double? | 0…1 |
| `source` | EventSource | ourPlayer / spotify / youtubeMusic / manual |
| `context` | [String:String] | flagi np. `isNovel`, `blockArtist` |

## `EventType`

```
playStarted, playProgress, playCompleted, skipped, liked, disliked,
replayed, searched, artistOpened, albumOpened, queueAdded,
recommendationClicked, openedInSpotify
```

## Wagi sygnałów (startowe, kalibrowane później)

| Sygnał | Waga |
|---|---|
| like | +1.0 |
| dislike | −1.0 |
| skip ≤10% | −0.7 |
| skip ≥80% | −0.1 |
| pełny odsłuch | +0.3 |
| replay | +0.8 |
| opened in Spotify | +0.2 |
| artist opened | +0.2 |

## Rozdział danych

- **Prywatny profil** — zostaje na urządzeniu.
- **Telemetria** — pseudonimizowana, opt-in, używana do ewaluacji/treningu
  globalnego rankera (nie do kopiowania konta użytkownika).

## Event → profil (EventEngine)

Każde zdarzenie aktualizuje: affinity artysty/gatunku/sceny/nastroju, liczniki
fatigue (recent artist/genre), zbiór odsłuchanych utworów, tolerancję nowości
(`noveltyTolerance`), skłonność do eksploracji oraz listy blokad.
