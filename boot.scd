// boot.scd
// Single-block startup. Copy contents to ~/.config/SuperCollider/startup.scd
// and it will run automatically every time SC starts.
//
// First-time quark install: evaluate the block below ONCE, then remove it
// (or leave it — Quarks.install is idempotent).
//
// --- FIRST TIME ONLY: Install quarks (comment out after first run) ---
(
Quarks.checkForUpdates({
    Quarks.install("SuperDirt", "v1.7.3");
    Quarks.install("Dirt-Samples");
    Quarks.install("Vowel");
    Quarks.install("https://github.com/thgrund/TidalVST");
    thisProcess.recompile();
});
)
// sc3-plugins: sudo apt install sc3-plugins

(
s.options.numBuffers    = 1024 * 256;
s.options.memSize       = 8192 * 32;
s.options.numWireBufs   = 128;
s.options.maxNodes      = 1024 * 32;
s.options.sampleRate    = 44100;
s.options.numInputBusChannels  = 2;
s.options.numOutputBusChannels = 2;

s.waitForBoot {
    // --- SuperDirt ---
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles;
    ~dirt.start(57120, 0 ! 12);
    SuperDirt.default = ~dirt;
    s.sync;
    "SuperDirt ready.".postln;

    // --- Surge XT SynthDef ---
    SynthDef("SurgeXT", { |out, pan = 0|
        var sound = In.ar(out, ~dirt.numChannels);
        sound = VSTPlugin.ar(sound, ~dirt.numChannels, id: \surge);
        Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan))
    }).add;
    s.sync;

    // --- Surge XT instance + TidalVST wiring ---
    var vstControlBus    = ();
    var vstControlBusses = ();

    var synths      = Dictionary[\surge -> Synth("SurgeXT", [])];
    var instruments = Dictionary[
        \surge -> VSTPluginController(synths.at(\surge), id: \surge)
                      .open("Surge XT.vst3", editor: true, verbose: true)
    ];

    var triggerFunc = { |vstName|
        var oldBusses = Set[];
        var newBusses = Set[];
        var busId;
        var lag      = ~lag + (~latency ? 0);
        var sustain  = ~sustain = ~sustain.value;
        var note     = (~freq.value.cpsmidi).round(1).asInteger;
        var velocity = (~amp.value * (~gain.min(2) + ~overgain).pow(4))
                           .linlin(0, 1, 0, 127).asInteger;
        var instrument = instruments[vstName];

        synths.at(vstName).set(\out, ~out, \pan, currentEnvironment.at(\pan));

        ~dirt.server.makeBundle(~latency, {
            currentEnvironment.keysDo { |key|
                if (key.asString.contains("varg"), {
                    busId = currentEnvironment.at(key);
                    if (busId.asString.contains("c"), {
                        if (vstControlBusses.at(busId).isNil, {
                            vstControlBusses.put(busId, Set[]);
                        });
                        vstControlBusses.at(busId).add(vstName);
                        vstControlBus.put(currentEnvironment.at(key),
                            key.asString.replace("varg", ""));
                        newBusses.add(currentEnvironment.at(key));
                    }, {
                        instrument.set(
                            key.asString.replace("varg", "").asInteger,
                            currentEnvironment.at(key));
                    });
                });
                vstControlBusses.keysDo { |bus|
                    if (vstControlBusses.at(bus).includes(vstName), {
                        oldBusses.add(bus)
                    });
                };
            };
            (newBusses -- oldBusses).do { |deleteBus|
                vstControlBusses.at(deleteBus).remove(vstName);
            };
        });

        thisThread.clock.sched(lag,           { instruments[vstName].midi.noteOn(0, note, velocity) });
        thisThread.clock.sched(sustain + lag,  { instruments[vstName].midi.noteOff(0, note, velocity) });
    };

    var serverMessage = { |synth|
        [\out, ~out, \sustain, ~sustain].asControlInput.flop.do { |each|
            ~dirt.server.sendMsg(\s_new, synth, -1, 1,
                currentEnvironment.at(\synthGroup), *each.asOSCArgArray)
        }
    };

    ~dirt.soundLibrary.addSynth(\surge, (playInside: {
        triggerFunc.value(\surge);
        serverMessage.value(\SurgeXT);
    }));

    ~instruments = instruments;
    "Surge XT registered.".postln;
    "Boot complete. Open song.scd to play.".postln;
};
)

// --- Preset utilities (evaluate individually as needed) ---
// ~instruments.at(\surge).savePreset("/path/to/patch.vstpreset");
// ~instruments.at(\surge).loadPreset("/path/to/patch.vstpreset");
// ~instruments.at(\surge).program_(0);
// ~instruments.at(\surge).info.programs.do { |name, i| (i.asString ++ ": " ++ name).postln };
// ~instruments.at(\surge).editor;
