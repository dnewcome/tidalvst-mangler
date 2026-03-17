# algo-music

TidalCycles setup with VST instrument support via VSTPlugin + TidalVST, running Surge XT on Ubuntu.

## Stack

- **TidalCycles** — pattern/live coding language (Haskell)
- **SuperCollider + SuperDirt** — audio engine
- **VSTPlugin** (SC extension) — VST3 host inside SuperCollider
- **TidalVST** (SC quark) — bridges Tidal patterns to VST instruments
- **Surge XT** — open source VST3 synthesizer

## Installation

Run the setup script (Ubuntu only, tested on 25.10):

```bash
./setup.sh
```

This installs:
1. SuperCollider + sc3-plugins + pipewire-jack
2. GHC + Cabal via ghcup
3. TidalCycles
4. Surge XT 1.3.4 (from official .deb)
5. VSTPlugin 0.6.2 (built from source — no prebuilt binaries exist)

### Real-time audio priority (do once)

Allow SC to request real-time scheduling — without this you may get audio glitches:

```bash
sudo usermod -a -G audio $USER
```

Log out and back in for the change to take effect.

### VSTPlugin build notes

VSTPlugin has no prebuilt Linux binaries. The script clones the source and the
VST3 SDK separately and builds with cmake. Key flags used:

- `-DVST2=OFF` — VST2 SDK is no longer distributed by Steinberg
- `-DSUPERNOVA=OFF` — supernova build requires `nova-tt` headers not in apt
- VST3 SDK must be cloned into `vst/VST_SDK/VST3_SDK/` inside the source tree

When opening plugins, the `.vst3` extension must be included in the name passed
to `VSTPluginController.open()`, otherwise VSTPlugin mistakes the inner `.so`
for a VST2 plugin and refuses to load it.

## First-time SuperCollider setup

Open `boot.scd` and evaluate the commented-out quark install block once:

```supercollider
Quarks.checkForUpdates({
    Quarks.install("SuperDirt", "v1.7.3");
    ...
});
```

SC will recompile. After that, skip this block — quarks persist across sessions.

## VS Code setup

Install the SuperCollider extension by `scztt` from the VS Code marketplace,
and the TidalCycles extension:

```bash
code --install-extension tidalcycles.vscode-tidalcycles
```

In Settings (Ctrl+,), set:
- `tidalcycles.bootTidalPath` → path to `BootTidal.hs` in this repo
- `tidalcycles.ghciPath` → `/home/dan/.ghcup/bin/ghci`

## Every session

```bash
./run.sh
```

This starts `sclang` with `boot.scd` via PipeWire and opens VS Code.
Watch the SC output panel for:
```
Boot complete. Open song.scd to play.
```

## Tidal patterns

Use `# s "surge"` to target Surge XT:

```haskell
-- Simple melody
d1 $ n "0 3 7 5" # s "surge" # sustain 0.4

-- Scale-mapped notes
d1 $ n (scale "minor" "0 2 4 6") # s "surge" # sustain 0.3

-- Control VST parameters by index (varg1 = param 0, varg2 = param 1, ...)
d1 $ n "0 3 7" # s "surge" # varg1 "0.2 0.5 0.8"

-- Slow parameter sweep
d1 $ n "0" # s "surge" # legato 4 # varg1 (slow 4 $ range 0.1 0.9 sine)
```

To find parameter indices, run in SC:
```supercollider
~instruments.at(\surge).info.parameters.do { |p, i| (i.asString ++ ": " ++ p.name).postln };
```

## Preset management

From the SC IDE:

```supercollider
// Save current patch
~instruments.at(\surge).savePreset("/path/to/patches/mypatch.vstpreset");

// Load a patch
~instruments.at(\surge).loadPreset("/path/to/patches/mypatch.vstpreset");

// Select factory preset by index
~instruments.at(\surge).program_(0);

// List all factory presets
~instruments.at(\surge).info.programs.do { |name, i| (i.asString ++ ": " ++ name).postln };
```

## Adding more VST plugins

1. In `boot.scd`, duplicate the SynthDef block with a new name and `id`
2. Add an entry to the `synths` and `instruments` dictionaries
3. Add a `~dirt.soundLibrary.addSynth(\yourname, ...)` call
4. Use `# s "yourname"` in Tidal

VST3 plugins are searched in:
- `~/.vst3/`
- `/usr/lib/vst3/`
- `/usr/local/lib/vst3/`
