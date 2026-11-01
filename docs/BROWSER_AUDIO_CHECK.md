# Local two-browser audio check — 1 November 2026

Tested the actual exported Web files over local HTTP using Edge and Firefox in isolated, fresh browser contexts. Browser automation ran headless. This is instrumented signal verification, not a human headphone listening test or public Duke deployment check.

| Browser | Music signal | F10 mute | F10 restore | Isolated SFX preview | Beyond 60s loop |
|---|---|---|---|---|---|
| Edge 153.0.4234.48 | PASS | PASS | PASS | PASS | PASS |
| Firefox 157.0 | PASS | PASS | PASS | PASS | PASS |

Method: observe the WebAudio destination with an analyser through a zero-gain diagnostic branch; read RMS/peak after interaction, after F10, with Music volume at zero and SFX preview, and beyond 63 seconds. An oscillator self-test confirms the probe can detect signal; its values are excluded from game acceptance. Runtime files are not instrumented on disk; the hook exists only in the test browser. Original audio routing remains audible once, without duplicate gain.

Findings/fixes: the default Web Sample route produced zero measured game output while the oscillator worked. A Web-only engine Stream override restored music/SFX, native limiter mixing and runtime Ogg looping. F10 initially failed while the main scene was paused by menus; moving it to the always-processing settings node fixed menu input dispatch. The settings regression and targeted GUI-input/particle checks passed.

Both browsers loaded the real menu without JS exceptions or Godot script errors. They reported WebGL buffer warnings, retained in the JSON console evidence rather than hidden. Rendering was visually checked in saved screenshots. No claim is made of exhaustive gameplay testing, subjective loop-seam approval, speaker/headphone balance or the deployed public URL.

Raw evidence: evidence/browser-audio-results.json. Final exports completed with exit 0. Video decode check completed with no errors; native mixed comparison audio peak is -4.2 dBFS. Final source has no online AI/runtime dependency.


Author confirmation, 1 November 2026: all supplied game artwork is AI-generated; sound effects are from Freesound; Chase Mode and Untitled BGM are from Suno. The author confirms the browser acceptance passed. This is author confirmation, separately attributed from automated measurements. Exact historical stage times/charges remain not recorded; no reconstruction is requested. Per-file Freesound licenses and generation-account terms are not inferred from platform names.
