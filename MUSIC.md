# Music integration

On 2026-10-30 the student supplied two completed MP3 files from Downloads and confirmed Chase Mode for the Boss encounter and Untitled for regular background music. The files are copied unchanged into the project.

| File | Role | SHA-256 |
|---|---|---|
| assets/music/chase_mode.mp3 | Boss encounter | B346CBFAA0E0A45022FD1499E395644D65EE0B86456361A243121335297D3539 |
| assets/music/untitled.mp3 | Regular gameplay, victory and return to menu | 768D3F8CB0984179BCE93A30BA92074CF73CCC69617051A53644D0C1342D088B |

Music starts after the first Start or Developer Mode click. One AudioStreamPlayer switches between the two tracks. Segment changes and retries using the same track continue playback; returning from Boss to the campaign or menu switches to Untitled. Music continues during panel pauses. M toggles Master-bus mute in gameplay and menus without restarting playback. Both entry modes use the same audio behavior.

Both original full tracks repeat from the beginning. No trimming, waveform editing, mastering or seamless-loop preparation has been performed. Playback gain starts at -14 dB in music_player.gd; this is an initial integration setting, not a measured loudness target or student-approved mix. Listening acceptance, loop seams and two-browser audio checks remain for the student.

The conversation contains Suno prompt drafts and student feedback, but the exact prompt/model used for each delivered file, generation date, plan tier, saved terms, cost, production time and stage ratings are not confirmed. This integration record does not invent those details or claim completion of the entire Lab C music pipeline.
