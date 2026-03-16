// boot.scd — SuperCollider startup file for TidalCycles + VSTPlugin
// Evaluate this whole file with Ctrl+Shift+Enter, or block by block with Ctrl+Enter

// --- 1. Install Quarks (run once, then comment out) ---
(
Quarks.checkForUpdates({
    Quarks.install("SuperDirt", "v1.7.3");
    Quarks.install("https://github.com/thgrund/TidalVST");
    thisProcess.recompile();
});
)

// --- 2. Boot the audio server ---
(
s.options.numBuffers = 1024 * 256;
s.options.memSize = 8192 * 32;
s.options.numWireBufs = 128;
s.options.maxNodes = 1024 * 32;
s.options.sampleRate = 44100;
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 2;

s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles;
    ~dirt.start(57120, 0 ! 12);

    // --- 3. Load a VST instrument ---
    // Replace the path below with your actual VST3 plugin path.
    // Common locations on Linux:
    //   ~/.vst3/                  (user installs)
    //   /usr/lib/vst3/            (system installs)
    //   /usr/local/lib/vst3/
    //
    // To list available plugins, run: VSTPlugin.search(s)

    s.sync;

    ~vst_synth = {VSTPlugin.ar(nil, 2)}.play;
    ~vst_ctrl = VSTPluginController(~vst_synth);

    ~vst_ctrl.open("/path/to/your/plugin.vst3", action: { |ctrl|
        ctrl.editor; // open the plugin GUI (optional)
        ("Loaded: " ++ ctrl.info.name).postln;

        // Register with TidalVST so Tidal can address it as "myvst"
        TidalVST.addVST(\myvst, ctrl);
    });

    "SuperDirt + TidalVST ready.".postln;
};
)

// --- Preset utilities (run interactively as needed) ---

// Save current patch to file:
// ~vst_ctrl.savePreset("/path/to/patches/mypatch.vstpreset");

// Load a patch from file:
// ~vst_ctrl.loadPreset("/path/to/patches/mypatch.vstpreset");

// Select a factory preset by index:
// ~vst_ctrl.program_(0);

// List all factory preset names:
// ~vst_ctrl.info.programs.do { |name, i| (i.asString ++ ": " ++ name).postln };

// Get/set a parameter by index:
// ~vst_ctrl.get(0, { |val| val.postln });
// ~vst_ctrl.set(0, 0.75);
