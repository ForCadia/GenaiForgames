# UI button audio — 2026-10-31

Both user-provided new files are button sounds, not coin sounds.

- `assets/sfx/ui_click.wav`: extracted 0.10–0.62 seconds from Downloads/buttonpress_needrevise.wav (23.260s source, eleven distinct active regions). Preserves stereo/44.1kHz, converts 24-bit PCM to Godot-friendly 16-bit PCM, no speed change. Runtime gain -3.0dB.
- `assets/sfx/ui_error.wav`: unchanged copy of Downloads/327738__distillerystudio__error_01.wav, approximately 0.991s, mono/48kHz/16-bit. Runtime gain -4.12dB.

Original Downloads files remain unchanged. Source authorship/license evidence was not supplied here; the error source filename identifies distillerystudio and asset 327738, without assuming a license.

UIAudio attaches once to native BaseButtons: valid presses play the click, disabled mouse clicks play the error, and blank/unreadable name-load actions explicitly reject. Error has short priority protection so the normal confirmation cannot immediately overwrite it. Hover/focus remain silent. Both route through the saved SFX/Master settings and limiter and run while the menu pauses gameplay. Coin audio is intentionally unchanged pending the user's separate asset.

Godot import and ui_audio_smoke/settings_smoke passed. UI-audio smoke covers click/error routing, failure priority, native button registration and SFX volume routing. Shutdown resource cleanup warnings still occur in the audio test; no claim of a completed human listening pass is made.
