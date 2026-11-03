---
name: mkv-mux
description: "Combine a movie file with all recursive subtitle files (SRT, ASS, SSA, SUB, VTT) into an MKV container without re-encoding using ffmpeg. Use when the user wants to mux subtitles and a movie into an MKV file."
---

# MKV Subtitle Muxer

Combines video and all recursive subtitle files into an MKV container without re-encoding (`-c copy`).

## Usage

```bash
# Run the helper script in the directory containing the movie and subtitles:
<skill-dir>/scripts/mux-subtitles [directory] [--output output.mkv]
```

## Features
- Automatically finds the largest video file in the target directory (recursively or flat).
- Finds all subtitle files (`.srt`, `.ass`, `.ssa`, `.sub`, `.vtt`) recursively.
- Guesses subtitle language from filenames (e.g., `.en.srt` -> English) and sets correct stream metadata.
- Muxes video, audio, and all subtitles instantly using `ffmpeg -c copy` (no re-encoding, zero quality loss).
