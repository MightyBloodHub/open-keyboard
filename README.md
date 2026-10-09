# ⌨️ Open Keyboard

**Build your own playable keyboard from sounds you record. It runs in your browser and everything stays on your computer.**

Record a sound for each key (your voice, a glass, a guitar string, anything), name the key and give it a computer key. The sound keeps playing for as long as you hold the key. Open Keyboard works out which musical note each key is, and it can even help you play well-known melodies with the sounds you made.

It's a single HTML file with no dependencies, no build step, no account and no server: no data or audio ever leaves your machine.

> Screenshots live in [`docs/screenshots/`](docs/screenshots/). They may not be in the repository yet; see *Contributing*.

---

## Features

- 🎙️ **Record a sound for every key.** Press Record, wait for the 3-2-1 countdown, play when you see **PLAY NOW**, then press **Stop**. Silence at the start and end is cut off and the volume is evened out for you. A level meter shows the mic input and warns you when it hears nothing.
- 🔁 **Sound lasts as long as you hold the key.** Each recording plays its start once, then loops its middle with a smooth crossfade while the key is held, and fades out quickly when you let go. You can play several keys at once.
- ✂️ **Sound editor.** View the waveform, trim the start and end, select a part and cut it or keep only it, move the loop points, change the volume, zoom in, undo as many steps as you like, and go back to the original recording at any time.
- ⌨️ **Bind any computer key.** Letters, numbers, punctuation, arrows, Space, Enter and F-keys. Bindings follow the physical key (`event.code`), so other keyboard layouts work. If a key is already used, you can swap or move it.
- 🗂️ **Many keyboards, saved automatically.** Your keyboard library supports New, Open, Rename, Duplicate (copies the recordings too) and Delete. Every change is saved straight away, and the app reopens the keyboard you used last.
- 📦 **Export and import.** Save a keyboard as one `.json` file that includes the audio, and share it.
- 🎼 **Finds the note of each key.** Each key gets a badge such as `♪ E4 +2¢` with a small tuner, and drums or noise show *no pitch*. You can set a note yourself, sort keys by pitch, and change the A4 tuning reference.
- 🎵 **Melodies (experimental).** 15 traditional and public-domain tunes are ranked by how well your keys can play them. Choose **Auto-play** or **Practice** (the next key lights up and wrong presses are counted). Turn on **Exact pitch** to speed up or slow down your sounds so every note is right, or type your own melody (`C4 D4 E4:2 R G4`).
- 🩺 **Built-in audio check.** The bottom bar shows the audio status and output level, with **Test speaker** and **Restart audio** buttons.

## Quick start

You only need Python 3 (it already comes with macOS Command Line Tools and most Linux systems) and a modern browser.

**macOS:** double-click **`Keyboard Builder.command`** (or run `./start.sh`).
**Linux:** `./start.sh`
**Windows:** double-click **`start.bat`**

**Any system, by hand:**

```bash
python3 -m http.server 8765 -d app
# then open http://localhost:8765
```

Then **allow the microphone** when your browser asks.

Notes:
- **The microphone needs `localhost` (or https).** Opening `index.html` directly as a file won't record in most browsers.
- **Keep the port at 8765.** The browser saves your keyboards for one exact address, so a different port means an empty app (your data on 8765 is still there).
- **Downloaded from GitHub?** You may need to make the launchers executable: `chmod +x start.sh "Keyboard Builder.command"`.
- **macOS blocks the launcher the first time?** Right-click it, choose **Open**, then **Open** again.

## How to use

1. **Build tab:** add keys, give them names, press **● Record** for each one, and use **⌨ Bind key** to choose the computer key that plays it. Open **✂ Edit sound** to trim the sound or change its loop.
2. **Play tab:** hold the keys with the mouse, touch or your computer keyboard.
3. **Melodies tab:** pick a tune, then **▶ Auto-play** to hear it or **🎯 Practice** to play it yourself.
4. **◀ Keyboards:** manage your saved keyboards, and export or import them.

## How it works

| Part | Technique |
|---|---|
| Recording | `getUserMedia` → **AudioWorklet** that captures the raw audio (falls back to `ScriptProcessorNode`), recording at the same time with **MediaRecorder** as a backup in case the main capture comes back silent |
| Clean-up | Cuts off silence using a level set from the recording's own peak and background noise, then evens out the volume |
| Sustain | Finds the steady part of the sound (just after the attack, before it fades below about 30% of peak). Bakes an **equal-power crossfade** into the loop end, then loops it with `AudioBufferSourceNode` (`loop`, `loopStart`/`loopEnd`) and a short fade on release |
| Note detection | **YIN** pitch detection (cumulative-mean-normalised difference) on about 46 ms slices of a down-sampled copy. It refines between samples, skips silent slices and unclear ones (clarity < 0.75), picks the semitone most slices agree on (louder, clearer slices count more), and checks for octave mistakes. The result is the middle value of that group, in Hz, cents and confidence |
| Melody mapping | Tries every transposition. Each note is matched to a key, preferring an exact semitone, then the same note in another octave, then the nearest note. Notes are scored by length to give the match %. *Exact pitch* adjusts `playbackRate` to hit each target note |
| Storage | **IndexedDB** (stores: `keyboards`, `keys`, `audio`, `meta`). The original recordings are kept alongside your edits, so **Reset to original** always works |

## Browser support

Tested with recent **Chrome** and **WebKit/Safari** (automated headless tests, including the Safari engine) and designed for current Firefox/Edge. It needs Web Audio, IndexedDB and `getUserMedia`, and AudioWorklet is used when available.

## Privacy

Everything runs on your computer. Recordings, keyboards and settings are stored in your browser's IndexedDB for `http://localhost:8765`. Nothing is uploaded, and there are no analytics and no network requests apart from loading the page itself.

## Troubleshooting

- **Can't hear anything:** press **🔊 Test speaker** in the bottom bar.
  - **No beep:** check your system volume, the output device, and whether the browser tab is muted, then press **↻ Restart audio**.
- **"No sound detected" or "Mic peak level: silence":** turn on the microphone for your browser.
  - **macOS:** System Settings → Privacy & Security → Microphone.
  - **All systems:** check the input device and its level in your system's sound settings.
- **My keyboards disappeared:** you probably opened a different port or browser. Go back to `http://localhost:8765` in the same browser.
- **A note is wrong:** click the ♪ badge and choose the correct note, or edit the sound so only its steady part is left.

## Project structure

```
app/index.html               The whole app (HTML + CSS + JS, no dependencies)
Keyboard Builder.command     macOS double-click launcher
start.sh                     macOS / Linux launcher
start.bat                    Windows launcher
docs/screenshots/            Screenshots
```

Internal names such as the IndexedDB database `keyboard-builder` and the export format id stay the same on purpose, so existing saved keyboards and exported files keep working.

## Contributing

Issues and pull requests are welcome. There's no build step: edit `app/index.html`, run a launcher, and reload the page. Please keep the app dependency-free and fully local. Good first contributions:
- add screenshots to `docs/screenshots/`
- add more public-domain melodies to the `MELODIES` list (format `NOTE:beats`)
- improve pitch detection for tricky sounds

## License

[MIT](LICENSE) © 2026 MightyBloodHub
