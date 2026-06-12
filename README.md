# Card War — iOS

A small two-player card "War" game for iOS, built with **UIKit + Storyboard (MVC)**.

The player is greeted by name, assigned a side (East/West) based on their real
location, then plays 10 automatic rounds against the house (PC). The stronger
card each round scores a point; after 10 rounds a summary screen shows the
winner.

## Screens

| Screen | What it does |
| --- | --- |
| **Menu** | Enter & save your name, sample location → pick your side, START button. |
| **Game** | Auto-runs 10 rounds. Every 5s a new pair of cards flips up (shown 3s), score updates, countdown in the middle. |
| **Summary** | Shows the winner and their score, with a button back to the menu. |

## Rules

- Side is decided by longitude: **east of `34.817549168324334` → East Side**, otherwise **West Side**.
- Each round both players get a random card; the stronger card (2…14, Ace high) scores.
- Equal cards are ignored (no point).
- After 10 rounds the game ends. **A tie is won by the house (PC).**
- The game needs both a **name** and a **location** before START is enabled.

## Features

- 🌙 **Dark / night mode** — globes redraw with a night palette, text uses dynamic system colours.
- 📱 **Portrait & landscape** — layout is fully Auto Layout / stack-view based.
- 🔊 **Sound** — card-flip and win effects (built-in system sounds). Optional looping background music (see below).
- ♻️ **Lifecycle aware** — the round clock and music stop when you leave the screen or background the app, and resume on return.

## Project structure

```
CardWar/
├─ AppDelegate.swift / SceneDelegate.swift
├─ Models/        PlayerSide, PlayingCard, Deck, GameEngine   (pure logic)
├─ Services/      LocationService, NameStore, SoundManager
├─ Views/         GlobeView, CardView
├─ Controllers/   MenuViewController, GameViewController, SummaryViewController
└─ Base.lproj/    Main.storyboard, LaunchScreen.storyboard
```

## Running

1. Open `CardWar.xcodeproj` in Xcode.
2. Pick an iPhone simulator and press **Run** (⌘R).
3. To test sides without moving: in the Simulator, **Features ▸ Location ▸ Custom Location…** and enter a longitude east or west of `34.8175`.

## Optional: background music

Background music is wired up but no track is bundled by default. To add one:
drag an audio file named **`background.mp3`** into the `CardWar` target (check
"Copy items if needed" and the target membership). It will loop during the game
and stop when the game stops. No code changes needed.

## Demo

_Add screenshots and a short video here before submission._
