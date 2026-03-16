// boot.scd — SuperCollider startup for TidalCycles + Surge XT via TidalVST
// Evaluate each block with Ctrl+Enter (cursor inside the parentheses)

// --- 1. Install Quarks (run once, then skip) ---
(
Quarks.checkForUpdates({
    Quarks.install("SuperDirt", "v1.7.3");
    Quarks.install("Vowel");
    Quarks.install("https://github.com/thgrund/TidalVST");
    thisProcess.recompile();
});
)

// --- 2. Boot server + SuperDirt ---
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
    s.sync;
    "SuperDirt ready.".postln;
};
)

// --- 3. Load Surge XT via TidalVST (run after SuperDirt is ready) ---
(
SynthDef("SurgeXT", { |out, pan = 0|
    var sound = In.ar(out, ~dirt.numChannels);
    sound = VSTPlugin.ar(sound, ~dirt.numChannels, id: \surge);
    Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan))
}).add;
)

(
var synths = Dictionary[\surge -> Synth("SurgeXT", [])];
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

var vstControlBus     = ();
var vstControlBusses  = ();

var serverMessage = { |synth|
    [\out, ~out, \sustain, ~sustain].asControlInput.flop.do { |each|
        ~dirt.server.sendMsg(\s_new, synth, -1, 1,
            currentEnvironment.at(\synthGroup), *each.asOSCArgArray)
    }
};

// Register "surge" as a sound source in Tidal
~dirt.soundLibrary.addSynth(\surge, (playInside: {
    triggerFunc.value(\surge);
    serverMessage.value(\SurgeXT);
}));

~instruments = instruments;
"Surge XT registered. Use  # s \"surge\"  in Tidal.".postln;
)

// --- Preset utilities ---
// Save current patch:
// ~instruments.at(\surge).savePreset("/path/to/patches/mypatch.vstpreset");

// Load a patch:
// ~instruments.at(\surge).loadPreset("/path/to/patches/mypatch.vstpreset");

// Select factory preset by index:
// ~instruments.at(\surge).program_(0);

// List factory presets:
// ~instruments.at(\surge).info.programs.do { |name, i| (i.asString ++ ": " ++ name).postln };

// Open Surge XT GUI:
// ~instruments.at(\surge).editor;
