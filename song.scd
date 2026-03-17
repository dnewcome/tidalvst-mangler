// song.scd
// Requires boot.scd to be running (SuperDirt + Surge XT loaded).
// Evaluate block 1 to define everything, then block 2 to start.

// ============================================================
// 1. DEFINE COMPONENTS, SCENES, AND ARRANGEMENT
// ============================================================
(
// All vars declared first — SC requires this
var bpb, arrange, silent;
var kick, kick2, snare, sn2, ht, ht2, oh, perc, perc2;
var bass, bass2, lead, lead2, pad, riser;
var intro1, intro2, intro3;
var verse1, verse2;
var breakdown, buildup, drop, bridge;
var outro1, outro2, outro3;

// ------------------------------------------------------------
TempoClock.default.tempo = 130/60;
bpb = 4; // beats per bar

// HELPERS
silent  = Pbind(\type, \dirt, \s, \bd, \dur, Rest(inf));

arrange = { |sections|
    Routine({
        sections.do { |sec|
            sec[1].value;
            (sec[0] * bpb).wait;
        };
        "Arrangement complete.".postln;
    });
};

// ------------------------------------------------------------
// COMPONENTS
// Drums use SuperDirt samples. Melody uses Surge XT.

kick  = Pbind(\type, \dirt, \s, \bd, \dur, 0.25, \amp, 0.9);
kick2 = Pbind(\type, \dirt, \s, \bd, \dur, Pseq([0.25, Rest(0.25), Rest(0.25), 0.25, Rest(0.25), Rest(0.25), 0.25, Rest(0.25)], inf), \amp, 0.9);
snare = Pbind(\type, \dirt, \s, \sd, \dur, Pseq([Rest(0.5), 0.5], inf), \amp, 0.8);
sn2   = Pbind(\type, \dirt, \s, \sd, \dur, Pseq([Rest(0.75), 0.25], inf), \amp, 0.75);
ht    = Pbind(\type, \dirt, \s, \hh, \dur, 0.125, \amp, 0.55);
ht2   = Pbind(\type, \dirt, \s, \hh, \dur, Pseq([0.125, Rest(0.125), 0.125, 0.125, Rest(0.125), 0.125, Rest(0.125), 0.125], inf), \amp, 0.5);
oh    = Pbind(\type, \dirt, \s, \oh, \dur, Pseq([Rest(0.75), 0.25], inf), \amp, 0.6);
perc  = Pbind(\type, \dirt, \s, \cp, \dur, Pseq([0.125, Rest(0.125), Rest(0.125), 0.125, Rest(0.125), 0.125, Rest(0.125), Rest(0.125)], inf), \amp, 0.65);
perc2 = Pbind(\type, \dirt, \s, \cp, \dur, Pseq([Rest(0.75), 0.25], inf), \amp, 0.6);

bass  = Pbind(
    \type, \dirt, \s, \surge,
    \degree, Pseq([0, \r, 4, \r, 3, \r, 1, \r], inf),
    \scale, Scale.minor, \octave, 3,
    \dur, 0.25, \sustain, 0.3, \amp, 0.8
);
bass2 = Pbind(
    \type, \dirt, \s, \surge,
    \degree, Pseq([0, \r, \r, 4, 3, \r, 1, \r], inf),
    \scale, Scale.minor, \octave, 3,
    \dur, 0.25, \sustain, 0.4, \amp, 0.8
);
lead  = Pbind(
    \type, \dirt, \s, \surge,
    \degree, Pseq([[0,4,7], \r, [5,9,12], \r], inf),
    \scale, Scale.minor, \octave, 4,
    \dur, 0.5, \sustain, 1.2, \amp, 0.7
);
lead2 = Pbind(
    \type, \dirt, \s, \surge,
    \degree, Pseq([0, \r, 4, \r, 7, \r, \r, \r], inf),
    \scale, Scale.dorian, \octave, 4,
    \dur, 0.125, \sustain, 0.2, \amp, 0.7
);
pad   = Pbind(
    \type, \dirt, \s, \surge,
    \degree, Pseq([0], inf),
    \scale, Scale.minor, \octave, 3,
    \dur, 4, \sustain, 8, \amp, 0.45
);
riser = Pbind(
    \type, \dirt, \s, \surge,
    \degree, Pseq([0], inf),
    \scale, Scale.minor, \octave, 4,
    \dur, 4, \sustain, 8, \amp, 0.5
    // automate Surge param from SC: ~instruments.at(\surge).set(0, val)
);

// ------------------------------------------------------------
// SCENES
// Each scene is a function that reassigns Pdef slots.
// Switches happen at the next bar boundary (quant set in block 2).

intro1    = {
    ">> INTRO 1: kick".postln;
    Pdef(\d1, kick);   Pdef(\d2, silent); Pdef(\d3, silent);
    Pdef(\d4, silent); Pdef(\d5, silent); Pdef(\d6, silent);
};
intro2    = {
    ">> INTRO 2: hats".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, silent);
    Pdef(\d4, silent); Pdef(\d5, silent); Pdef(\d6, silent);
};
intro3    = {
    ">> INTRO 3: perc".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, perc);
    Pdef(\d4, silent); Pdef(\d5, silent); Pdef(\d6, silent);
};

verse1    = {
    ">> VERSE 1: bass".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, perc);
    Pdef(\d4, sn2);    Pdef(\d5, bass);  Pdef(\d6, silent);
};
verse2    = {
    ">> VERSE 2: lead".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, perc);
    Pdef(\d4, sn2);    Pdef(\d5, bass);  Pdef(\d6, lead);
};

breakdown = {
    ">> BREAKDOWN".postln;
    Pdef(\d1, silent); Pdef(\d2, silent); Pdef(\d3, silent);
    Pdef(\d4, silent); Pdef(\d5, pad);   Pdef(\d6, silent);
};
buildup   = {
    ">> BUILD-UP".postln;
    Pdef(\d1, silent); Pdef(\d2, ht2);   Pdef(\d3, perc);
    Pdef(\d4, silent); Pdef(\d5, pad);   Pdef(\d6, riser);
};

drop      = {
    ">> DROP".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, oh);
    Pdef(\d4, snare);  Pdef(\d5, bass);  Pdef(\d6, lead);
};
bridge    = {
    ">> BRIDGE / DROP 2".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht2);   Pdef(\d3, oh);
    Pdef(\d4, snare);  Pdef(\d5, bass2); Pdef(\d6, lead2);
};

outro1    = {
    ">> OUTRO 1: drop lead/bass".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, perc);
    Pdef(\d4, sn2);    Pdef(\d5, silent); Pdef(\d6, silent);
};
outro2    = {
    ">> OUTRO 2: kick and hats".postln;
    Pdef(\d1, kick);   Pdef(\d2, ht);    Pdef(\d3, silent);
    Pdef(\d4, silent); Pdef(\d5, silent); Pdef(\d6, silent);
};
outro3    = {
    ">> OUTRO 3: kick alone".postln;
    Pdef(\d1, kick);   Pdef(\d2, silent); Pdef(\d3, silent);
    Pdef(\d4, silent); Pdef(\d5, silent); Pdef(\d6, silent);
};

// ------------------------------------------------------------
// ARRANGEMENT
// Edit bar counts here. Re-evaluate block 2 to restart.

~song = arrange.([
    [4,  intro1],
    [4,  intro2],
    [8,  intro3],
    [16, verse1],
    [16, verse2],
    [16, breakdown],
    [8,  buildup],
    [32, drop],
    [32, bridge],
    [8,  outro1],
    [4,  outro2],
    [4,  outro3],
]);

"Song defined. Evaluate block 2 to start.".postln;
)


// ============================================================
// 2. START
// Starts all Pdef tracks and kicks off the arrangement.
// Re-evaluate this block to restart the song from the top.
// ============================================================
(
// Point the dirt event type at our SuperDirt instance
SuperDirt.default = ~dirt;

// Quantize all Pdef switches to the bar
Pdef.defaultQuant = 4;

// Start all tracks (they begin silent until the arrangement assigns patterns)
[\d1, \d2, \d3, \d4, \d5, \d6].do { |name|
    Pdef(name, Pbind(\type, \dirt, \s, \bd, \dur, Rest(inf)));
    Pdef(name).play(TempoClock.default, quant: 4);
};

// Run the arrangement
~song.play(TempoClock.default);
"Song started.".postln;
)


// ============================================================
// LIVE CONTROLS (evaluate any line individually)
// ============================================================

// Stop everything
Pdef.all.do(_.stop); ~song.stop;

// Mute/solo a track
Pdef(\d5).pause;
Pdef(\d5).resume;

// Jump to a scene manually (takes effect at next bar)
// (just evaluate the scene variable directly)
// breakdown.value;
// drop.value;

// Change tempo
TempoClock.default.tempo = 140/60;

// Load a Surge preset before a section
// ~instruments.at(\surge).loadPreset("/path/to/patch.vstpreset");
// ~instruments.at(\surge).program_(0);
