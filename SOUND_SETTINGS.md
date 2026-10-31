# Audio mix and settings — 2026-10-31

Entry points: main menu **SETTINGS**, or **Esc → SETTINGS** during play. Settings apply immediately and save locally to `user://settings.cfg`. Esc/Back from the page returns to the pause menu while the game stays paused. Combat HUD volume/mute controls and the M shortcut are removed.

Options: Master / Music / Sound Effects volume (0–100%), mute all, desktop fullscreen, vertical sync, tutorial hints, reduced grenade flash and death-camera motion. Includes sound preview and restore defaults. Fullscreen is disabled in the editor's embedded preview, whose sizing is controlled by Godot. Web uses browser display controls. Audio and presentation options do not change movement, weapons, checkpoints or tester telemetry. The `--lab-test` flag disables reading/writing user settings.

The native Music and SFX buses feed Master. A Godot AudioEffectHardLimiter with a -1 dB ceiling protects the summed mix against overlapping peaks. Original audio files, durations and reload pitch-fitting are retained. `audio_mix.gd` is the single per-file gain table shared by weapons, world effects, music and the preview player.

Offline analysis decodes stereo PCM at 24 kHz, computes RMS over active 50 ms windows (within 30 dB of the loudest window), and measures sample peaks. This is active RMS calibration, not LUFS measurement or a claim of perceptual listening validation. Main combat cues target roughly -21 to -24 dBFS active RMS, reload/switch around -24 to -25, shield/drone -27 to -29 and music -29. Most clips keep 3 dB individual peak headroom. Boss explosion is an exception: its high crest factor needs extra gain to bring the body up; the Master limiter controls the brief peak. Boss countdown was unusually quiet (~-49 dBFS active RMS) and is raised independently; shield and several turret clips are attenuated.

The source files remain unchanged. The offline measurement script is `tools/analyze_audio_mix.py`, using the already-present tooling FFmpeg under ignored `tmp/video-tools/`; its output belongs in `tmp/audio_levels.json`. This is development tooling, not a game runtime dependency.

Settings selection follows the [Xbox Audio Accessibility Guideline](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/105), which recommends separate controls for different audio classes, and [Godot's limiter documentation](https://docs.godotengine.org/en/4.7/classes/class_audioeffecthardlimiter.html). Dialogue and voice-chat controls are omitted because this game has neither.

Files were statically reviewed and source audio levels were measured offline. `tests/settings_smoke.gd` covers bus independence, mute, settings navigation and paused time; it is provided for the user's verification. Game/runtime tests and packaging were not run, following the user's request to test the modified project themselves.
