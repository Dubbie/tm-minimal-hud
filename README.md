# Minimal HUD

Hide the parts of the Trackmania HUD you don't need, with one key. A plugin for [Openplanet](https://openplanet.dev/).

## Features

- Toggle minimal mode with `F8`, everything comes back when you turn it off
- Supported native HUD elements:
  - records
  - respawn helper
  - countdown
  - best race viewer
  - time gap
  - bottom timer
  - checkpoint splits
- Hide overlays from other plugins. Currently supported:
  - Dashboard
  - Grinding Stats
  - Checkpoint Counter
  - Split Speeds
- Hide the native chat and Better Chat
- Presets: make your own, rename or delete them, and switch between them with `F9`
- Keybinds can be changed in the Settings menu

## Presets

Presets are edited in Openplanet's settings, under Minimal HUD → HUD. Ticking a box changes the preset you have selected.

They're saved to `presets.json` in the plugin's storage folder. If that file ever gets broken, it's moved to `presets.broken-<date>.json` and the plugin starts again with Default, so you can still get your presets back from it.

## How other plugins are hidden

Minimal HUD doesn't draw over other plugins. It turns off their display settings while minimal mode is on, and puts back exactly what you had when it turns off, when you leave a map, or when Minimal HUD is disabled. Your original values are also saved to `snapshots.json`, so they're put back the next time Minimal HUD loads, even after crashes.

## Known limitations

- The native chat isn't re-hidden every frame, so it can show up again until the next re-apply.
- Better Chat shows while the Openplanet overlay (`F3`) is open.

## Issues

Found a bug or want something else to be hideable? [Open an issue](https://github.com/Dubbie/tm-minimal-hud/issues), or message me on Discord: `Subesz`.
