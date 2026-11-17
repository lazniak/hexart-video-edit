# Changes

Polska wersja: [CHANGELOG.pl.md](CHANGELOG.pl.md).

## 0.19.43 (2026-11-17)

- Render queue: the thumbnail on a bar is larger (160x90 points on a wide panel) and as tall as
  the whole content of the bar, instead of sitting in a corner. The picture of the last frame of
  every render is remembered (a small WebP in the cache, cleaned like other previews), so a bar
  has a picture after a restart of the program too, and for renders of an agent and of the
  background process.
- Render queue: a bar says how the render went. Done: how long it took and at what speed (for
  example "Rendered in 1 min 25 s · 50 fps, 2.0x"). An error, a cancel or an interruption: at
  which timecode, which frame of how many and at what percentage it stopped, after how long and
  for what reason; the progress bar stays at that point. The timecode is the one the playhead
  shows for that frame (sequence time from zero, without drop frames), so you can go there; the
  sequence's own timecode (start timecode, drop frame) is in the tooltip when it differs. The
  frames are the rendered ones, handed to the encoder: after an error the file can hold a few
  frames fewer. During a render the time that has passed shows next to the time left. A render
  the program did not finish (closed, crashed) is marked as interrupted at the next start and
  shows how far it got.
- Render queue: an agent reads the same numbers in `export_status` (start and end, frames
  rendered of those planned, `stopped_at`, the real-time factor, `outcome`). A render
  interrupted by closing the program or killing the background process has the state
  `interrupted`, and after a restart of the program `export_status` also answers by the
  `queue_id` of the bar, even when the job number no longer exists. The fields that were there
  before, `timecode` among them, mean what they meant.
- Render queue: in a narrow dock a bar takes the size of its thumbnail and the wrapping of its
  text from the visible width of the panel, and the row of buttons above the list wraps, so
  nothing of a bar leaves the panel.

## 0.19.42 (2026-11-17)

- The window after an update shows the release notes in the language of the interface: Polish
  in a Polish interface, English in an English one and in every other language (until now
  always Polish, with a note saying so). Switching the language while the window is open
  switches the notes too. Release notes on GitHub are now in English, with a link to the Polish
  version, and the README, the security file and the bug report form have the English text
  first. Every earlier version has full English notes, and hve.hexart.io shows in English the
  same notes as GitHub. The public Polish changelog is in `CHANGELOG.pl.md` and no longer
  carries task numbers in brackets.

## 0.19.41 (2026-11-17)

- Fix: 10-bit and 12-bit footage (ProRes, DNxHR, HEVC, XAVC) now has the same levels in Pixel
  Motion frames, in resized exports and on the full-depth monitor as in a 1:1 export. Until now
  such frames were slightly different: shadows about 1.7 code values (out of 1023) higher and highlights
  lower, and with 12 bits and footage with alpha the whole picture 0.4% darker, so a computed
  frame could flicker next to a source frame. The alpha channel of 10-bit footage now reaches
  full opacity (it was 99.9%). The same applies to decoding on an NVIDIA graphics card, also
  for footage in full range. Pixel Motion frames and In to Out renders of such clips will be
  computed once again.

## 0.19.40 (2026-11-17)

- Stabilization works on a sequence placed on the timeline and read as a native clip
  (Sequence interpretation: Native clip). The camera is analyzed from the frames of the
  sequence itself, after the analyses of the stabilized clips inside it. When you later change
  something inside the sequence, nothing is analyzed by itself: stabilization keeps using the
  old analysis, the effect row shows "Sequence changed" in red, and a new analysis starts only
  with the "Re-analyze" button (one change, undoable). Undoing the changes in the sequence
  restores the ready state without any computing. Exporting such a sequence does not wait and
  does not analyze: the export window says in red that the old analysis will be used. A
  sequence read as a nest has no frames of its own, so the effect suggests changing the
  interpretation. The agent sees the `changed` state in `camera_status`. When a frame of the
  sequence does not render completely (a file inside is offline, a layer is still loading),
  the analysis ends with an error that names the frame number and nothing from it is saved,
  instead of analyzing a placeholder frame.
- Stabilization: a shot where the camera turns far, with strong smoothing and the "Stabilize
  only" framing, could fall back entirely to the source picture (the correction reached its
  limit on many frames, and the window calculation did not finish within its step limit). Now
  such a window gets the best path that fits within the limits, and the source is used only
  when there is none.
- Camera analysis: a frame pair where the picture does not move like a single rotation (the
  camera travels toward the scene) now gets its speed from points tracked through the
  neighboring pairs, when it has measured pairs on both sides, instead of a speed guessed from
  the neighbors. In our measurements, on a shot with a push-in the shake left after
  stabilization is 0.86 of the source shake (was 0.89), and at 90% smoothing 0.89 (was 0.95);
  on a fly-through shot with jerks there is no improvement (1.09 against 1.07). This does not
  cover most pairs without a measurement, because tracked points are missing in jerks. Saved
  analyses are made again on first use. The camera track for the agent marks such pairs with
  the `chained` flag, and `hve stab solve` shows what the solver did with a saved analysis.

## 0.19.39 (2026-11-16)

- Camera Lens Blur has natural edges. A blurred foreground blends softly into the background
  over the whole blur radius, the background behind it extends under its edge without a seam
  and keeps its own sharpness, a sharp object does not tint the blurred background, there is
  no hard line at a depth jump, and the frame borders do not smear. The inside of a near
  object is fully opaque, small bright points give an even bokeh, bright highlights do not
  drop off in a step, and changing the radius does not jump when it passes from one level to
  the next. The half-resolution preview looks like the export.
- Effect points on the Program monitor: when a point parameter is selected in Effect controls,
  the monitor shows the motion path of the point with its keyframes. You drag keyframes
  without moving the playhead, the crosshair adds a keyframe under the playhead, and the
  keyframe menu changes the interpolation, applies Easy Ease or deletes the keyframe. Shift
  locks the axis, arrows move by 1 px (by 10 with Shift), Esc during a drag restores the
  value, and keyframes outside the clip are visible and editable. It works for every point
  parameter, not only in Lens Blur, also in a detached monitor window.
- Effect controls shows time also before the start and after the end of the clip. Keyframes
  can be added there (always under the playhead, on a sequence frame), moved, pasted and
  jumped to (J and K), and the part of the lanes and graph outside the clip is clearly
  darker. The panel follows the playhead only near the clip (up to three clip lengths, at
  least 5 s on each side) or when you move it in the panel; a key inserted while the playhead
  is far away lands under it and widens the range of the panel. Playhead moves made in this
  panel do not switch the clip while "Selection Follows Playhead" is on. The agent sets keys
  outside the clip through `set_keyframe`, `set_param` with `at`, presets, plugin parameters
  and web layer parameters. In the `paste_effects` notes the `keys_dropped` field is now
  called `keys_outside`.
- Expressions hear the audio. `audioLevel()`, `audioPeak()`, `audioAmplitude()` and
  `audioBand()` read the RMS level in dBFS, the peak, the amplitude and the equalizer bands (by
  band name or a range in Hz) of clips, tracks, submixes and the master; `thisComp.track()`
  gives the fader, pan and sends, and `dbToLinear()` and `linearToDb()` convert values. The
  expression editor suggests these functions and has ready snippets. Level analysis is
  computed in the background and kept in the cache; the preview never waits for it, while
  export and agent tools wait for exact numbers.
- The expression pick whip (spiral) can be dropped on the fader, meter, pan and sends in the
  Audio mixer, on a keyframe or a value line on the timeline (with Alt as a plain number) and
  on the dB value in an audio track header. The meter gives the peak after the fader (with
  automation and mute, without pan, solo and strip effects), a keyframe gives the value of
  the parameter at the time of that key, and a tooltip at the pointer says what will be read.
  Effect parameters of a submix can now be linked.
- Expressions no longer block keyframes, as in After Effects. The stopwatch turns on
  keyframes even while an expression is running. A typed value (also `+10`, `*2`, `+10%`) and
  a drag change the value under the expression, and the tooltip of the field shows the result
  and the value under it. An expression reads its own parameter by any path as the value
  under itself, without a circular reference error. A whip dropped on its own parameter
  writes `value` (when the parameter already has another expression, in link mode it refuses
  with an explanation instead of deleting it). "Replace expression with keyframes" is now in
  the menu of the parameter name. The agent tools `set_keyframe` and `set_param` return both
  values.
- VST3 and CLAP plugin windows hear what is playing: input meters, analyzers and gain
  reduction move during playback, also on track buses and with a side-chain key, and fall
  back after you stop. Edits made in a CLAP plugin window are no longer lost after the first
  change.
- The VST catalog shows plugin screenshots again instead of red triangles; a missing or
  damaged image is an empty frame with the hint "Image unavailable".
- Picture and sound stay in sync through the whole session. The player took the audio output
  latency from the driver on the fly, and that figure could grow over time (on headphones 595
  ms after three hours), so the picture drifted from the sound. HVE now measures the latency
  once, when the stream starts, and the playback clock does not step back after gaps in the
  audio. `debug_audio` reports `depth_ms` and `anchor_ms`, and `underruns` counts only audio
  dropouts during playback. Test scenarios no longer open the sound card and write their log
  to their own folder.
- New effect Chromatic aberration (Stylize): colored fringes like in a real lens, growing
  toward the frame edges, or a constant shift in a chosen direction. The Spectral style gives
  smooth color transitions, RGB split gives a glitch look. Amount, center (draggable on the
  Program monitor), falloff, angle and red / blue balance have keyframes and expressions.
  Four presets: Subtle lens fringe, Vintage lens, Wide-angle corners, RGB glitch split.

## 0.19.38 (2026-11-16)

- Expression controls have names and groups: you rename a control in place (double-click its
  name, F2 after clicking it, or Rename in its menu) and gather controls into named groups
  with Move to group. A group in Effect controls is a collapsible header with the number of
  controls and a + button that adds a control straight into it; a double-click renames the
  group, and its menu moves it, ungroups it or deletes it together with its controls. The
  control settings window has a Group field. Expressions read controls as before, the group
  only organizes the panel. The agent sees and sets the group through `list_controls` and
  `set_control` (`group`), and `set_control` returns the final place of the control (`index`,
  `group`).
- Renaming an expression control (in place, in the settings window or by the agent) rewrites,
  in the same change, the expressions that read it by the old name (`ctrl("Old")`,
  `effect("controls")("Old")` and similar, also from other clips and on mixer buses), and
  says how many there were; one Ctrl+Z undoes the name together with the expressions.
  References by id and controls of the same name in other effects stay unchanged. Sequence
  variables, clip group curves and the color of a solid are rewritten too, a new name does not
  take references away from another control, changing the type of a control without a name
  counts as a rename, and a web layer with audio no longer blocks a rename. What cannot be
  kept is reported in a message.
- The expression pick whip (spiral) can do more. When you write an expression, the whip in
  the editor header inserts a reference at the cursor: a complete, valid expression applies at
  once, an unfinished one stays to be completed, and Esc returns to the text from before the
  edit. Held near the top or bottom edge of a list, it scrolls the list. Variables are targets
  (`vars.name`) and sources (a variable with an expression has its own whip). Held over a clip
  on the timeline, it shows that clip in Effect controls, so a parameter can follow another
  clip. It works between panels and detached windows; held over a tab hidden behind another
  one (also in the list in the tab bar), it brings that tab to the front, and the rows of the
  Color and Grading panels are targets too. Held over the strip effects in the Audio mixer, it
  shows the stack of that bus in Effect controls, so a parameter can follow a track or master
  effect (submix parameters are not allowed for now, because expressions do not read them
  yet). Dropped on a freshly added expression that still holds only `value` (for example a
  variable after "Add an expression"), it replaces it with the reference and applies it at
  once.

## 0.19.37 (2026-11-15)

- Agent (API fixes after the first editing pass of an episode): `edit` with `result:
  "compact"` returns change counters and a map of item name to id that is never truncated (133
  commands fit in 9 KB); the full result is unchanged. A later command of a batch can point to
  an item placed earlier in the same batch (`"#0"` is the command index, `"#title"` is a
  `place` with `"key": "title"`), parameter commands take `"effect": "hve.motion"` instead of
  `target`, and `set_param` and `set_keyframe` on an effect accept a plain value, so a clip can
  be placed and scaled in one batch. The new `read_docs` reads the agent guides in parts (a
  table of headings, a section, further chunks). `write_component` changes an existing
  component without sending the whole of it: only the named files, a text replacement in a file
  (`edits`), a change of manifest fields (`manifest_patch`). `import_media` has a concise
  result, and media with the same name are told apart by the file name with its extension. The
  `HK` kit for web components gained `HK.rng`, `HK.textWidth` and `HK.fitText`; the web guide
  describes the page size, the `info` fields and CSS variables.
- Agent (after the second pass): every agent change, `export` and `normalize_audio` warn when
  items lie on a track that cannot be heard (a muted track, a muted VCA, a muted submix on the
  way to the master, the solo of another track). The new `measure_audio` measures the mix of a
  range the way the export will do it: loudness in LUFS, range, true peak, RMS over time and
  stretches of silence, for the program or for each track separately. `delete_items` takes
  tracks or `all: true` with an optional time range instead of a list of ids, so one batch
  clears the timeline and lays it out again as one revision. `place` accepts `fade_in` and
  `fade_out`. Expressions have `fadeDb` and `fadeGain` (constant-power fades). A track or
  sequence added earlier in a batch is found by its name.
- Agent (after exporting a whole episode): `validate_component` and `render_frame` point out
  the elements of a web layer that stick out of the frame (which element, by how many pixels,
  past which edge). `export_status` shows where the frame time goes (decoding, web layers,
  compositing, encoder) in total, recently and in time windows, so you can see when and why an
  export slows down. `publish` checks that the YouTube account is ready before it asks the user
  for consent, and says plainly what is missing; `server_status` shows this state.

## 0.19.36 (2026-11-15)

- Stabilization and camera analysis: a file kept in the project folder (for example in
  `exports` or `media`) or in the library could not be analyzed. The effect showed "The
  analysis failed", and the reason was "file not found": the analysis opened the path stored
  relative to the project as it stands, that is relative to the directory the program was
  started from. Only files outside the project folder worked. The bug had been in the
  stabilizer since its first version.

## 0.19.35 (2026-11-15)

- Camera: camera motion analysis is a product of its own, and the stabilizer is its first
  consumer. The agent can ask for the camera analysis of any clip or video file without adding
  stabilization (`analyze_camera`), check its state (`camera_status`) and read the camera track
  frame by frame (`get_camera`): pan, tilt and roll, focal length, confidence and measurement
  noise, shots, ranges that could not be measured, and the lens. One analysis per file and
  settings (method) serves everyone, nobody repeats it. For now the track contains the camera
  rotation only, without position and scene points (those will come with the 6DOF analysis), so
  it is not yet enough for anchoring elements in space. The stabilized picture does not
  change, and saved analyses stay.
- Preferences, Cache: the camera analyses of the project have a size, a limit and the "Remove
  unused analyses" button. Analyses that the project does not use right now (also those of a
  switched-off stabilizer) disappear on their own after 7 days or when they exceed 2 GB (the
  least recently used first); until now every "Analyze" and every change of settings left a
  folder forever.

## 0.19.34 (2026-11-15)

- Stabilization: camera motion analysis separates shake from parallax better. On handheld and
  drone shots, where objects are at different distances, the measurement of each frame pair
  was off in a slightly different way, and the stabilizer took those differences for shake.
  Now the velocities of consecutive pairs are combined with the acceleration of points tracked
  across three frames, in which parallax cancels out. In our measurements, the shake above
  about 1 Hz that remains after stabilization at 90% smoothing is: a handheld walking shot
  0.42 of the source (was 0.71), a drone 0.47 (was 0.51) and 0.78 (was 1.25), a known shake
  added to a steady shot 0.26 px out of 12.8 px (was 0.30 px). Shots with jerks and
  fly-throughs, where some frame pairs have no measurement, do not improve, and one of them at
  90% comes out worse than before the change and worse than the source (the whole common
  shake 1.02 of the source, was 0.97). Saved stabilization analyses are computed again.

## 0.19.33 (2026-11-14)

- Stabilization: the stabilizer no longer makes the picture worse. Up to 0.19.32, on handheld
  and drone shots the shake after stabilization grew (in our measurements from 1.2 to 5.9
  times). The solver is written from scratch: the correction is built only from what the
  analysis measured. Where a frame pair has no measurement (blur, a jerk), the picture follows
  the camera there instead of a guessed value, and motion that the analysis cannot tell from
  its own noise does not enter the correction. Shake added to a calm shot disappears almost
  completely (3 to 10% of it remains). Difficult moving shots, where the analysis loses some
  of the frames, come out close to the source for now (0.9 to 1.03 of its shake): stronger
  stabilization of such shots needs a new camera analysis and is the next stage. Analyses
  computed earlier are computed again.
- Stabilization: Smoothness accepts keyframes, and the new Strength parameter (0 to 100%,
  also with keyframes) says how much of the correction reaches the picture: 100% is all of
  it, 0 is the source. The picture does not jump at a key, also with a hold-type key: the
  solver spreads the change over time itself (the smoothing window changes by at most one
  second per second). Projects without such keys render as in the item above, and agents set
  keys through `set_keyframe`.

## 0.19.32 (2026-11-13)

- Fix: audio clips no longer lose their starts during playback. The mixer played silence until
  the file was decoded, and it asked for decoding only when the playhead reached the clip, so
  the first frames of sound were lost (a short voice-over or effect lost a few frames, a long
  file more). This happened with every file the program had not decoded earlier: after
  switching the sequence, after placing a new clip on the timeline, in a nested sequence and
  for the first moments after opening a large project. Now the files of the active sequence
  are decoded ahead as soon as their set changes, and the files from the nearest 3 seconds
  before the playhead go before the rest, also when playback is stopped. One of the three
  decoder threads is always free for the file the mixer is waiting for.
- Fix: a Pixel Motion frame is no longer darker than a regular frame of the same clip. With
  slow motion and frame rate changes the picture flickered where frames computed by the engine
  (optical flow or RIFE) alternated with source frames: the decoder gave the engine a picture
  darker by half to one code value (8 bits), and with saturated colors by up to two. Now both
  frames have the same levels up to rounding, in the preview and in the export. This applies to
  8-bit Y'CbCr sources (H.264, HEVC, most cameras, phones and generators). The same fix aligns
  the export of such a clip scaled with the 1:1 export, and JPEG images. Pixel Motion frames
  and frames of In to Out renders computed earlier are computed again (the old files are
  removed by the cache limit).

## 0.19.31 (2026-11-13)

- Effect controls: the "Go to clip" button in the clip header moves the playhead to the start
  of the clip when it is outside the clip. The playhead line runs through the whole height of
  the panel, also over empty space and collapsed groups.
- Effect controls: under Motion Scale you can see that the picture of the clip is fitted to the
  frame (for example 50% for a 4K clip in an HD sequence), with a "Fit to frame" switch. The
  Position of such a clip says so in a message (it can be turned off in the menu of that
  line). Agents see the same in `get_timeline` and in the edit result (`fit`). Existing
  projects render unchanged.
- Effect controls: the stopwatch tells the truth. It is gold only with keyframes, and the
  state of an expression has its own mark (dot: running, ring: off). A parameter with an
  expression turned off accepts keyframes, and a click with a running expression asks and can
  replace it with keyframes without a jump in the picture (one undo step).
- Effect controls: parameter groups of web components and effects have a header with a name,
  an indent and a line along the rows of the group.
- Effect palette: a shortcut (Ctrl+Shift+P in the Premier layout, Ctrl+Space or
  Ctrl+Shift+Space in the others, changeable in the shortcut editor) opens a small search
  window for effects, presets and transitions. It searches Polish and English names, also
  typed without Polish letters. Favorites (star) are at the top, then recently used. Arrows and
  Enter add the effect to the selected clips, a transition goes on the cut like Ctrl+D.
  Favorites (effects, presets and transitions) are in the shortcut editor and can get their own
  shortcut; when you remove the star, that shortcut disappears. The palette opens in the window
  where the shortcut was pressed, also a detached one, and while it is open, keys do not run
  shortcuts.
- A new project without decisions made for you: the empty sequence of a new project has the
  format "from the first clip" (visible in the tab, in Info and in the sequence settings), and
  the first video clip sets its size, frame rate and sound without asking, in the same revision
  (a still image, audio alone or a format card do not set it). The names the editor gives by
  itself (sequence, new project) are in the interface language, and the language choice at the
  first start renames the untouched names of the empty project. The Edit menu has the "Undo
  moves the playhead to the change" switch (off by default); when it is off, undoing a change
  outside the timeline view says so in a message with a "Show" button. Agents see `format_unset`
  in `project_info` and `get_timeline`.
- The clip mismatch window after tester feedback: "Change sequence settings" no longer zooms
  the timeline out to the whole sequence, so clips dropped while zoomed in stay where you see
  them before the question, with the same zoom and playhead. One Ctrl+Z takes back the clips
  and the new settings, and the next drop onto an empty sequence asks again. The question about
  settings is no longer lost when another window is open at the drop or a clip is not yet
  probed: it appears as soon as it can. A drop moves the frame to the timeline, so Delete
  removes the dropped clips, not files from the project.
- The panel that has the keyboard has a gold frame, and only it takes the keys. A click or a
  drop (also of files from Explorer) moves the frame, and so do the panel switching shortcuts
  and the Window menu. Delete, Ctrl+A and Ctrl+C/X/V over the timeline no longer remove
  anything from the Project panel when the frame is on the timeline, and do not edit the
  timeline when the frame is on another panel; other shortcuts on those keys (undo in Las
  Vegas, step in Mozart, clearing the in and out points) keep working. The gold line at the top
  of the monitors is now the same frame; tab groups without the frame have a gray bar.
- The opacity and volume lines on clips are hidden by default and are not grabbed by accident.
  They are shown by the "Clip keyframe lines" switch in the new "Timeline display settings"
  menu in the timeline bar (Ctrl+Alt+Shift+K, remembered), and for a moment it is enough to
  hold Ctrl+Alt over the tracks (Ctrl+Alt gestures on clips work as always). A parameter chosen
  in the track header and the Pen tool show the lines as before, and so do the VEGAS
  envelopes.
- Link is not a group. "Link" joins one picture with its sound (from the same file or from a
  separate recorder) and never one clip with itself; linked parts have a chain mark. Two
  pictures, titles and other clips are joined by the new "Group" (Ctrl+G, "Ungroup"
  Ctrl+Shift+G): a group has its own mark and a dashed top edge, a click selects the whole
  group, Alt+click one clip. Projects in which different clips were linked open with those
  clips in a group (a message appears once), nothing is lost; sound from a recorder stays
  linked with the picture.
- Alt+click selects one part of a linked clip, and dragging it moves only that part, without
  unlinking. Parts that have drifted apart show a red badge with the offset in frames, and the
  clip menu has "Move into sync" and "Slip into sync".
- Models you already have: Whisper and RIFE can use a file from another program or from an
  earlier download ("Use an existing file…", "Look in the usual places"), without copying,
  after checking the format, size and checksum. A missing file is described plainly.
- Model downloads: the Whisper button gives the size of the model and of the runtime
  separately, progress shows speed and time left in Preferences and in the task bar, and an
  interrupted download can be resumed.
- Updates your way: in Preferences choose Automatic (as before), Ask (the program says that a
  new version exists and downloads it only after a click; it installs a ready one after
  "Restart now" or, if you choose Later, at the next start) or Manual (it checks nothing by
  itself). You can see the installed version, when the program last checked and what it found.
  The first start after an update says "Updated to X (was Y)" and shows what is new. The
  program never restarts by itself and never interrupts an export, a render, a recording, a
  generation, a transcription, an upload or an online session.

## 0.19.30 (2026-11-13)

- Dragging numbers (tester feedback): every number in the app (Effect controls, mixer, export,
  color, DAW, masks, audio effect knobs) changes by one unit per point of movement, by ten with
  Shift, by a tenth with Ctrl. Note: Shift now speeds up and no longer slows down as before in
  number fields, audio effect knobs and the Color master bar. The unit depends on the range: 1
  for Position, Scale, degrees, percents, frames and pixels, finer for narrow ranges (0.01 for
  opacity 0..1, 0.1 for reverb decay), a round larger number for very wide ones (20 Hz for the
  equalizer frequency 100..8000 Hz). With Ctrl the field shows decimal places. The cursor is
  hidden during the drag and stays in place, so a drag does not end at the screen edge; after
  you release, the cursor comes back. Over remote desktop, with a pen and with touch the cursor
  stays visible and wraps at the window edge. Alt+Tab or a pop-up window ends the drag. Esc
  during a drag restores the value from before and writes nothing to the history (also on a
  parameter with keys and with several clips), and the dialog, filter, key selection and note
  selection in MIDI stay. The width and height of an export and of a sequence go in steps of 2
  pixels and are always even.
- Fix: an expression typed in a number field (`*2`, `+10%`) is computed once, from the value
  before the edit. Before, some fields applied it twice (Scale 100 after `*2` gave 400).
- Enter in text fields (tester feedback): in multi-line fields (expressions, text, marker
  notes, the code and JSON editor, prompts) Return adds a line, and Ctrl+Return and Enter on
  the numeric keypad confirm (Ctrl+Return also in detached windows). In single-line fields
  both Enter keys confirm.
- Ready expressions (tester feedback): the list under the plus says what replaces the whole
  expression (or the selection) and what is inserted at the cursor. One Ctrl+Z restores the
  previous expression.
- Fix (tester feedback): the plus in the expression editor with selected text no longer
  confirms an unfinished expression, does not shift the panel and does not close the editor.
- Preferences in sections (tester feedback): a list of sections on the side (General, Language
  and look, Timeline, Playback and cache, Media, Transcription, AI and models, Agent,
  Documents, Updates, Keyboard shortcuts) instead of one long page. The search field finds a
  setting in Polish and in English, also typed without Polish letters, and scrolls to it. The
  window returns to the last section, fits in 1280x720, and the search, the list and Close are
  always visible. General shows the settings folder with an Open button.
- Keyboard shortcuts at hand: Edit > Keyboard shortcuts… and Ctrl+Alt+K (Premier, Cupertino,
  Leonardo, Las Vegas, Mozart, Studio) open the shortcut editor as a section of Preferences.
  The editor searches by command name in every language and by key, typed or pressed ("Find by
  key"), and a chord taken by another command is red on both, with a hint which one; "Only
  conflicts" shows only such rows.
- First run without guessing (tester feedback). The installer asks where to install (Enter
  keeps the default folder, `-InstallDir` and `-Yes` skip the question) and updates an existing
  installation where it is. A folder with other files, or a whole drive, gets a subfolder
  "HEXART Video Edit". Uninstalling removes the program files by name, and in a folder that a
  previous installer accepted despite other files it also leaves the program's subfolders and
  says which. Installations older than the `.hve-install` marker (v0.14.0 to v0.18.1) are
  recognized and get the marker. The program is listed in Settings, Apps: a right click on it
  in the Start menu gives "Uninstall", and in its Start menu folder there is a shortcut
  "Uninstall HEXART Video Edit". Uninstalling asks whether to keep the settings and the list of
  recent projects, and never touches projects. The version in the entry follows self-updates. A
  junction in the program and data folders (for example models moved to another drive)
  disappears as a link, and what it points to stays. `-Purge` from a data folder outside the
  default place removes only what the program writes.
- The Projects window without "Cancel": "New project", "Open project…" and "Open"; the first
  run goes straight to an empty project, without a list to choose from.
- It is clear where the settings are: Help, "Open settings folder", and the path in "About". A
  `portable.txt` file next to the program turns the copy into a portable one, with settings,
  first-run steps and cache in a `data` folder next to it and with its own agent port. A copy
  from another folder asks once whether to use the shared settings or stay separate.
- Project panel: the hover preview can be turned off (Filter menu, Shift+H in the panel); then
  hovering decodes nothing. Selected clips dropped on the "New bin" button go into a new bin in
  one step; the clip menu has "Move to new bin" and "Move to bin" with a list of bins.
- The text editing panel shows the transcript of the clip clicked in the Project panel or on
  the timeline, without opening the Source monitor; the pin keeps the current clip.
- The six-dot panel handles no longer show through modal windows.
- "Change with agent" no longer says "no microphone" when the microphone works: gaps reported
  by the driver do not end the recording, and the message gives the real cause (no device, no
  Windows permission, unplugged, did not open, only silence).
- Effect controls (tester feedback): Delete or Backspace with a mask selected removes the
  mask, not the whole clip. A panel that has the focus no longer hands Delete to the timeline:
  it acts on keys, effects and values or on the mask, and with no selection does nothing. A
  mask row has a context menu (Rename, Invert, Lock, Delete mask), also from the mask name.
  With the focus in the panel, Shift+Delete, Alt+Backspace and other layout shortcuts that
  delete clips do nothing, a held Delete removes once, and a click on a mask and on an effect
  gives one selection at a time.
- Timeline after tester feedback: clips dropped farther along an empty sequence stay in place
  after "Change sequence settings", and a drop with new settings is undone with one Ctrl+Z.
  Dragging a clip over track headers no longer loses it: releasing over a header puts the clip
  at the start of that track (just passing over the headers on the way from the Project panel
  moves nothing), and over the ruler the preview stands still; a drag ends outside the
  timeline panel or with Esc. A right click on an empty place of a track puts the playhead
  there and stops playback, like a click on the ruler, dragging with the right button scrubs as
  on the ruler (with Ctrl with sound), and a further click opens the place menu. The backslash
  (`\`) shows the whole sequence, and a second press returns to the previous zoom and scroll,
  separately in each timeline panel.
- Scrubbing in the Program and Source monitors: when you stop the mouse with the button held,
  the monitor no longer pretends that a stand-in picture from another moment is the frame of
  the playhead. Until the playhead frame is ready, the picture is dimmed with the label
  "Waiting for the playhead frame", and then it shows exactly the time of the playhead; when the
  frame cannot be decoded, the label says so. While moving, and when editing under a standing
  playhead, the stand-in picture stays as it was, with a small stroke in the corner.
- The bars above the Program picture and the diagonal stroke in the corner have a legend in
  the tooltip (focus frame, preview cache colors, playhead); a description is in the README.
- A double click in the Program picture selects the topmost clip under the pointer and turns on
  transform, as in Premiere (without locked tracks, adjustment layers and clips with opacity
  0; a full-frame title does not cover the clip under it); full screen has its own button in
  the monitor bar and still Ctrl+`.
- Sequence menu: "Select Clip at Playhead" (D in the Premier layout, on the targeted tracks)
  and the "Selection Follows Playhead" switch (off by default, remembered).
- Masks and other overlays of the Program monitor do not go outside the picture area: they do
  not cover the transport, the bars or other panels. After you zoom the view out, mask points
  can be placed and dragged outside the frame.
- A triple click on a mask path selects all its points: the box moves, scales and rotates the
  whole mask in one undo step.

## 0.19.29 (2026-11-11)

- Documents through conversion (part three): HTML, office files (DOC, DOCX, ODT, RTF, PPT,
  PPTX, ODP, XLS) and EPS come into the project as a picture with pages, like a PDF. HTML is
  printed by Chrome or Edge on a 16:9 page: the page gets the files from its own folder,
  without the network and without any other files of the computer, and a change of a file next
  to it (a style sheet, an image) gives a new picture. Office files are converted by
  LibreOffice: yours, or one installed with a single button in Preferences, the Documents
  section (373 MB, into the tools folder of the editor, without a system-wide installation).
  EPS is converted by Ghostscript, if you have version 10.03.1 or newer (an older one has known
  vulnerabilities and is not run, and neither is a program that does not report its version).
  Each of them runs as a separate program, and the result lies in the cache and counts toward
  its limit. The conversion is stopped by Cancel of the import, the export or another
  background task (a preview render, saving a frame) and by closing the editor, and the program
  ends together with everything it started. When the program is missing or the conversion
  fails, the import says what happened; an export with such a document stops with the same
  message.

## 0.19.28 (2026-11-11)

- Match Color: a new effect matches the color of a whole clip to chosen reference frames (a clip
  on the timeline and a frame in it, up to 16). In Effect controls there is a list of references
  with a thumbnail and timecode, "Add reference" by clicking a clip on the timeline, "Clip under
  playhead", and the "Reference" parameter has keyframes (linear ones blend the references, Hold
  switches between them). Strength, Luminance and Color are separate, plus Protect neutrals. The
  analysis runs in the background with progress and a cache on disk, and
  it is the same in preview and export. Agent: `match_color` with `mode: effect` and
  `match_color_status`. A clip with stabilization is measured after its analysis, a second Match
  Color on a clip after the first, removing a reference renumbers the keys, and a nested
  reference clip still works. A copied sequence, "Make unique", paste and an Alt copy together
  with the reference clip match to the copies of the clips, and an adjustment layer cannot be a
  reference. A reference on a nested sequence item with changed speed or reversed points to the
  same frame.
- Documents as pages (part two): text files (TXT, LOG, INI, TOML, YAML), Markdown, JSON, XML, CSV
  and TSV, and spreadsheets (XLSX, XLSM, XLSB, ODS) come into the project as a picture with
  pages, like a PDF. The editor lays out a 16:9 page (1920 x 1080) in the app's fonts: light text
  on transparency, dark text once you set a light background in Interpret Footage. JSON and XML
  are colored, Markdown has headings, lists, quotes, code and tables, a table repeats its header
  on every page, and a spreadsheet is its sheets one after another. The pages are vector, so
  they are sharp at any scale. A document comes in when you pick it by name; a folder import,
  and a selection together with video, audio or a folder, skips it and counts it in the summary.
  SRT and VTT files stay captions. A JSON or XML file named like a photo from the same selection
  (`IMG_1.jpg.json`, also `IMG_1.jpg.supplemental-metadata.json` from Google Takeout) is the data
  of that photo and is skipped too. The file is streamed into pages as it is read, up to 2000
  pages, so even a very large or malformed file takes only as much memory as its pages show.
  Markdown above 2 MB is shown as plain text.
  MCP: `import_media` takes these files by path under the same rules, `media_info` reports
  `document.pages`.
- Interpret Footage: a right click on one or more items in the Project panel opens a window with
  settings by kind of media. Video: frame rate from the file or a chosen one (every frame of the
  file plays, the length and the sound follow), pixel aspect ratio, field order, alpha (straight,
  ignored, premultiplied over a color), color interpretation and range, rotation, start
  timecode. Image sequence: frame rate, first frame, gaps hold the previous frame or are empty.
  Still image: its own length for new clips. Sound: mono, stereo, one channel, a channel map
  (dual mono), another sample rate. With several items, only what you touch changes. Clips that
  are already on the timelines keep their place, length and source times, and the window says how
  many of them now show other frames and how many run past the end of the source. One revision,
  with undo.
- More file types: all images that the bundled FFmpeg decodes (among others JPEG XL, AVIF, HDR,
  DDS, PSD, ICO, QOI, JPEG 2000, PCX, SGI, PNM), SVG, PDF and AI files compatible with PDF.
  Vector sources stay sharp at any scale (vector drawing) or are drawn once at a chosen DPI, with
  a transparent background or a color. PDF, AI and multi-page TIFF have pages: the number of
  pages is checked on import, Interpret Footage sets the default page, and a single clip has its
  own page in Effect controls (Source, Page; keys hold the value, so one PDF can turn pages over
  time).
- MCP: `update_media` sets the interpretation with the same words as the window (`rate`,
  `pixel_aspect`, `fields`, `alpha`, `rotation`, `range`, `start_timecode`, `start_frame`,
  `missing_frames`, `still_duration`, `rendering`, `dpi`, `page`, `page_box`, `background`,
  `audio_channels`, `sample_rate`; `file` goes back to the file) and returns `items_retimed` and
  `items_past_end`. `media_info` shows `interpretable`, `interpretation`, `file_probe` and
  `document`. The page of a clip: `set_param` and `set_keyframe` with the `page` parameter.
- Media read at a different frame rate or sample rate: transcript words, beats, silence, search
  hits and the stabilizer go along with picture and sound (the analysis keeps the file's time,
  and the reader converts it to the media's time). Rotoscope, depth and stem separation on such
  media say that you must first go back to the values from the file. A TIFF page and a document
  page have a size limit instead of unbounded allocation; the preview inside a TIFF file is no
  longer counted as a page, and black-and-white pages are read.
- Scopes on the GPU from every frame: the full output frame is measured in float precision
  instead of a 1920 px, 8-bit sample, the picture is in screen pixels (also on HiDPI), and it
  refreshes with every frame shown instead of about 8 times a second. Eight modes (luma and RGB
  waveform, RGB and YCbCr parade, vectorscope with 75 and 100% targets, skin line and zoom,
  histogram of RGB, channels and luma from 256 to 4096 bins, linear and log, CIE 1931 xy with
  Rec.709, P3 and Rec.2020 gamuts, false color), up to four scopes at once in five layouts,
  scales in percent, nits (PQ), HLG and 8 and 10-bit code values, indicators of clipping and
  out-of-gamut values, a measurement region picked on the Program monitor, persistence and trace
  brightness. A paused frame is measured at the sequence resolution. PQ and HLG scales also show
  what goes beyond the gamut and above the range (a PQ sequence limited to its peak counts
  clipping at the peak), a flat picture does not slow the measuring down, and a graphics card
  without compute shaders gets a message instead of an empty panel.
- Speed on sequences: a sequence placed on the timeline (a nest) takes what a clip takes: speed
  in percent, reverse, fit to duration, the Rate Stretch tool, slip and Time Remap. Picture,
  sound, transcript words and the associated playheads follow the speed; the pitch of the sound
  changes with it. A nest with another speed, reversed or with Time Remap cannot be flattened
  until it is back at 100% forward. The Speed and duration window opens with the item's reverse
  state.
- A sequence as a nest or as a native clip: a new "Sequence interpretation" switch in the item
  menu and in Effect controls. A nest works as before (exact time inside, no source end). A
  native clip treats the sequence like a file: its own frames at the sequence frame rate, Frame
  Blending (Frame Mix; Pixel Motion shows Frame Mix for now), trim and slip within the length of
  the sequence, and a held first and last frame beyond it. Switching back and forth loses
  nothing. Agent: `set_speed`, `slip` and `set_frame_blend` on sequence items, the new
  `set_nest_mode` and a fuller `nest_info`.
- Fix: a reversed clip (also in a reversed sequence) showed every frame one too late, and the
  first frame fell just outside the range. A freeze frame in the Cupertino layout starts on the
  frame that is visible at every speed and direction.
- Timeline: dragging a clip with Alt leaves a copy where you drop it, and the original stays.
  The whole selection is copied, picture together with sound, also to another track, with
  snapping and with insert (Ctrl) or overwrite as when moving; one revision and one undo. You
  can press and release Alt during the drag, the preview shows at once whether it is a copy or a
  move, and the cursor says which mode it is. In the LasVegas layout Ctrl copies. A single clip
  without its partner is now moved with Alt+click and a plain drag; S turns snapping off during
  the drag. A copy, also one pasted with Ctrl+V, has its own identifiers of effects, masks,
  markers and takes.
- Left and right Alt work the same in mouse gestures: curves on clip keyframes and in Effect
  Controls, copying a clip, trimming one side. On a Polish keyboard the right Alt (AltGr) did
  not reach gestures until now; typing Polish characters and shortcuts stay unchanged.
- Tempo as keyframes: the header of the tempo lane in bars mode has buttons for the previous
  point, a point at the playhead (add or remove) and the next point, a BPM field to drag and to
  type in, and a switch between step and ramp. In bars mode, keyframes on a clip line land on
  the bar grid. The agent reads the tempo map in `get_timeline` (`tempo_map`).
- Two timelines side by side: the timeline that is not being edited draws the whole interface
  (the bar, headers with switches, scroll bars, the tempo lane). Its track switches and its view
  act on its own sequence without switching the editing, and a click on a clip or the ruler
  edits in that timeline at once.
- Project panel: after an import the panel opens the bin the files went to, selects them and
  scrolls to the first one, in the list and in the grid; it waits until you release the mouse
  and does not take the keyboard from the timeline. The list has column headers: a click sorts
  (a second click reverses), the header menu shows and hides metadata (type, duration, frame
  rate, resolution, codec, pixel format, color, audio, size, modified date, path, uses, rating,
  tags, reel, status), a header can be dragged to another place, an edge changes the width, and a
  double click fits it. The layout and sorting are saved in the program's preferences. Folder
  import (File > Import folder, the panel menu, drop) recreates the structure as bins in one
  revision, skips hidden files and system junk, and after the import says how many files it
  skipped, with a list. Agent: `import_media` with `recursive: true` imports a folder with its
  structure and returns the bins and the skipped files.
- Dropdown lists and menus no longer widen by themselves: the list of export presets with a
  saved preset grew by 4 points in every frame (the row with the rename and delete buttons asked
  for 4 points more than the list had, and the interface toolkit gives a list the width from the previous frame),
  and the scroll bar of a long list (effects and plugins in the mixer) slid in over the first
  frames and widened the list by its own width. Every list and menu now has a fixed width from
  the first frame and widens only for a longer name that has arrived in it, at most up to the
  screen; names longer than the screen end with an ellipsis (plugin names with the full name in
  a tooltip).
- Effect controls: the previous and next keyframe buttons, the diamond and reset show hover and
  press, have tooltips and grey out when there is nowhere to jump. A jump to a keyframe no longer
  stops in place at a key between frames of the sequence, and it skips keys outside the visible
  part of a trimmed clip; the buttons, J and K, and the Grading and Color panels count it the
  same way. In the Color panel the keyframe buttons work (they did nothing before), and the
  shortcut that adds a key no longer adds a second key on the same frame.
- "Reveal in Project" in the tab menu: a timeline tab reveals its sequence, the Source monitor
  and the text editor reveal their clip. The Project panel comes to the front, opens the folder
  of the item, selects it and scrolls to it, in the list and in the grid.

## 0.19.27 (2026-11-09)

- Sound of web components: a component with `audio` in `layer.json` computes its sound offline
  from the same time, parameters and keys as its picture (`hve.onAudio` block by block or
  `hve.renderAudio`). On the timeline it is a picture and sound pair linked like a clip with
  sound, the render runs in the background with a cache on disk and in memory, and export waits
  for it. Agent: `add_web_layer` places the pair, `preview_component_audio` saves a WAV with the
  level and envelope.

## 0.19.26 (2026-11-09)

- Image sequences: numbered PNG, EXR, DPX, TIFF, JPEG and WebP frames come in as one clip with a
  frame rate chosen in the import window (the active sequence's rate by default), also when
  dragged onto the timeline. The frame rate can be changed later in the clip menu (Interpret
  Footage), with a warning when clips would reach past the end of the sequence. A missing frame
  shows the frame from before the gap, never black, and the import window, the Info panel and
  MCP say how many frames are missing. The whole sequence is one decoder, also when the frames
  are numbered with steps of two. MCP: `import_media` with a pattern (`%04d`, `####`) or
  `sequence: true`, `media_info` with numbers and gaps, `update_media` with `rate`.

- Media offline: a clip whose file is missing shows a "Media offline" card with the file name in
  the Program and Source monitors instead of black. Export lists the missing files before it
  starts and begins only after you agree to those files (then with the card; a file that
  disappears later still stops it). The agent gets the list in `render_frame` and `export`, and
  the user agrees in the editor window.

## 0.19.25 (2026-11-09)

- Final Cut Pro import: `.fcpxml` files and `.fcpxmld` bundles, also from a ZIP made on a Mac
  (NFD names). The primary storyline, connected clips, a 24p conform into a 50p project
  (25 fps), retimes with a speed curve as Time Remap, dissolves, opacity, transform, volume and
  markers. Transitions and effects with no counterpart in HVE (Simple Camera Slide, mLut, Match
  Color, curves) get a marker for review and a line in the fidelity report. J and L cuts, muted
  camera sound in synchronized clips and disabled channels carry over as in FCP; a file on a
  network share is not touched without consent.
- The last source frame no longer disappears when the speed equals the source length divided by
  the clip length.
- MCP: `render_frame` saves a copy of the frame in the project (`out_path`) and skips chosen
  tracks (`exclude_tracks`); `match_color` compares frames at one sequence time (`at`); `trim`
  moves effect keys with the edge on request (`keys: "edge"`) and warns about keys outside the
  clip; `edit` keeps the active sequence on a rebuild and reports its change; the description of
  `edit` has a cheat sheet of field names; `get_timeline` shows a clip's Time Remap and computes
  its start and end in the source from it.
- The agent saves its suggestions and bug reports in a local file (`feedback_note`), and
  `feedback_send` opens them in the report window, privately to HEXART only; the user sends
  them.
- Editor actions from outside, for example from a Stream Deck: `hve action <id>`, HTTP
  `/admin/action`, the action list `hve action --list`; described in the Stream Deck guide. They
  work like a shortcut (not with an open dialog, menu or text field), the response says whether
  the action ran, and their changes have their own author in History. Undo, redo, microphone
  recording and replacing the open project never run from outside.
- The agent measures the color of shots with numbers (`color_stats`): luma, mean RGB, warmth and
  tint of the midtones, chroma and clipping of every shot, and the jumps between neighboring
  shots, without looking at an image of each. Frames come from inside the shot, outside
  transitions, rendered in memory, with a time limit.
- Effects from the first drop: NTSC from the list starts with a VHS look, and when Effect
  Controls is not on top, the message says where it is and opens it with a click. Letterbox has
  presets with cinema aspect ratios (2.39:1, 1.85:1, 2:1, 4:3, 1:1).
- Video transitions are in Effects right under the video effects, each with a description in
  the tooltip (zoom, push, slide and others).
- An audio track adds an effect or a VST plugin from its own menu, not only in the mixer.
- Recordings: a take from an accidental recording is removed in the Recording panel in one
  revision, and recordings the project no longer has are moved to the project's trash by a
  button next to the message or in the panel (checking at the moment of the click what the
  project uses), and the message afterwards has a Restore button.
- Program monitor: the center of a layer moves it (the anchor point with Alt), the handles of a
  small layer shrink, and a press moved by a hair changes nothing. Dragging a layer while
  editing is off hints where to turn it on.
- The Ctrl+D fade on a free edge of a clip fades evenly in brightness (also in old projects),
  and the gap between video and audio tracks is wider: a clip dragged down stays on V1.
- Image stabilizer, gyroscope from the file: the analysis reads the gyroscope and accelerometer
  data recorded by the camera (DJI, GoPro, Sony, Insta360, Blackmagic, RED, iPhone apps, Gyroflow
  `.gcsv` logs next to the file), matches the timing and orientation of the sensor to the
  picture by itself on three short stretches, and calculates the rest of the shot from the
  gyroscope without decoding frames. The horizon holds to gravity. Lens profiles: the one the
  camera wrote in the file or the Gyroflow database (public domain, downloaded on demand:
  `hve stab lens-db --download`), with the focal length and distortion from the profile instead
  of an estimate. `hve stab analyze` has `--source auto|optical|gyro`, `--gyro-offset-ms`,
  `--lens` and `--lens-profile`. A damaged camera file does not close the program (it is read in
  a separate process with a memory limit), a log that started on its own is found whole (also
  while walking), and a GoPro profile matches the lens mode from the file (Wide, Linear,
  SuperView), also when the database has several settings for that mode. A long read from a
  network drive lasts as long as it keeps going, and when it fails (also a locked file or a
  drive that disappeared), the reason is visible in the analysis result, and the following
  analyses try again, at most three times. The Stabilize effect in the editor now analyzes with
  the gyroscope when the file has it and it agrees with the picture, and with the focal length
  from a rectilinear lens profile (from the file or from the database installed with
  `hve stab lens-db --download`); a fisheye profile, leveling to gravity, distortion in the
  render, and choosing the source and the lens in the effect are not there yet. After the update
  every clip with the Stabilize effect is analyzed anew once (analysis engine version 2).
- One agent connection state: the Agent window, its bar and Preferences say the same, also when
  a client with an old key, or a client of another copy of the program, knocks on the port. Such
  a client gets a message on how to reconnect (a 401 response starts with "unauthorized: " and
  advice, and is not a bare "unauthorized"), the server counts rejected attempts with a key
  instead of writing each one to the log, and `hve mcp --connect` rereads the key after a change
  and keeps working.
- The Agent window starts with a short summary: one line per change or step of the agent,
  repeats counted; the connection, sessions, calls and messages are under "Details".
- What is turned off is not there: without the agent server, the "Change with agent" button and
  the list of guidelines for the agent disappear.
- Web layers with WebGL, also MapLibre GL and Mapbox GL maps: every frame shows the state set
  for its time (until now a map driven from `hve.onFrame` showed the camera from the previous
  frame, and a stopped playhead stayed on the view from before the move). The map waits for its
  style and tiles, so `hve.ready(map.once('load'))` no longer hangs for 15 s on a frame. Export
  renders the next frames of such layers on all browser threads at once. The browser picks the
  efficient graphics card, and when WebGL is drawn by the CPU (SwiftShader, WARP), the Program
  monitor shows a "WebGL without GPU" badge and `debug_web` reports it.
- Parameters of web components in Effect controls: the tooltip of a name says what the
  parameter does, its range and unit, and its default value; groups from the manifest are
  together under their name and can be collapsed with an arrow, and advanced settings are in a
  collapsed group at the end. Agents get the guide `hve://docs/web-components` and `advice`
  hints when a component is saved. Old manifests work unchanged.
  Layer values outside the manifest (set by an agent) now have their own controls in the "Not in
  the manifest" group, instead of being only in the project JSON.
- Memory bar in the Program monitor: a thin bar under the title shows which of the seconds
  around the playhead are ready to play at once (gold in memory, green rendered, blue loading,
  dark not loaded yet); the tooltip says how many seconds ahead of the playhead are ready.

## 0.19.24 (2026-11-08)

- Agent (API fixes from field reports): `clear_markers` without `kind` clears markers of all
  kinds in one revision, `place` of a web layer takes plain parameter values, `render_frame`
  takes `time` instead of `at`, the new tool `reset_web_params` restores the default values of a
  component's parameters, and `preview_component` composes up to 36 frames into one WebP contact
  sheet with the time and parameters of each frame.
- Fix: a web component that starts a Web Worker no longer hangs the editor's page server.
- Image stabilizer in the editor: the Stabilize effect in the Transform group. Once added to a
  video clip, it queues its own analysis (the clip under the playhead and whatever an export
  waits for go first; one analysis at a time, in the background, using part of the graphics
  card's power), and from the first analyzed fragments the monitor shows an already stabilized
  picture. Simple view: Result (Smooth, Cinematic, Tripod, Handheld, Rolling shutter only),
  Smoothness, Method, the "Crop and zoom" framing up to 115%, and an Analysis row with an
  Analyze button. Changing the speed, Time Remap or the trim of a clip needs no new analysis,
  and the path is recalculated in milliseconds. The picture is sampled once (Lanczos 3), and a
  frame that needs no correction passes to the file unchanged, bit for bit. Export waits for the
  analysis; the export window says how many clips are waiting for it.
- Image stabilizer, step two: camera motion analysis from real footage. Points tracked on the
  GPU, camera rotation from every pair of frames, self-calibration of the focal length (with a
  safeguard against drone and walking parallax), rolling shutter readout time, cuts, repeated
  frames and flat shots. The analysis runs in fragments in source time, is saved in the project
  folder and, after an interruption, resumes where it stopped. Measurement: `hve stab analyze`
  with the time of every stage and the result of every fragment.
- VST3 and CLAP plugins switch on with the first click: during playback a disabled plugin
  already has its instance loaded, so after you enable it the processed sound is heard at once.
- Licenses stay out of the way: license checking during work (a marker on the bar, questions at
  export, refusals for the agent) is off by default and turns on in Preferences > Licences. The
  report is always on demand (Help > Licences and components). The "Write licences" button saves
  in the project folder `licenses/` where each file comes from and under what license it is, and
  each item can be marked as allowed to be shown publicly (the list is in `public.txt`).
- The window takes over the background agent server more reliably: a busy server is asked again,
  the window does not open a second time a project that a background process holds, it tries
  again every 10 s, and the "AGENT: NOT CONNECTED" badge disappears by itself when the
  connection returns. `show_editor` from the background opens one window. "Change with agent"
  asks before turning on microphone and cursor recording.
- Bug reports are private by default: they go only to HEXART, without a public report on
  GitHub, with an option to attach the project without media (without folders, library names and
  the project name; "Show what will be sent" shows the exact text). A report that is too big
  loses the project first, then the screenshot, and the window says what was left out. A public
  report is a separate choice with consent. Privacy policy and terms of use in version 1.1.
- ElevenLabs voice-over defaults to the newest model, `eleven_v4_turbo`.
- Effect controls: copying effects and values also in the group view, "Paste with key times
  scaled" (keys fitted to the length of the target clip, like Paste Attributes in Premiere),
  Ctrl+V in the panel pastes the effects of a clip copied on the timeline, and the agent has the
  tools `copy_effects` and `paste_effects` (paste in one revision, the same clipboard as the
  panel).
- Timeline: Shift+click on a cut on another track adds an edit point (HVE and Premier), every
  point has its own mark, and Trim Backward and Forward move all of them at once in one
  revision.
- Drop assist everywhere: source edits in all layouts (Leonardo, Mozart, Cupertino, Edison,
  LasVegas) no longer overwrite the sound underneath, the sound goes to a free or a new track;
  the MCP tools `place_clip`, `insert_clip` and `overwrite_clip` have an `assist` option, and the
  result lists the tracks.
- Select forward and backward in every layout: Edit, Select clips forward and backward, on all
  tracks or on this track, from the playhead; in LasVegas "Select events to end", in Mozart
  Select Right and Select Left.
- A ripple blocked by music with a sync lock: the message says which track blocks it, and the
  button next to it closes the gap without that track in one revision.
- Window menu: Reset layout (panels from separate windows come back) and the most common panels
  at the top, with Effect controls, in every layout.
- Timeline tabs come back when the project is reopened, each once.
- Overwrite replaces a clip as a whole: a source edit or a drop with assist over a clip with
  picture and sound also removes its own sound in the overwritten range (a partial overlap cuts
  it at the edge), and the new sound lands in its place. Music, voice-over and effects
  underneath stay untouched.
- Plugin catalog: a plugin put in the user folders by another installer is shown as found,
  with no install; one found in another folder has an "Install a second copy" button with a
  warning.
- Fixes: VST3 plugins compile on Linux, and a randomly failing test of invitations in team
  work is fixed.
- Image stabilizer, step one: a new stabilization calculation module. It saves the camera
  motion analysis in the project folder (fragment files checked with a checksum, written with no
  risk of corruption), smooths the camera path in milliseconds (Smooth, Cinematic, Tripod,
  Handheld, horizon, framing with automatic zoom up to 115%) and calculates the warp grid with
  an error below 1/64 of a pixel. Measurement: `hve stab bench`. There is no effect in the
  editor yet.
- Studio: moves of the fader, pan and plugin knobs in automation write mode are heard at once,
  not only after stopping; plugin knobs from the plugin editor window are saved in the same
  pass. Comping a take range no longer cuts the clip: the clip stays whole and plays the
  segments of the chosen takes with a short crossfade, and the combined picture does not change.
  Take rating is a field of the take (old projects move it themselves on opening). The ADR and
  Foley loop returns to the pre-roll, so the beeps and the streamer are in every pass; the
  streamer can also be on the Source monitor. The ADR and Foley cue list can be saved to CSV and
  PDF (with Polish letters) and loaded from CSV (comma or semicolon, also the Polish Excel
  format, columns in Polish or English, no duplicates). New: Scrubber (F9, dragging across the
  tracks scrubs the sound), Consolidate (Alt+Shift+3, the clips in the range into one file) and
  Tab to Transient (Ctrl+Alt+T, Tab jumps across the hits in the sound).
- Faster 4K export: a 4K HEVC shot from a drone or a camera is decoded by two processes at once
  in export, and the picture planes arrive from the graphics card without conversion, so the
  source stage is shorter. The picture in the file is identical to before, bit for bit.
- Export on a full machine no longer switches the decoder to the CPU after 20 s when the
  graphics card decoder is slow, and still delivers frames: it keeps waiting for it (up to 5
  minutes over the limit). A hung decoder is replaced as before.
- FFmpeg processes (decoders, encoders, proxies) always end together with the editor or the
  `hve` command, also after a crash or a close from Task Manager. A script that read the output
  of `hve play` no longer waits for decoders that outlived the command.
- Masks with a long path (stars, shapes with thousands of points) render several times faster:
  on a 4K frame a star with a 2016-point path costs about 21 ms instead of 103 ms. The picture is
  identical to before, byte for byte.
- The Color panel no longer stops the editor on color matching: the reference frame and the
  matching frame decode in the background, and the button waits with a progress spinner.
- The hardware encoder test (NVENC, QSV, AMF) starts in the background a few seconds after the
  program starts, so the export window and the first export do not wait for it, also with a busy
  GPU.
- Render queue: a WhatsApp copy of HDR footage (PQ, HLG) has tone mapping to SDR and no longer
  looks pale; when sending to WhatsApp from the bar you can add a caption, visible in the
  consent window; agent exports that a background process ends after the window opens appear in
  the queue as bars with progress and an "In background" mark.
- Pixel Motion with RIFE: a half-precision (fp16) copy of the model is made on this computer
  when the model is installed or when fp16 is first turned on in Preferences. Up to Full HD it
  computes about three times faster than fp32, at 4K slower, so fp32 stays the default.
  Preferences warn when a frame whose longest side is 3840 px or more will lengthen a slow-motion
  export.
- Pixel Motion during playback by deadlines: in-between frames are computed in the order in
  which the monitor will show them, from the playhead, in the direction and at the speed of
  playback (also in an In to Out loop). A frame that the engine cannot finish in time drops out
  of the queue and Frame Mix plays in its place, so the engine does not waste time on late
  frames and makes the ones it can still make. The idle render of Pixel Motion goes from the
  playhead in the direction of the last playback.
- Background render when idle (Preferences > Preview render, off by default): when you do
  nothing for a moment, the editor renders the preview from In to Out on its own (without them,
  the stretch around the playhead), with a GPU limit in percent of the time. A key, a click,
  playback, an export or an edit stops it; progress and GPU use are shown in the background work
  list in the status bar.
- Render Source In to Out (Sequence menu, or Render In to Out next to the Source monitor in
  focus): the decoded frames of the clip between the markers go to the render memory and the
  Source monitor plays them from there (a "Rendered" badge), without a decoder.
- The Source monitor plays with frame prediction like Program: the frames of the nearest
  seconds are decoded by deadlines, also backward and in a loop between the markers.

## 0.19.23 (2026-11-07)

- New ASCII effect (Stylize): the picture drawn with characters of any font installed in the
  system, downloaded from Google Fonts or sitting in the project's `fonts` folder (best with a
  fixed width; a missing font is replaced by the built-in Hack with a warning). A font added to
  the `fonts` folder while you work appears by itself, and a font file picked from disk is
  copied to that folder, so the project also works on another computer. 60 parameters: size and
  aspect of the cells or the number of columns, spacing, glyph scale, rotation and offset of the
  grid, 15 character sets and a custom one, character choice by brightness, by edges and their
  direction, or by both, dithering, brightness, contrast and gamma before mapping, color: one,
  from the source, from a gradient, from a palette (ANSI, CGA, Game Boy, C64, PICO-8 and others)
  or quantized, background, the original under the characters, blend modes, thickness and
  outline of the characters, stability in time, and animations of rain and character mixing with
  grain. 34 ready presets, from green terminal and Matrix rain to newspaper, Game Boy and
  mosaic. It runs in real time on the GPU, the export is the same as the preview; the agent sees
  the effect and the presets through MCP.
- Settings windows of the built-in audio effects: every built-in audio effect opens in its own
  window, with the button in the effect header in Effect controls, with a double click on the
  slot in the mixer (track and master) or from the slot menu. The window has a live graph for
  its effect: the EQ curve on the spectrum before and after with draggable bands and band solo,
  the transfer curve of compressors, limiters and gates with gain reduction and its history,
  reverb decay, delay echoes, LFO, a noise profile with a "Capture profile" button, the
  distortion and saturation curve, loudness and true peak of mastering, a goniometer. Every
  value can be typed with a unit, Shift changes it precisely, a double click restores the
  default, and the whole gesture is undone with one Ctrl+Z. Also A/B, click-free bypass, input,
  mix and output, and monitoring of the side chain, the band and what the effect takes away.
- Audio effect presets: 499 factory presets (8 to 15 per effect) in the categories dialogue,
  voice-over, podcast, music, broadcast, Foley, ADR, cleanup, mastering and sound design, in a
  browser with search, categories and favorites. Own presets: save, rename, overwrite, delete,
  import and export; the agent has them through MCP too (`list_effect_presets`,
  `save_effect_preset`, `delete_effect_preset`, `user:<name>` in `apply_effect_preset`). A preset
  does not erase the captured noise profile of noise reduction, and "Save as" does not take it
  away. When the file of own presets cannot be read, HVE does not overwrite it and says that the
  save failed.
- New audio effects: expander, transient shaper, ducker, de-plosive, loudness leveler (target
  in LUFS), declipper, tremolo and auto-pan, pitch shifter, DC filter, utility (polarity, M/S,
  width, mono, pan), saturation and de-reverb.
- Audio effect fixes: no clicks when parameters change or are switched (filter slopes, band
  types, sections, bypass), a delay or reverb switched on again does not play old samples,
  surround reverb does not cut playback short and has correct channel maps, chorus, flanger and
  phaser sound in preview from the middle of a clip the same as in export, noise reduction
  remembers the captured profile after a seek, the declicker works the same at 44.1, 48 and
  96 kHz, channel loudness knows the quad, 5.0 and 6.1 layouts. Default settings sound exactly
  as before on mono and stereo tracks. Old projects may sound different if they contain: a PEQ
  cut band with Q above 1.93 (now 1.93 at most, resonance up to +6 dB), a custom IR file at
  another sample rate or longer than 10 s (resampling with a sinc filter instead of a linear
  one, a 50 ms fade-out when it is cut), a declicker at 44.1 or 96 kHz (windows according to the
  sample rate), channel loudness or surround reverb in quad, 5.0 and 6.1 layouts (correct
  channel maps), chorus, flanger and phaser on a track with an LFE channel (LFE is no longer
  modulated) and playback of those three effects from the middle of a clip (LFO phase from the
  item time, as in export).
- Expression Controls: the Expression Controls effect now has eighteen control types with their
  own names: slider (with range and unit), percent, integer, angle shown as in After Effects as
  revolutions and degrees (`2x +45°`), 3D orientation, checkbox, color with an eyedropper from
  the Program monitor, point with a handle on the monitor, 3D point, 2D and 3D vector, dropdown
  list with named items, layer (a clip choice), range, time, text, random seed with a new-seed
  button, and curve. You add a control with the "+ Control" button under the effect or from the
  effects menu (Expression Controls, then the type); the context menu of a row opens the
  settings (name, type, limits, slider range, step, unit, list items, tooltip), duplicates,
  moves and removes the control, and every change is one undo step. Expressions read controls by
  name: `ctrl("Speed") * time`, `ctrl("Rotation").revolutions`, `ctrl("Mode").item`,
  `ctrl("Target").value.position`, `ctrl("Window").lerp(0.5)`, `ctrl("Curve").at(time / 4)`, and
  the After Effects form `effect("Speed")("Slider")` works too. Copying and pasting a control's
  value onto another clip creates the missing control there. Older projects with the five old
  controls open unchanged. Agents got the MCP tools `list_controls`, `set_control` and
  `remove_control`.
- VST plugins: a new window with the vst.hexart.io catalog (over 1100 described plugins, with
  reviews, licenses and links), with search and filters, also with no network. HVE installs free
  VST3 and CLAP plugins with one click after confirmation: it downloads the file straight from
  the maker, checks SHA-256 and copies it to the user folders, with no administrator rights;
  they are then at once in the effects browser. Update and uninstall are in the same window.
  Paid ones and ones that need an account open the maker's page. Through MCP the agent searches
  the catalog and asks for an install, which always waits for your consent.
- Source color unchanged: DJI drone and phone files that write the old SD-era transfer tag
  (`bt470m`) in HD footage are read by HVE as BT.709, like Premiere and Resolve, so the render of
  such shots has exactly the source color and can go straight to the encoder. A change visible
  in old projects: the render of these files (until now recalculated from gamma 2.2, lighter in
  the shadows) changes to match the source. The old reading stays in the media menu in the
  Project panel: "Colour interpretation", "Tags as written" (also to choose from: forced Rec.709
  and log, PQ and HLG curves; in MCP `update_media` with `color`, any spelling, for example
  "BT.709" or "S-Log3"). PQ and HLG chosen by hand work like HDR tags: an HDR badge and an SDR
  preview.
- A shot drawn 1:1 (without scale, rotation or effects) comes out of the render with the source
  samples also when the frame goes through the graphics card (a title over the shot, a
  transition, another depth or subsampling of the output file): the card converts the source's
  Y'CbCr planes itself, without clipping colors outside RGB. The difference from the source falls
  from up to 50 code values in more than a third of the samples to at most 1 at the same depth
  and subsampling (0 outside the title and in H.264). 4:4:4 footage the same way, to every
  output: to 4:4:4 from up to 54 values in 24% of the samples to at most 1, to 4:2:0 and 4:2:2
  the same for luminance. Such a 4K shot also renders about 20% faster, because the decoder
  does not convert it to RGB. Unchanged: a 4:2:0 or 4:2:2 shot in an export with finer
  chrominance (4:4:4, RGB), which takes interpolated chrominance as before, and a shot shifted by
  an odd number of pixels horizontally (for 4:2:0 also vertically), which goes the old way.
- A layer placed 1:1 on whole pixels (shot, title, card) is copied pixel for pixel instead of
  through a filter, in the preview and in every export. The old filter let a trace of the
  background into the top row and the left column of the frame, and with sharp edges a little of
  the neighboring pixels. It changes 0.014 to 0.038% of the samples, in 95 to 99% of them by 1
  code value, by 10 at most (4:4:4 10-bit export), and the mean error against the source in
  those pixels falls from 0.95 to 0.34 code values.

## 0.19.22 (2026-11-07)

- Dropping a clip with picture and sound onto the timeline: the part under the cursor goes to
  the track you point at, the other part to a free track next to it (a paired one, the nearest
  free one or a new one), so nothing is overwritten. A new track shows while you drag as an
  outline under the tracks, appears when you release, and one Ctrl+Z undoes it all. The same
  with the Insert and Overwrite buttons of the Source monitor. Insert with Ctrl no longer takes
  picture and sound out of sync.
- Delete and Backspace with one part of a linked clip selected (Alt+click) remove only that
  part, in all layouts. Ctrl+C and Ctrl+X take only that part the same way, so a paste does not
  duplicate the part that stayed.
- A click on a clip end selects the edit point with its side with every trim tool and in every
  layout, including a free end of a clip; Roll selects both sides.
- A double click on a clip on the timeline opens it in Source with every tool and in every
  layout.
- Start without flicker: the editor window appears once, straight in its saved place and size,
  with a dark title bar. There is no white window in the corner of the screen and no jump on
  maximizing, and detached windows show up only in their own place.
- Splash screen: the program mark with animation, the version number and the start progress
  (graphics, settings, services, layout, agent server, project) on the monitor where the window
  will open. It fades over the ready editor. You turn it off in Preferences > General > Splash
  screen.
- When the editor window cannot open (for example with no graphics driver), the program says so
  in an error message window with the log folder, instead of closing without a word.
- Render queue from scratch: every render is a bar, and the waiting ones you drag by a handle
  into the order in which they should render (they render one after another). The bar shows the
  frame that FFmpeg is encoding right now, the file name (the full path in the tooltip, a click
  shows the file in its folder), percent with two decimal places, timecode and time left.
  Transfer with one button: during the render a "Transfer when done" field, then a button, and
  after sending a "Link" that copies the link to the clipboard until the link expires. WhatsApp
  the same way, with a choice of recipients and one consent before sending when whatsapp-scrap
  is running; a file larger than 16 MB HVE first shrinks in the background to a temporary copy.
  The queue is saved in the project and comes back after a restart (an interrupted render with a
  "Render again" button).

## 0.19.21 (2026-11-06)

- NTSC and VHS effect (`hve.ntsc`): a GPU port of zhuker/ntsc, a real deformation of the signal
  (composite encoding and decoding, ringing, noise, VHS tape filters), not an overlay. Best on
  an adjustment layer over the whole edit. Presets `broadcast`, `vhs` and `vhs_lp`, noise drawn
  from a seed and the frame number, so preview and export look the same.
- Faster export without changing a single sample: a clip with no effects that already has the
  pixel layout of the output file (the same subsampling, the same depth, matrix and range, the
  same size) goes from the decoder straight to the encoder in Y'CbCr, so the render is identical
  to the source bit for bit (before, it went through RGB and back). Layers fully covered by an
  opaque clip that overhangs the frame are not decoded or computed in export (the same result
  bit for bit, and a project with four 4K tracks renders several to over ten times faster).
  10-bit video goes from the decoder to the graphics card in half the bytes, copies to and from
  the GPU run in parallel, and the pipeline to the encoder has a larger buffer. All of this is
  checked by comparing frames before the encoder with the old path and with the source
  (difference 0). `hve render --stages` shows the timing of the stages, `--spec` takes any
  export settings.
- Transitions: a transition is visible over the full height of the clip, with its curve drawn.
  Dragging up and down under the transition bar changes the curve (up is faster at the start,
  down is slower), for picture and sound, in preview and in export; the value is also in Effect
  Controls and in MCP (`bend`). Shift while dragging a transition edge moves the motion onto the
  other edge from the moment of pressing, and when released leaves that edge where it got to.
- Trim preview: when trimming, rippling, rolling, slipping, sliding and dragging transition
  edges, Program shows the frame at the point of the dragged handle; for roll, slip, slide and
  transitions, two pictures side by side. After you release, it returns to the playhead. Both
  switches are in the View menu.

## 0.19.19 (2026-11-05)

- Playback with frame prediction: the editor works out ahead which source frames it will show in
  the next few seconds (Time Remap, reverse, nests, interpolation, J/K/L and shuttle up to 50x)
  and decodes them by GOP, with several decoders at once (also on a second graphics card), each
  frame on its own deadline.
  The picture follows the sound: a late frame does not hold it up for long, and a fast shuttle
  shows keyframes. `hve play --rate` measures any speed, `--legacy` the old path.

## 0.19.18 (2026-11-05)

- Work layouts: besides the existing layout, you choose in Preferences (and switch on the fly) a
  layout with the keys, gestures and panels known from other programs: Premier (Premiere Pro),
  Leonardo (the Edit page of DaVinci Resolve, with the Media and Edit pages), LasVegas (VEGAS
  Pro), Edison (EDIUS), Mozart (Media Composer), Cupertino (Final Cut Pro) and Studio (Pro
  Tools). Each layout has its own key map to edit in the shortcut editor, its own tools and
  workspaces, and the project stays the same: changing the layout does not change the timeline.
- Variable mask feather like in After Effects: the Mask Feather tool under G on the Program
  monitor adds a point with a click on the path and at once sets its radius outward or inward
  (one undo step). Shift keeps the point in place, Alt and a sideways drag change the tension,
  Ctrl and a click or Delete removes the point. The feather boundary is a dashed line, and the
  radius is visible next to the point you drag. A point in the middle of a straight side now
  works exactly there, the inner and outer boundaries pass smoothly through the path, and a
  point dragged onto the path pulls the feather in to it (a point with radius 0 from a click
  without a drag still changes nothing, so older projects look the same). Hold, the corner
  angle and such a pull-in come out sharp in the render, and new and removed points go into all
  keyframes of the path, also ones with a different number of vertices, at the same place on
  the path. Effect controls shows the number of points with a reset, and the MCP tools
  `add_mask` and `set_mask` take `feather_points`. In layouts where G, Q or V mean something else
  (Mozart, Edison, LasVegas, Studio, Leonardo, Cupertino), the letter stays with the layout
  until you pick the mask tool.
- Monitor shuttle: grey labels at the ends of the bar show the range (−8.00× and +8.00×), and
  the wheel over the bar changes it by 0.1× (by 1× with Shift) from 1.00× to 50.00×. The ticks
  follow the range. The wheel also works while you hold the knob, wherever the cursor is, and
  the speed at once follows the knob in the new range. The range is kept in the user's
  preferences, not in the project, and is the same in all layouts. On a narrow monitor the
  labels shorten or hide, and the full range is in the tooltip. Ctrl with the wheel still zooms.
  Above 20× the picture runs at full speed, and the tape sound fades out smoothly and comes back
  below 20×. J and L no longer slow down a faster shuttle set from the bar.
- Effect controls: a visible Property and Value column header with a divider you can drag, and
  the values of all rows (numbers, X and Y pairs, colors, lists, checkboxes, angles, text)
  start at the divider, with the unit right after the number. Effects, parameter groups and
  values are selected with a click, Ctrl, Shift or a rectangle, copied with Ctrl+C, pasted with
  Ctrl+V (also onto several selected clips at once, with keyframes at the same time from the
  clip start) and deleted with Delete, also from the context menu.
- Faster preview: a "No frame blending in the preview" switch in the Program bar and in the View
  menu. Program, scrubbing and playback then show the source frame without blending and Pixel
  Motion, while the export and the frames for agents stay as in the project. A badge is visible
  on Program.
- Render preview In to Out (Sequence menu; Premier `Enter`, Cupertino, Leonardo and Mozart
  `Ctrl+Alt+R`, LasVegas `Shift+M`, Edison `Alt+Shift+Q`, Studio `Alt+Shift+R`): the frames of
  the range are computed in the background like in an export and then play smoothly, also with
  Pixel Motion and Time Remap. The render bar on the timeline shows them in green, and the
  cache has a RAM and disk limit, an age and a Clear button in Preferences.
- Background work in the status bar: an indicator with a list of jobs, progress, cancel and
  Pixel Motion counters.
- 10-bit SDR footage (DJI, iPhone HEVC) without color effects decodes lighter during playback;
  with scopes, the before and after split, a LUT or color correction it keeps full depth, and
  the export is unchanged.
- Export no longer writes a black frame when a decoder does not keep up: a frame that is late
  gets a new decoder on the CPU and more time, and if it still does not arrive, the export
  stops with a message saying which file and which frame failed. The same goes for a web layer
  that does not render, and for offline media. 4K HEVC 10-bit export no longer decodes further
  ahead than frame memory holds (before, it pushed needed frames out of memory and looked for
  them again), and frames made by Pixel Motion are not decoded a second time at the layer size.
  During an export the Pixel Motion pre-render in the editor waits, so that it does not take the
  GPU from the export. Export has its own decoders that the preview does not take away, and they
  close after the export; cancel works at once, also when the export is waiting for a late
  frame.
- The Studio layout for working like in Pro Tools: Shuffle, Slip, Spot and Grid edit modes (F1
  to F4), Grabber, Trim, Selector and Pencil tools, nudge, zoom presets and Commands Focus. An
  audio track shows clips, a volume or pan automation lane, or take lanes in which a click
  plays the take and a drag comps a section. The Touch, Latch, Write and Trim automation modes
  record the fader movement as one undo step. In Studio the mixer gets sends, VCAs, an object
  panner and binaural monitoring. New ADR panel (cues from markers, three beeps, a streamer over
  the picture, loop recording of cues with rated takes) and Foley panel (cue sheet, tracks per
  category, recording passes).
- A double click on a sequence in the Project panel opens its timeline in every layout: the tab
  that shows it comes to the front (also from another window), and when there is none, a new
  one appears next to the other timeline tabs. A double click on a nest opens it the same way in
  a timeline tab, and Alt+double click steps into it in place as before. A double click in the
  middle of a clip opens it also when it lands on the opacity line or comes right after a click
  that selected the clip.
- Interchange with audio programs: AAF import and export for Pro Tools (clips with handles, clip
  gain, fades and crossfades, volume and pan automation of tracks, markers), REAPER `.rpp`
  projects (tracks, items, fades, volume and pan envelopes, markers and regions, tempo and
  meter, MIDI items) and MIDI `.mid` files as sequences with MIDI tracks and a tempo map. Each
  import is undone by one Ctrl+Z.
- Musical time on the timeline: a Bars switch turns the ruler into bars and beats, shows a tempo
  lane with points, ramps and meter changes, and a grid that gestures snap to (bars, beats,
  divisions down to 1/32 and triplets). Each tempo change is one Ctrl+Z. An audio track can
  follow the tempo and keep its pitch: Signalsmith Stretch stretches the clips, and the export
  sounds the same as playback. A MIDI or audio clip can be repeated as a pattern on bars.
- Multitrack recording: a new Recording panel. You arm any number of audio tracks, each with its
  own input (a channel or a pair) from one or several WASAPI devices, and record them at once.
  Punch in and punch out between the In and Out points with pre-roll, loop recording in which
  each lap is a take of the same clip that you switch in the panel, and input monitoring
  through the track's mixer with its effects. A recording lands on the sample it was played on:
  the latencies measured by the driver and the declared ones, and a manual offset in
  Preferences. The whole pass is one Ctrl+Z. ASIO is waiting for a license agreement with
  Steinberg.
- MIDI: MIDI tracks play through VST3 and CLAP instruments to the sample, and the export sounds
  the same as playback. A new MIDI Editor panel with a piano roll (drawing, moving, length,
  velocity, quantization with strength and swing) and a step editor for drums; each gesture is
  one Ctrl+Z. MIDI files (format 0 and 1) with a tempo map, MIDI device inputs and a side chain
  input for plugins.
- Object mixing: an audio track can be an object with a position in the room, or with an
  azimuth, elevation and distance, with automation. The mixer renders objects with ITU-R BS.2127
  to stereo, 5.1, 7.1, 7.1.2, 7.1.4 and 9.1.6, and playback sounds the same as the export.
- Headphone monitoring: a wider sequence can play binaurally on a stereo output (a head model,
  no external HRTF data).
- ADM BWF: writing and reading BW64 files with ADM metadata (bed and objects with movement), a
  format that Dolby Atmos Renderer, Pro Tools and Resolve Fairlight accept. Import recognizes
  the bed channels by speaker, so a bed in BS.2051 order or on any layout lands on the right
  channels. For now from the library only, menu commands will come separately.
- Broadcast loudness: presets ATSC A/85 (-24 LKFS, -2 dBTP) and Netflix (-27 LKFS measured on
  the dialog alone, -2 dBTP) next to EBU R128 and the platforms. The measurement in the mixer
  shows the dialog loudness and its share of the programme, and a verdict on whether the mix
  meets the chosen standard. Dialog is found by a local speech detector, so the result follows
  the method but is not certified.
- The mixer plays sends to aux buses (pre and post fader, with level and pan in automation), VCA
  faders and side chain: a compressor on the music can duck it under the dialog. Each branch
  keeps plugin latency to the sample, and playback sounds the same as the export.
- Fader automation in Touch, Latch, Write and Trim modes: the whole pass is one change in the
  history, undone by one Ctrl+Z.
- Bounce of a track to a WAV file and track freeze: a frozen track plays from the file until it
  changes.
- Buses of up to 16 channels: 7.1.2, 7.1.4 and 9.1.6 play in full, with downmix to 7.1, 5.1 and
  stereo.

## 0.19.9 (2026-11-04)

- Source: a click or drag on the bar under the picture jumps straight to that spot, also at the
  end of a very long clip. Tape-style scrubbing with sound is now under Ctrl.
- Project: Del removes the selected clips, sequences and folder (it asks first, with an "Ask
  next time" box), F2 renames.
- Project: folders and sequences look like clips, in the same list and the same grid. A folder
  opens with a double click.
- "Reveal in Project" from the timeline opens the folder with the clip and selects it.
- Window layout: a panel dropped on the button at the edge of the dock lands next to the whole
  layout. The grip at the right end of the tab bar moves the whole group at once.
- "Reveal in Timeline" does not open a second tab for the sequence that the main timeline
  entered as a nest: the main tab goes back up to it.
- Project: "Replace Footage…" swaps the file of a clip everywhere it is used (the same clip, a
  new source, one Ctrl+Z).
- Project: F2 renames in place, right on the name, without a window. Enter or a click elsewhere
  saves, Esc keeps the old name.
- Masks like in After Effects: many masks on a clip with a name, color and order, the modes
  None, Add, Subtract, Intersect, Lighten, Darken and Difference, an Inverted switch, and on top
  of that a path, feather (X and Y), opacity and expansion with keyframes.
- Masks are drawn on the Program monitor: rectangle, rounded rectangle, ellipse, polygon and
  star (Q), a pen with adding, removing and converting vertices and a variable width feather
  (G), free transform (Ctrl+T). Shortcuts as in After Effects: M, MM, F, TT, Ctrl+Shift+N,
  Ctrl+Shift+I, Ctrl+Shift+M, Ctrl+Shift+F, Ctrl+Shift+H.
- Mask feather with a smooth or linear falloff, and motion blur of the mask. Preview and export
  look the same.
- The AI agent adds and changes masks over MCP (`add_mask`, `set_mask`, `move_mask`,
  `remove_mask`).
- A connected clip moved together with its parent, or attached to another clip, takes its sound
  and the rest of its linked parts along.

## 0.19.5 (2026-11-03)

Faster export, licenses on every element of a film, a new web layers browser and an AI agent
working in the background on any project.

Export:

- Colors are computed on the graphics card at export: frames go to FFmpeg at once in the format
  of the codec, so 2 to 2.7 times less data goes to FFmpeg and it converts nothing. Picture
  quality stays the same.
- The next frames are read back from the graphics card ahead of time, and writing to the codec
  runs on a separate thread. Source decoders prepare the next frames earlier. The UHD H.264
  export loop went from 29.6 to 23.5 s on our workstation, HD from 14.9 to 11.4 s.
- ProRes without an alpha channel at the Fast and Balanced speeds uses a faster ProRes encoder:
  4K ProRes HQ is computed in the editor at about 20 frames per second instead of 5.5. The files
  are larger (by 28 to 72%), and picture quality stays very high. The Quality speed and ProRes
  4444 with alpha stay on the existing encoder.
- NVENC at the Balanced speed uses the p5 preset: about 40 frames per second instead of 20 in a
  4K test. Quality and Smallest file stay on p7.
- The export window shows the encoder speed for ProRes too.

Timeline:

- Switching to the tab of another sequence's timeline lets you edit it at once. Before, the tab
  reacted only after a second click.
- Timeline zoom (keys, Ctrl and Alt with the wheel, slider) keeps the playhead in the middle of
  the view. You can turn this off in Preferences.
- Own cursors for every timeline tool, and a preview of what a click will do. Razor draws a cut
  line through all the clips it will cut. Trim, Ripple, Roll and Rate show brackets at the edit
  point and highlight the edges that will change. Slip shows how far the source can be moved,
  and Slide the edges of the neighbors. Track select and Type show what they will cover.
- Markers can be dragged on the ruler (with snapping, Alt turns it off, Esc cancels). The
  Markers panel highlights the current marker during playback and scrolls to it.
- A click in an empty part of a track and rubber-band selection no longer move the playhead.
  Only the ruler and the playhead line move it.
- A dragged clip also snaps to its own start and end from before the drag.
- Copy and paste redone: the clipboard remembers tracks, pasting overwrites nothing (everything
  lands on the first free tracks, new ones are created when needed), and Ctrl+Shift+V pastes
  with an offset. Pasted clips are selected, and the playhead stops at their end.
- Zoom keys act on the panel under the cursor or the one clicked last (Effect controls,
  monitors), and otherwise on the timeline.
- A second click on a selected gap deselects it.
- The ruler is taller (42 instead of 28 points), with a larger playhead and marker flags.
- Lift and Extract work only when In and Out are set, and the buttons say what is missing. The
  full range is highlighted more strongly on the timeline, and after a cut a message says how
  much was cut and from how many tracks.
- Alt while dragging a volume or opacity key: the Bézier handles grow with the drag instead of
  jumping to 100% at once.

Project:

- Commands from the context menu of the Project panel act on the whole selection: one change in
  the history, a count in the name of the command and a note about skipped items. Select
  sequence rows with Ctrl and Shift.
- "Reveal in Timeline" opens all sequences that use the selected media. The one with the most
  hits stays active, the others have a light gold tint until the first click.
- A new Proxy queue panel (Window > Output), opened from the status bar: cancel, retry, show the
  file and remove from the list.
- Show in Explorer selects the file also when the path has a space (before, it opened
  Documents). When the file is gone, it opens the nearest existing folder.
- Frame interpolation for a selection: in the clip menu, right below Speed / Duration, one
  command for all selected video clips, with a mixed state when the clips have different modes.

AI assets:

- The panel is a real generator: kind, a multi-line description, reference cards with
  thumbnails and a model choice. The gallery uses the same grid and list as the Project panel
  (size slider, Ctrl with the wheel, columns fill the width), and the tiles do not jump on
  hover. Motion preview on hover stays.

Effects, color and web layers:

- One browser in the Web layers panel: project layers, built-in ones and the library in a single
  view, without tabs. Search covers everything, with a tree on the left (Source and categories
  with subcategories) and tag filters as chips. Grid and list views, a size slider, motion
  preview on hover, badges (aspect, alpha, loop, source, problems), a double click places it on
  the timeline, a drag drops it on the timeline.
- The web component library has 455 items in 26 categories: new charts (bar, line, share,
  gauges, flows and special), maps, infographics and 3D components.
- Motion blur of web layer content: a switch in Effect controls blurs the motion inside the
  page, not only the motion of the layer itself. The shutter angle (180° by default) and the
  number of samples (8 by default) are parameters with keyframes. Pages that keep state over
  time (animations, counters) get a warning instead of a silent absence of the effect.
- Web layers show frames faster: several browsers in the background instead of one, and during
  playback the frames ahead of the playhead are prepared in advance. In a test with six 1080p
  layers, renders per second rose from 32 to 65.
- Effect point handles on the Program monitor: the mask center, the focus point of Camera Lens
  Blur, the window center in secondary correction and the point of the Controls effect can be
  dragged directly on the picture. The direct editing switch is in the monitor bar, between the
  timecode and the scale menu.
- Group view in Effect controls: with several selected clips that share an effect, the
  parameters are shown together (a "Per clip | All clips" switch), values that differ between
  clips are "mixed", and the target preview highlights the clips that a given field will
  change. Parameters can be linked into clip groups.
- RIFE interpolation at 4K on DirectML no longer produces vertical streaks in Pixel Motion mode.
  The picture of large frames is computed in overlapping bands, and badly computed frames from
  the cache will be recomputed.
- Numbers that round to zero no longer show a minus (for example "-0.00 px/s" under the keyframe
  graph).

Time and number fields:

- All time fields are one component: they commit with Enter, Tab, loss of focus and a click
  outside the field (Esc cancels), slow dragging moves by fractions of a frame, and they show
  time in the chosen mode (Ctrl with a click switches: timecode, frames, seconds). A time field
  is now also used for the transition duration, the length limit in AI Rough cut, the In to Out
  length on the Program monitor and the export window.
- Long export preset names end with an ellipsis, and the full name is in a tooltip.

Sound:

- The Source monitor plays sound: playback, J/K/L and backwards, In/Out loop, scrubbing during
  play, like on the Program monitor. Dragging the Source bar and the timecode scrubs the sound
  like tape.
- Master fader in the Audio mixer: adjustment from -96 to +15 dB with a double click to 0 dB,
  one undo step per drag. It covers playback, export, loudness measurement and nested
  sequences.

Licenses:

- Licenses on every element (file, plugin, font, web layer, component, reference, generator,
  effect). A project has a work type: private, non-commercial, commercial (the default), for a
  client or broadcast. Each element gets a verdict: fine, obligation, caution, condition not
  met, unknown or conflict. The Licences window describes each work type.
- Next to an exported film come a file with a full license snapshot (`NAME.LICENSE.txt`) and a
  list of credits for the description or end titles (`NAME.ATTRIBUTIONS.txt`). Both can be
  turned off in Preferences, and the agent's draft export does not create them.
- License request mode: for each element it shows whom to ask and for what. A draft of the
  request is only a file in the project folder, nothing is sent.
- The AI agent cannot increase the use of a blocked element (a new clip, a copy, longer or
  faster), and the final export, sending and publishing are checked before asking for consent
  and once more after it. Only you change the declarations and the work type. This is an aid,
  not legal advice: the reports say plainly what they do not cover.

AI agent (MCP):

- The agent works on any project in the background and does not switch the program's window: the
  project is the context of the agent's session, and the window and agents on the same folder
  share one history. Projects in the background autosave and are released after 30 minutes of
  silence.
- After handover to the window (`show_editor`), running exports finish in the background and
  `export_status` still reports them. When other jobs run (transcription, analysis), the window
  waits for them or cancels them on an explicit command.
- `export_status` gives the elapsed time, the estimated end and frames per second, and with
  `wait` it waits until the export ends. Without a job it lists all exports of the session.
- `normalize_audio` has limits: the largest gain, a silence gate and a maximum peak (-1 dBTP by
  default, measured as true peak). The result says which clips were limited and why.
- Local Whisper has time limits per clip, and a failed clip does not stop the whole job. Silent
  passages, subtitle credits and typical made-up phrases over silence are removed from the
  transcript.
- `render_frame` waits up to 30 s for layers that are still loading instead of returning an
  incomplete frame, and when the frame is incomplete it says why.
- `edit` accepts track names (`V1`, `A1`) and files with commands, returns identifiers of
  nested objects, and `write_component` accepts enum options as plain text.
- Review mode: a "Change with agent" button in the middle of the bottom bar. You turn it on,
  speak and point with the cursor at what to change, and when you turn it off the program hands
  this to the agent as one guideline. The frame in the program windows glows according to the
  microphone level.

Installation:

- Updating with the installer succeeds also when some program holds HEXART Video Edit files, for
  example an AI agent session connected over MCP with the FFmpeg libraries loaded. Busy files
  wait next to the new ones and disappear at the next install or program start, when nothing
  uses them anymore.
- The uninstaller also removes the component library and downloaded updates.

Windows and layout:

- Dialog windows, including Preferences and Licences, fit small screens (1280x720 and smaller) with
  the buttons always within reach. Windows measure their own title bar and frame, and leave a
  margin at the top and bottom in the center. They open in the right place at once, without a
  jump after the first frame.
- Preferences and settings have single columns of labels and fields in every section, and
  wrapped chips ("Panels that expand", "Default settings") no longer cover the neighboring
  fields.
- Smart panel expanding reads the intent of the cursor: a dead zone at the edges, only time
  spent deep and slowly in a group counts, a cursor returning to a group that has room takes
  nothing away, and a click or the wheel take room at once. Changing a tab in a group does not
  collapse it back. New settings "Delay before taking over" and "Dead zone at the edges" in
  Preferences > Interface.
- When the tabs of a group do not fit, the "+N" button stays pinned on the left, the list marks
  hidden tabs, and the edges fade where something is hidden. Scroll bars are visible when the
  content overflows and brighten on hover.

## 0.19.0 (2026-10-30)

Fixes after the second test with an editor and new notes on the interface.

Windows and layout:

- Nothing goes off the screen: windows, dialogs, menus, drop-down lists and tooltips fit on the
  screen (1280x720 too), long content scrolls, and the title and buttons stay visible.
- AI windows separately: Agent, Approval requests, Analysis, Search media, Rough cut and
  Rotoscoping and stems are separate panels. The Window menu has categories (Editing, Effects
  and graphics, Color, Audio and text, AI, Output), and an open panel has a gold icon.
- Dock tabs: the gold bar does not stay on a covered tab, and when the tabs do not fit, a button
  at the end of the bar shows the rest.
- Dragging between panels: an effect from the Effects panel onto Effect controls, onto the
  Program monitor and onto a clip, effect presets, effects in the stack (change of order; onto
  another clip: moves, with Ctrl copies).
- Smart panel expanding: a switch in the top bar next to Workspace (off at first, also in
  Preferences > Interface). After a moment, the group of panels under the cursor takes room from
  its neighbors; your layout stays the base, and moving an edge by hand sets a new one.
- Project settings have their own window (File > Project settings), and Preferences no longer
  repeat the Interface section.

Project:

- A size slider in list and grid mode (also Ctrl + wheel). The grid always fills the width of
  the panel.
- A preview under the cursor scrubs the clip with a horizontal movement (Project and AI assets).

Timeline:

- Every sequence can have its own timeline tab (the menu of a sequence in Project and of a
  nested clip), and the playhead goes through nests.
- Lanes above the top video track and below the bottom audio track: a clip dropped there creates
  a new track. At the bottom "+" adds a video and audio track, and "−" removes the empty ones.
- The last filmstrip frame at the end of a clip is truly the last frame of the clip.
- Replacing a clip: a clip from Project dropped with Alt onto a clip on the timeline replaces it
  (like Replace in Premiere), Shift+Alt with source time sync.
- Markers on the timeline: hovering highlights them, a click selects like in the Markers panel,
  right click opens their menu.
- The tools panel has a fixed width and a fixed icon size.
- The wheel over the tracks can scroll the timeline horizontally (Preferences).
- Tape-style scrubbing with sound: jog/shuttle and Ctrl with a playhead drag play smoothly, with
  the pitch following the speed, without clicks when changing direction and stopping.

Effects, color and web layers:

- The effects list is a tree with collapsible branches and sorting (Polish letters sorted
  correctly), with effect presets as a separate branch.
- You change the height of graphs in Effect controls by dragging an edge, and the clip volume
  curve has visible Bézier handles.
- A negative scale in Effect controls flips the picture on that axis, like in After Effects.
- Z-depth from Video Depth Anything with a constant depth range over time, and the Camera Lens
  Blur effect.
- Blend modes computed correctly: Multiply, Darken and the others do not darken the background
  of the sequence, and Add and Screen look different.
- Web layers no longer show flickering leftovers of old frames after a change without a
  keyframe, and motion blur works inside the page too.
- The web component library in the Web layers panel (the first components), parameters with JSON
  data and a data editor.
- The preview of a Rec.709 sequence (monitor, NDI, `render_frame`) has the same colors as the
  export. SDR preview tone mapping now works only in HDR sequences, so the peak of the
  mastering display no longer dims and compresses the highlights of SDR clips.
- Drop-down lists do not jump on hover, and the vectorscope has a higher resolution.

Sound:

- Submixes with their own effect chain: a track goes to Master or to a submix. dB scales next to
  the faders in the Audio mixer.
- Effects in the chain of a track and a submix: you change the order by dragging, dragging onto
  another bar moves the effect with its settings, with Ctrl it copies.
- 5.1 and 7.1: surround pan, a separate center and LFE on a track and on a clip, multichannel
  tracks on the timeline and multitrack export with advanced settings.
- Film stems in the AI panel and in `separate_stems`: dialog, music and effects, also music with
  effects, voice and the rest, and six stems (with guitar and piano). A new CASS engine (Bandit
  v2 and DBS-TIGER); the last stem takes the rest, so the stems add up to the source.
- Word transcripts that follow the edit: local Whisper (free, offline, installed in Preferences
  > Transcription) or ElevenLabs Scribe (paid, with speakers, after a quote).

Work together online:

- The session continues without the host: guests keep working when the host leaves or closes the
  program, and media downloaded once stay.
- After a restart, the program offers "Back to the online session" with one click.
- When sharing, you decide whether guests may invite more people.
- Media upload fits the server limits: server refusals end in a wait and a retry, progress is
  shown per file, and the session window with a long list of files fits the screen.

Agent and program:

- Export to HXC, the HEXART codec: "HXC" and "HXC lossless" presets in the editing group, with
  the sound in an `.hxc.m4a` file next to it. This is an intermediate file for HEXART Video Edit
  (other programs will not open it), not a file for the client. An `.hxc` file can be imported
  back like any media.
- Connecting the AI agent from the program: Preferences > Agent shows whether Claude Code and
  Claude Desktop are on the computer and whether they see the program, and the "Connect" button
  writes the right command (also for a copy unpacked from the zip). The Claude Desktop
  configuration gets a backup, and other servers and settings stay unchanged. In Claude Code you
  choose the scope: all projects or one folder (its `.mcp.json`), with a move between them, and
  for those who prefer to ask Claude, there is a ready command to paste. From the terminal:
  `hve agent status|connect|disconnect`.
- First start wizard: language, projects folder, agent connection, automatic updates and bug
  reports. You can skip it; it comes back from the Help menu.
- The installer is also in the zip: run from the unpacked folder, it installs those files.
- `hve mcp --connect` ends together with its client and leaves no processes behind.
- A bug report can include a screenshot of the program window (the "Attach a screenshot" box,
  off by default): a thumbnail, a large preview and "Retake". HEXART keeps the screenshot
  privately, it is not published.
- The "Licences and components" window lists the film stem models and their licenses.

## 0.18.1 (2026-10-29)

- The "Licences and components" window with a list of the components of the program and their
  licenses. The purpose of a project (commercial or private) in the project settings; the export
  says when a project uses a component allowed only for non-commercial use, and asks for one
  confirmation.
- Full license texts, the license agreement and rights information in the package.
- The program no longer closes right after start when the Fonts panel was open with a downloaded
  font.

## 0.18.0 (2026-10-29)

Fixes after the first test with an editor.

Collaboration links:

- Clicking an `hve://` link in a browser opens the program (the installer registers the link,
  and the installed program repairs the registration at start). When the editor is already
  running, the link goes to the open window, which comes to the front with the join form filled
  in. You always confirm joining yourself.
- Links pasted from a chat or an email also work without `https://`, with text around them, with
  `%23` instead of `#` and with an added slash. A damaged link says what is wrong.

Work together online:

- A view link gives a view-only mode: changes no longer disappear silently. The sharing window
  shows the edit link first.
- The project opens for a guest at once, and the files download in the background with progress
  (first the ones at the playhead) and replace themselves.
- "Follow" (right button on another person's playhead label, or the list of people): the
  playhead, playback, zoom and scrolling of the timeline, the sequence and the active monitor
  follow that person until you interrupt (Esc, a click or an action of your own).
- In an online session Ctrl+Z undoes the newest change of the shared history, whoever's it is,
  and the message says whose change it was. Undo no longer loses the changes of collaborators.
  The clipboard stays personal.
- Two people with the same name are told apart by a color and a short code next to the name.
- File > "Open shared project link…" and a button in the projects window; you can also simply
  paste the link (Ctrl+V outside text fields).
- Clips that are not downloaded yet have a marker with the progress of uploading or downloading.

Timeline and transitions:

- Transition handles: an edge changes the length only on its own side, with Alt both at once,
  the middle moves the whole transition along the cut. The cursor shows the mode.
- The part of a transition outside the source material is hatched, and the tooltip says how many
  frames are missing on each side.
- Ctrl+D has one rule: selected adjacent clips get a transition only between themselves, one
  selected clip gets it on the cut nearest the playhead, and with no selection it goes on the
  cut under the playhead. One press never adds two transitions.
- Short transitions from older projects show their name again.
- The wheel over the time ruler moves the playhead by one frame, with Shift by 5 frames.

Monitors:

- Zoom from 10 to 400% works in Program and Source (100% is one picture pixel per screen
  pixel), panning with the middle button or the Hand tool (H), Ctrl + wheel zooms around the
  cursor, a double click on the zoom menu or Backslash returns to fit.
- The wheel over a monitor: frame by frame, with Shift by 5 frames.
- Jog/shuttle under the transport buttons: you grab the slider, the deflection is the speed and
  direction (up to 8x), releasing stops. J/L change the speed without a jump.

Keyframes:

- A dragged keyframe follows the cursor (Shift snaps to the playhead and other keys, Esc
  cancels), the whole drag is one change in the history and does not start playback.
- In the graph editor a dragged key takes the other selected keys along.
- The playhead in the Effect controls panel can be grabbed and scrubbed.

Audio:

- The waveform on the timeline shows the clip volume (also keys and mute), live while dragging;
  clipping has a red end.
- "Normalize audio…" in the clip menu: to a peak in dBFS or a loudness in LUFS, each clip
  separately or all together, with a preview of the change and one change in the history. The
  same for the agent in MCP.

Project and files:

- The project name comes from the folder or from the create dialog; "Untitled project" no
  longer appears. "Save as" has the same dialog for name and place and does not lose media.
- Dragging a clip onto "+" in the Project panel (or "New sequence from clip") creates a sequence
  with the settings of the clip: size, frame rate, HDR and audio.
- File > "Collect files…" copies all media to the project folder (identical files once).
  Optional copying on import in the preferences.

Export:

- Films with sound always have all the frames and sound exactly as long as the picture (before,
  it could be one frame short, for example in MXF).

Cache:

- Settings > Cache: choose the cache folder (for example on another disk). The change works from
  the next start: fonts and generations move to the new folder, previews and Pixel Motion frames
  in the old one disappear.
- Previews (gallery thumbnails, audio waveforms) have a limit of size (5 GB by default) and age
  (30 days without use by default); the least recently used disappear by themselves. "Clear
  previews" removes them at once.
- Thumbnails and filmstrips are saved as WebP instead of PNG: several times less disk space.

Proxies in the HXC codec:

- A new HXC proxy format (the HEXART codec): the View menu "Create HXC proxies of selected
  media". Scrubbing without waiting (every frame separately), a smaller preview decodes only the
  needed resolution, decoding on the graphics card. The proxy sound is next to it, in an `.m4a`
  file.
- A proxy plays by itself when the original is not on the disk (also the sound), and when
  turned on in the preferences, also for heavy sources (ProRes, DNx, RAW, above UHD). "Turn off
  proxies of selected media" removes the proxy from the chosen media.
- The proxy folder has a limit and an age in the preferences (50 GB and 60 days by default), a
  displayed size and a "Remove unused proxies" button; the proxies of the open project never
  disappear.

## 0.17.0 (2026-10-29)

Windows on every monitor and workspaces:

- Every panel can be undocked into a separate system window and moved to any monitor: drag the
  tab out of the window or choose "Undock to its own window" (the whole group: "Undock the group
  to its own window") in the tab menu. A window can hold many tabs and splits, like the main
  one.
- Tabs move between windows by dragging: over a group in another window the same buttons appear
  as in the dock (into the group or onto its side). Closing a window docks its panels back in
  the main window; the tab menu also has "Dock in the main window" and "Dock the whole window in
  the main one", and the Window menu has "Dock every window in the main one".
- Keyboard shortcuts and panel focus work in undocked windows.
- The program remembers the layout of all windows: place, size, maximization and monitor. When a
  monitor is gone or a window would fall off the screens, it lands on the main monitor in the
  same place relative to the screen; a change of scale (DPI) and resolution does not break the
  layout.
- A new Workspace menu next to the project picker, showing the name of the current one: Editing,
  Color, Audio and mixer, Effects and animation, Captions and text, AI and generation, Review.
  Switching takes one click, and a workspace remembers how you left it. "Save changes", "Save
  current as new…", "Reset to saved layout", "Restore the default preset", rename and delete for
  your own. A workspace covers the main window and all undocked windows on all screens; the last
  used one is remembered.

Work together online through a link:

- "Work together online": "Start sharing" gives a link with which other people work live in the
  same project, also in one timeline; the changes of everyone, including the agent, are seen by
  all at once. A separate "Link to view" gives view-only access.
- The project is encrypted end to end. Files imported by one person land on the disks of the
  others by themselves and stay on the server for 24 hours at most; the paths to the files are
  private. The playheads of other people are dimmed in blue on the timeline.

Markers:

- Marker editor: a name, labels and a description. The description is plain text or, after
  switching to JSON, a document with a conversation with the agent and a list of tasks for
  fixes. All of this also in the MCP tools for the agent. Export of markers to Premiere, EDL and
  OTIO unchanged.

## 0.16.0 (2026-10-29)

Automatic updates:

- The installed program checks by itself whether there is a new version on GitHub (shortly after
  start and every 6 hours), downloads it in the background, checks the SHA-256 sum and the
  version number, and installs without asking when the editor closes or when the agent server
  in the background has been idle for 10 minutes (then it comes back by itself in the new
  version with the same project). A failed swap breaks nothing: the files go back in place.
- A gold "Update X" button on the status bar: it closes the editor (asking about unsaved
  changes first) and starts it in the new version.
- Preferences, Updates section: "Update automatically" (on by default), the version number,
  "Check now" and the status.
- `hve update` updates from the command line, `hve update --check` only checks.

Audio mixer and timeline completed:

- Mixer: peak meters L and R next to the fader of every track (after the fader and balance, with
  hold and an overload marker like on the master).
- 35 built-in audio effects with about 90 presets: Multiband Compressor (4 bands, Linkwitz-Riley
  crossovers, presets Old Radio, Walkie-Talkie, Telephone, Toy, AM Radio, Megaphone, Broadcast,
  Podcast and others), a single-band compressor, a limiter, a gate, a de-esser, a tube
  compressor, Dynamics; low-pass, high-pass, band-pass and all-pass filters, a Parametric EQ (7
  bands) and a Graphic EQ (10 bands), Bass, Treble; Studio Reverb (FDN) and a spatial reverb
  (convolution with generated responses of 10 rooms or from your own WAV file, 5.1 and 7.1
  channels); delay, multitap, Chorus and Flanger, phaser; DeNoise, DeHummer; Distortion,
  Bitcrusher, a vocal enhancer; stereo and mastering tools; a declicker (clicks and record
  crackle). Distortion with oversampling (up to 8x), a limiter and a maximizer with look-ahead
  and true peak; their latency is compensated like in plugins. An impulse response file with a
  path relative to the project folder.
- MCP: `list_effects` and `list_bus_effects` show presets, and a new tool `apply_effect_preset`
  (one revision).
- Presets in the effect header in Effect controls: one undo step, parameters that the preset
  does not change go back to the defaults. The effect search also finds by identifier
  ("multiband").
- Keyframe lines on the clips of the timeline: volume for audio and opacity for video, a
  drop-down list in the track header picks any parameter of a clip, of an effect on the track
  bus or of a plugin (also volume and pan automation of the track). Ctrl and a click adds a key,
  dragging the line lifts the whole segment, Alt and a drag of a key makes a Bézier (also in
  Effect controls and in the graph editor), Alt and a click switches between linear and
  automatic Bézier.
- The expression pick whip also works between clips, track buses and the master:
  `thisComp.track("A1")` and `thisComp.master` with `effect()`, `effects` and `numEffects`; the
  link indicators jump to the bus.
- Right click on a clip: "Expand audio from source" and "Expand video from source" add the
  second stream on the first free track and link it to the clip.
- Tracks always fill the panel; Shift and plus or minus over the timeline gently enlarges or
  reduces all tracks; dragging the border between tracks resizes the whole group elastically
  (the grabbed border follows the cursor), and the middle separator splits the height between
  video and audio proportionally.
- The width of the header column is dragged by its right edge (remembered), the corner with the
  tool name and the end time is gone, and long track names end with an ellipsis (the full name
  is in the tooltip).
- Ctrl and a click on a timecode switches between timecode, frame number and seconds; the rulers
  of the timeline and of Effect controls show the same.
- Every number field accepts operations: `*2`, `+10%`, `/4`, `-=1.5`, `(1920-40)/2`, functions
  (`round`, `min`, `max`, `clamp`, `db`), time units in time fields (`+2s`, `-12f`, `1:30`), a
  decimal comma.
- Transitions: drawn over both clips with a name, the edges stretch in the right direction
  (centered ones grow symmetrically), Delete on a selected transition removes the transition,
  not the clip; an incoming transition on a cut where playback does not use it anyway is no
  longer shown.

## 0.15.0 (2026-10-28)

First public release: https://github.com/lazniak/hexart-video-edit (a one-line installer in
PowerShell, FFmpeg in the package).

- Bug reporting from the program: Help > Report a bug or an icon in the menu bar. A description
  in text or a voice note up to 3 minutes, a log from the last minute attached by default
  (a slider from 10 s to 10 min, text you can edit) and device information, with paths and the
  user name hidden. The report arrives as an issue on GitHub; the HEXART server turns the
  recording into text (ElevenLabs Scribe v2), and the recording itself is not published. When
  sending fails, the report is kept on the disk.
- Never a black frame with clips on several video tracks: a decoder that died midway is no
  longer taken for the end of the file, a momentary failure leaves no hole, past the end of the
  file the monitor shows the last frame like the export, and a layer without a picture is held
  until a frame arrives. The monitors do not decode layers fully covered by a clip above, so
  scrubbing and jumps on 4K footage on several tracks stall clearly less (jumps by click
  without freezes, scrubbing back and forth at most 0.2 s).
- Playhead in the middle of the timeline, an option in Preferences (off by default): the
  playhead stands in the middle, and the sequence moves under it during playback, scrubbing and
  scrolling. A second option: the mouse wheel zooms around the playhead, Shift and wheel scroll
  horizontally, Alt and wheel or the wheel over the headers scroll the tracks.
- Scrubbing and clicks while paused without black frames and without UI stutter: the UI thread no
  longer waits for the end of the FFmpeg process (up to 0.8 s at 4K), after a jump the monitor
  holds the picture only for a layer with nothing, placeholder frames from the whole range of
  the clip, a seek while paused decodes the frame and the 3 next ones, sessions that the
  playhead no longer asks for stop, and a ±3 s preview is decoded around a stopped playhead. A
  new measurement `hve scrub`.
- Timeline zoom is anchored on the playhead.
- FFmpeg bundled in the package (9.0.2); the program looks for it next to itself first.

## 0.14.0 (2026-10-26)

First release with a tag. It contains everything that was made so far.

New since the last test version (25.10):

- Expressions in full JavaScript: the QuickJS-ng engine with an object API, sequence variables,
  `hve.vars` and `hve.publish` in web layers, an expression editor with coloring, hints and
  signature help, a Variables panel, documentation from the Help menu (PL, EN), MCP tools
  `validate_expression`, `evaluate_expression`, `expression_docs`.
- Nested sequences: nesting picture and sound with spare material, flattening without changing
  the result or a refusal with a reason, opening nests, a path back.
- Recording a voice-over from a microphone straight onto the timeline: REC in the timeline bar
  (Shift+R), a countdown, a live waveform, a start from the In point or the playhead, repair of
  takes after a crash.
- Effect controls and Time Remapping like in After Effects, Pixel Motion, a Tools panel in the
  dock.
- Professional export: formats, 79 presets, an In/Out preview, checks before export, QSV
  verified on Intel hardware, corrected AMF arguments, all presets available to agents.
- A custom application icon (a frame with a playhead).
- Audio: loss of a device or a hung driver does not block the engine.
- FFmpeg and RAW decoders always report the reason for ending.

Earlier: the timeline from the mouse press, dragging with the system, HDR according to the
standards, color correction like in DaVinci Resolve, a web layers library and MCP, frame-exact
playback with work in the background, the agent server in the background and a project switcher.
