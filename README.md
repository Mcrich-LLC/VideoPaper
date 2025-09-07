# VideoPaper

VideoPaper is a lightweight macOS utility that lets you add your own looping video wallpapers so they appear natively inside System Settings > Wallpaper alongside Apple’s built‑in aerial / motion wallpapers — all without requiring admin privileges.

> Current format support: **`.mov` only** (H.264 or HEVC recommended). Additional formats may come later.

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Why .mov Only?](#why-mov-only)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Preparing Your Video](#preparing-your-video)
- [FAQ](#faq)
- [Credits](#credits)

---

## Features
- Adds your custom video(s) so they appear like native motion wallpapers
- No administrator permissions required
- Simple, focused UI (made initially for SwiftSaturday)
- Designed for macOS 26+ (see note below)
- Clean removal (no invasive system changes)

---

## Requirements
- macOS 26 (Tahoe) or later  
  (If you are testing on earlier public macOS versions, behavior may be undefined.)
- Apple Silicon or Intel Mac
- Xcode (only required if building from source)

---

## Why `.mov` Only?
macOS prefers `.mov` containers for certain system‑integrated media workflows. Restricting to `.mov` ensures:
- Reliable metadata parsing
- Smooth looping behavior
- Compatible codecs (H.264 / HEVC)

Support for `.mp4` or other containers may be explored later.

---

## Installation

### Option 1: Download (Recommended)
1. Visit the repository’s Releases page (if available).
2. Download the latest `VideoPaper.app` zip.
3. Move the app to `/Applications` (optional but recommended).
4. Launch it (you may need to right‑click > Open the first time due to Gatekeeper).

### Option 2: Build from Source
1. Clone the repo:
   ```
   git clone https://github.com/Mcrich-LLC/VideoPaper.git
   cd VideoPaper
   ```
2. Open in Xcode:
   ```
   open VideoPaper.xcodeproj
   ```
3. Select your target + Run.

---

## Quick Start
1. Launch VideoPaper.
2. Click the + button.
3. Upload a `.mov` file
4. (Optional) Change the thumbnail to a custom one.
5. Click Save
6. Open System Settings > Wallpaper and choose your new custom video.
7. Enjoy the looping motion wallpaper.

---

## Preparing Your Video

### Recommended Specs
- Format: `.mov`
- Codec: HEVC (smaller) or H.264 (broader compatibility)
- Resolution: Matches or is close to your display (e.g., 1920×1080, 2560×1440, 3840×2160)
- Frame Rate: The higher the better!
- Duration: 5–30 seconds, seamlessly loopable

### Converting with `ffmpeg`
If your source is `input.mp4`, convert to `.mov`:

HEVC (smaller file, macOS modern):
```
ffmpeg -i input.mp4 -c:v libx265 -tag:v hvc1 -crf 26 -preset medium -an output.mov
```

H.264 (broader compatibility):
```
ffmpeg -i input.mp4 -c:v libx264 -crf 20 -preset slow -an output.mov
```

(Optional) Add a slight fade to hide loop seams:
```
ffmpeg -i input.mp4 -filter_complex "fade=t=out:st=24:d=1,fade=t=in:st=0:d=1" -c:v libx264 -crf 20 -an output.mov
```

## FAQ

**Does this modify system files?**  
No. It aims to work without privileged changes.

**Can I use `.mp4`?**  
Not yet. Convert it to `.mov` using the steps above.

**Does it auto-loop?**  
Yes—macOS handles the looping once registered.

**Audio supported?**  
macOS wallpaper videos are typically silent—strip audio for best efficiency.

---

## Credits
Inspired creation by SwiftSaturday. Built with Swift and enthusiasm for customizable macOS experiences.

---

## Feedback
Have ideas or found an issue? Open an Issue or Pull Request on the repository.

Enjoy your new motion wallpaper experience!
