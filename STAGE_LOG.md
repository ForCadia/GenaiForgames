# EverFront stage log

Track: **2D**. Hero assets: player and armored turret family. Supplementary Boss examples are identified separately. Record consolidated on1 November2026 from surviving source, Git and conversation; this is a **retrospective reconstruction**, not a claim that all entries were written contemporaneously.

Rigging Stage3 is optional and not claimed: player animation is frame by frame with code-bound arms/head; the procedural cape is not a skeletal rig. AI trial records below distinguish AI-written code/advice from image or music generation. Account plan tiers, actual task times, without-AI estimates and payments were not recorded in available evidence. **NR means not recorded, not zero.** Ratings are current technical review assessments based on artifacts, not invented scores from an earlier student diary.

## 2D Stage 0 Art direction

Assets: player and turret.

Tool and plan: Codex assisted consolidation of the developer selected pixel science fiction Contra direction. Historical direction predates this audit. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Keep the deep olive player, bone white enemy machinery, blue factory and cyan amber red signal hierarchy.

What came out and what was kept or redone: Kept the established direction; created style/STYLE.md rather than claiming a new concept decision.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Clear roles survived many asset replacements, but late palette/proportion fixes show the guide needed to be formal earlier.

Would a studio use AI here: Use AI to consolidate constraints; the art director must choose and enforce them.

Evidence: GDD.md; style/STYLE.md; d7e6f0a.

## 2D Stage 1 Concept art

Assets: player and main enemy.

Tool and plan: Historical GDD records ChatGPT wording help and two OpenAI ImageGen mood references dated20 September. The original hero concept prompts were not recovered. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Preserve a readable military science fiction runner and distinguish light/heavy machinery.

What came out and what was kept or redone: Kept the game direction. Final supplied hero sheets are not relabeled as surviving concept-stage evidence.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 3. Broad direction is documented; hero-specific concept traceability is incomplete.

Would a studio use AI here: Useful for silhouette exploration with a candidate cap; keep selection and source records.

Evidence: GDD.md source-status section; design_sources/LabA_Zhu_GDD.pdf.

## 2D Stage 2 Final art

Assets: player and turret family.

Tool and plan: User supplied hero sheets; imagegen is directly documented for later alpha extraction, icon work and atlas edits. Original sheet generator/plan is unconfirmed. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Keep silhouettes and palette, remove unusable backgrounds, preserve attachments at play size.

What came out and what was kept or redone: Retained original modular player and turret artwork; replaced run art with the selected16-cell olive sheet.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 3. Art was usable only after scale, palette, crop and attachment work; generated spacing often failed.

Would a studio use AI here: Use AI as an image candidate generator, then budget deterministic production cleanup.

Evidence: 28ce60c; d7e6f0a; player_visual.gd; light_turret_frames.tres.

## 2D Stage 4 Animation

Assets: player and main enemy.

Tool and plan: Codex GDScript and native SpriteFrames integration; imagegen atlas-spacing attempts on later bosses. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Preserve authored frame order and fixed feet/base anchors; synchronize charge/fire and hit frames.

What came out and what was kept or redone: Player runs16cells at22fps without startup; turrets use existing authored charge/fire states. Later Iron sheets use measured gutter y532.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 2. Repeated spill, size drift and lost pivots required explicit metadata; a plausible sheet was not game-ready.

Would a studio use AI here: Use AI for motion ideas, not as the authority on frame count, pivots or hit timing.

Evidence: player_visual.gd; turret_base.gd; iron_boss_frames.gd; 3178caf.

## Shared Stage E Environment

Assets: factory background and track.

Tool and plan: Codex integration of user supplied background layers; original image generator/plan unconfirmed. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Maintain a blue industrial backdrop with lower contrast than combat and no visible scroll seam.

What came out and what was kept or redone: Kept native Parallax2D layers, mirrored repetition and fixed logical track.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Layered art supports atmosphere without adding runtime tools; provenance of original source still needs confirmation.

Would a studio use AI here: AI can explore setting; technical artists must check tiling and camera behavior.

Evidence: main.tscn; README.md backdrop section.

## Shared Stage UI UI art and text

Assets: title HUD settings mission selector.

Tool and plan: Codex layouts and theme; user supplied monitor images; Claude review supplied by user; selected imagegen monitor edits. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Industrial monitor menus, grouped weapon selection, legible below-track hints and explicit failure heading.

What came out and what was kept or redone: Kept monitor frame, hand-authored actual UI text and real controls; rejected stretched stand and rolled back build-tree layout.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Readable system comes from iterative layout decisions; generated decoration did not solve hierarchy.

Would a studio use AI here: Use AI for critique and implementation, keep text/layout in editable controls.

Evidence: NONCOMBAT_UI.md; TITLE_TERMINAL.md; d1d55ef; 180e112.

## Shared Stage VFX Effects

Assets: hit pickup failure and boss presentation.

Tool and plan: Codex procedural effects plus imagegen warning and slash assets. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Use real contact sparks, short reward bursts and clear failure feedback; keep hazards readable.

What came out and what was kept or redone: Settings toggle now switches the three cosmetic particle moments. Retained the custom warning and slash flipbook; discarded incomplete atlas candidates.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 3. Fast visual exploration helped, but wrong crescent direction and poor cell separation needed several corrections.

Would a studio use AI here: AI can draft effects; review frame isolation and gameplay meaning at full speed.

Evidence: main.gd _emit; assets/vfx/*.source.md; 683119f; ee3296a.

## Shared Stage I Integration and review

Assets: whole game.

Tool and plan: Codex source review, metadata inspection, git commits, Godot release export. Recent gameplay review remains user-led. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Preserve live hitboxes, local saves, original assets and historical telemetry while wiring new art/audio.

What came out and what was kept or redone: Kept separate Boss scenes and native audio buses; corrected contact points, foreground flyer hits and shared Iron HP.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Integration was productive with explicit invariants, but inference errors and scale bugs show why export is not playtesting.

Would a studio use AI here: Use AI with version control and concrete checks; require human play and listening acceptance.

Evidence: 0d92de7; 0af35f6; 427bca3; current export logs.

## SFX Stage 1 Spotting

Assets: six plus gameplay sounds.

Tool and plan: Codex mapping of requested user audio files to existing triggers. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: List fire, reload, ricochet, shield, pickup, failure, enemy charge and Boss attacks in priority order.

What came out and what was kept or redone: Kept the trigger list in docs/sound-list.md; did not pretend file count proves pipeline completion.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Explicit trigger mapping made implementation concrete and exposed missing/dead cues.

Would a studio use AI here: Use AI to draft a sound list; verify priorities against actual player decisions.

Evidence: SFX.md; world_audio.gd; docs/sound-list.md.

## SFX Stage 2 Sourcing

Assets: user downloaded effects.

Tool and plan: User provided files; Codex assisted file identification and source-page checking. No AI-generated sound waveform trial is documented. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Match source clips to weapons, coin pickup, buttons, sword attacks and a ballistic cannon.

What came out and what was kept or redone: Kept selected clips; RPG file is now unused because missiles were removed. Directly checked two CC0 pages; other licenses remain unresolved.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 3. Useful matches exist, but a filename was not adequate rights evidence.

Would a studio use AI here: Use AI for search/matching assistance, verify each creator and license.

Evidence: assets/sfx/boss_new_audio.source.json; docs/CREDITS.md.

## SFX Stage 3 Editing and design

Assets: reload button sword cannon.

Tool and plan: Codex-assisted ffmpeg/native audio preparation, deterministic waveform analysis. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Remove leading silence, select a single cannon report and make reload audio fit the existing duration.

What came out and what was kept or redone: Trimmed cannon source0.12..5.1s to exclude its second report; reload pitch follows source length/game duration.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Precise edits solved delayed/repeated sounds; high pitch from time scaling remains a tradeoff.

Would a studio use AI here: Use AI to script repeatable edits; audition transients and tails.

Evidence: 85513ef; UI_SFX.md; assets/sfx/boss_new_audio.source.json.

## SFX Stage 4 Implementation

Assets: all retained sound triggers.

Tool and plan: Codex GDScript and native AudioStreamPlayer voices. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Trigger melee once at execution, stop sustained shield/charge on state exit and isolate Music/SFX buses.

What came out and what was kept or redone: Kept actual state-entry cues, paused voices and reset cleanup; new F10 toggles Master mute without a HUD slider.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Event-based playback avoids per-frame stacking and preserves player timing.

Would a studio use AI here: Strong AI use when event contracts are explicit and reviewed.

Evidence: world_audio.gd; weapon_audio.gd; 46edeaf; game_settings.gd.

## SFX Stage 5 Mixing

Assets: combat and UI mix.

Tool and plan: Codex-assisted offline active-segment RMS calculation plus native limiter. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Balance mismatched files while keeping warnings ahead of music.

What came out and what was kept or redone: Stored per-file gain calibration; reduced overlap for repeated cues; Master limiter ceiling-1dB.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Measured levels are better than arbitrary source volume, but they do not replace browser listening.

Would a studio use AI here: Use AI for analysis/automation, reserve a listening pass for final approval.

Evidence: audio_mix.gd; SOUND_SETTINGS.md; f6b5bad.

## Music Stage 1 Music direction

Assets: regular and Boss tracks.

Tool and plan: Codex/Suno prompt discussion and developer selection. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Energetic pixel science fiction with less noisy orchestration; Chase Mode for Boss, Untitled for regular play.

What came out and what was kept or redone: Kept developer-confirmed mapping and reduced music to make combat cues clearer.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Specific feedback improved the brief; first prompt result was rejected as unsuitable.

Would a studio use AI here: Use AI to explore music direction while designer chooses fit.

Evidence: MUSIC.md; development conversation.

## Music Stage 2 Composition and production

Assets: Chase Mode and Untitled.

Tool and plan: Suno was requested in the workflow; final delivered MP3 files are user supplied. Exact final prompt/model/plan unconfirmed. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Instrumental driving music without masking warnings.

What came out and what was kept or redone: Kept the two selected complete tracks; no unsupported claim about stems, studio recording or human composition.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 3. Usable delivery exists but exact generation and subscription evidence is incomplete.

Would a studio use AI here: Generate candidates, cap exploration and document the account rights.

Evidence: assets/music/*.mp3; MUSIC.md.

## Music Stage 3 Mixing and mastering

Assets: loop derivatives.

Tool and plan: Codex-assisted ffmpeg edit and existing Music/Master bus calibration. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Create a30to90second native loop while retaining original full songs.

What came out and what was kept or redone: Created60.0second Ogg derivatives with0.25second endpoint crossfade; preserved source MP3s and limiter.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 3. Duration and edit are measurable; seam musicality is not certified without audition.

Would a studio use AI here: AI can automate loop construction; a composer/editor must approve the phrase.

Evidence: docs/MUSIC_LOOP_EDIT.md; docs/evidence/music-loops.json.

## Music Stage 4 Implementation

Assets: title ordinary and Boss playback.

Tool and plan: Codex GDScript/native Ogg looping. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Start from menu, switch to Boss track and avoid restarting the same track during retries.

What came out and what was kept or redone: Native looping and separate bus are wired; browser user-gesture unlock and two-browser acceptance are still pending.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. Playback state handling is repeatable, but desktop export alone cannot prove browser audio.

Would a studio use AI here: Use AI for implementation; verify in actual target browsers.

Evidence: music_player.gd; MENU_DEMO.md.

## Voice Stage ALT No voice alternative

Assets: attention budget.

Tool and plan: Codex-assisted rationale, using the assignment permitted alternative. Plan tier NR. Dates are supported by the cited records; original generation dates are not inferred from file modification times.

What I asked for: Rank lethal warnings and player state ahead of narration.

What came out and what was kept or redone: Selected a151word rationale; no casting or recording/captioning work is claimed.

Time: NR minutes. Estimate without AI: NR minutes.

Rating1to5: 4. The alternative matches a one-hit shooter and avoids repetitive spoken warnings.

Would a studio use AI here: AI can structure the argument; the developer must own the attention choice.

Evidence: docs/voice-script.md.



Author confirmation on 1 November 2026: tool/plan was reported verbatim as "gpt pro6.1sol" (GPT Pro / 6.1 sol). This identifies the author-reported tool and plan, not a verified invoice, subscription price, or confirmation of every historical asset generator. Actual charges, stage times and Suno/image generation account tiers remain NR unless separately evidenced. The author also explicitly authorized current gameplay recording, two-browser checks and fresh Windows/Web exports.
