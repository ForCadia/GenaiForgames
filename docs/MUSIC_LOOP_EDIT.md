# Music editing and loop delivery

Original full length MP3 files are preserved. Lab C derivatives are assets/music/untitled_loop60.ogg and chase_mode_loop60.ogg. Each decodes to60.0 seconds. Editing used the first60.25 seconds, starting the playable body at0.5 seconds and crossfading its final0.25 seconds into the source opening. The final0.5 second reaches the same source position at which the next loop begins. Ogg Vorbis avoids MP3 encoder delay at the repeat boundary.

Native AudioStreamOggVorbis looping is enabled in music_player.gd. Existing Music bus gains and Master limiter remain; waveform editing is not a claim that a human approved the mix. Original composition, musical phrase compatibility, seam audibility and browser unlock still require listening. Source manifest is docs/evidence/music-loops.json. Current export log is engineering evidence only.

Web audio uses `audio/general/default_playback_type.web=0` (engine Stream mixing). The previous default Sample route produced no measured game signal in both tested browsers; Stream restored music and F10 mute/unmute. Stream also retains the native bus limiter and runtime Ogg loop behavior. This is a Web-only override; desktop rendering and audio routing remain unchanged. See BROWSER_AUDIO_CHECK.md for measured acceptance scope.
