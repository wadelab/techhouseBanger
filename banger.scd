// ABSOLUTE TECH HOUSE BANGER
GUI.qt; // Use the stehtascope thingy to look a tthe waveform

(
s.waitForBoot({ // wait for server to boot - boot the server from scratch each time? Not sure what happens if you run this from the IDE and not VSCODE
    var root = 45; // A1
    var win, masterVol, bassBoost, driveKnob, tempoSlider, filterKnob;
    
    // Global control busses
    ~masterAmp = Bus.control(s, 1).set(1.0);
    ~bassAmp = Bus.control(s, 1).set(1.0);
    ~distAmt = Bus.control(s, 1).set(1.0);
    ~filterFreq = Bus.control(s, 1).set(1.0);

    s.scope(2); // pop up the oscilloscope
    s.meter;

    ~clock = TempoClock.new(126/60); // 126 BPM to start...

    // FAT KICK with pitch drop
    SynthDef(\fatKick, { |out=0, amp=2.0|
        var env = Env.perc(0.001, 0.4, amp, -8).ar(doneAction:2);
        var freqEnv = Env.perc(0, 0.3, 80, -4).ar;
        var sub = SinOsc.ar(43 + freqEnv, 0, env * 1.5);
        var body = SinOsc.ar(58 + (freqEnv*0.5), 0, env * 0.8);
        var click = HPF.ar(WhiteNoise.ar * Env.perc(0, 0.01, amp*0.6).ar, 4000);
        Out.ar(out, (sub + body + click)!2);
    }).add;

    // HARD CLAP
    SynthDef(\hardClap, { |out=0, amp=0.85|
        var n = WhiteNoise.ar;
        var env1 = Env.perc(0.001, 0.06).ar;
        var env2 = Env.perc(0.008, 0.25).ar;
        var body = BPF.ar(n * env1, 2000, 0.4);
        var tail = BPF.ar(n * env2, 1600, 0.35);
        var sig = (body + tail) * amp;
        Out.ar(out, sig!2);
    }).add;

    // TIGHT HATS
    SynthDef(\hat, { |out=0, amp=0.25, tone=9500|
        var env = Env.perc(0.001, 0.08).ar(doneAction:2);
        var sig = HPF.ar(BPF.ar(WhiteNoise.ar, tone, 0.4), 7000) * env * amp;
        Out.ar(out, sig!2);
    }).add;

    // OPEN HAT
    SynthDef(\openHat, { |out=0, amp=0.22|
        var env = Env.perc(0.001, 0.4).ar(doneAction:2);
        var sig = HPF.ar(BPF.ar(WhiteNoise.ar, 10000, 0.35), 6500) * env * amp;
        Out.ar(out, sig!2);
    }).add;

    // PERCUSSION
    SynthDef(\perc, { |out=0, amp=0.5, freq=800|
        var env = Env.perc(0.001, 0.08).ar(doneAction:2);
        var sig = SinOsc.ar(freq, 0, env * 0.4) + (WhiteNoise.ar * env * 0.6);
        Out.ar(out, HPF.ar(sig, 600) * amp!2);
    }).add;

    // MASSIVE SUB BASS
    SynthDef(\sub, { |out=0, freq=55, amp=1|
        var env = Env.perc(0.01, 0.8).ar(doneAction:2);
        var bassBoost = In.kr(~bassAmp); // Remember that bassAmp comes from the control!
        var masterVol = In.kr(~masterAmp);
        var sig = SinOsc.ar(freq, 0, env * amp * bassBoost * masterVol);
        Out.ar(out, sig!2);
    }).add;

    // GRITTY BASS with distortion
    SynthDef(\grittyBass, { |out=0, freq=110, amp=0.75, cutoff=2500, res=0.28|
        var env = Env.perc(0.003, 0.35).ar(doneAction:2);
        var bassBoost = In.kr(~bassAmp);
        var distAmt = In.kr(~distAmt); // And the distortion also comes fro mthe controller
        var filterMod = In.kr(~filterFreq);
        var masterVol = In.kr(~masterAmp);
        var sig = Saw.ar([freq, freq*1.005], 0.9).sum;
        sig = RLPF.ar(sig, cutoff * filterMod, res);
        sig = (sig * (4.0 * distAmt)).tanh; // much harder distortion
        sig = sig * env * amp * bassBoost * masterVol;
        Out.ar(out, sig!2);
    }).add;

    // ACID-STYLE LEAD
    SynthDef(\acid, { |out=0, freq=220, amp=0.3, cutoff=1000, res=0.15|
        var env = Env.perc(0.01, 0.25).ar(doneAction:2);
        var distAmt = In.kr(~distAmt);
        var filterMod = In.kr(~filterFreq);
        var masterVol = In.kr(~masterAmp);
        var sig = Saw.ar(freq, 0.6);
        sig = RLPF.ar(sig, cutoff * env * 3 * filterMod + 300, res);
        sig = (sig * (3.5 * distAmt)).tanh; // add distortion
        sig = sig * env * amp * masterVol;
        Out.ar(out, sig!2);
    }).add;

    // STAB CHORD
    SynthDef(\stab, { |out=0, freq=440, amp=0.22|
        var env = Env.perc(0.01, 0.5).ar(doneAction:2);
        var distAmt = In.kr(~distAmt);
        var masterVol = In.kr(~masterAmp);
        var sig = Saw.ar([freq, freq*1.25, freq*1.5, freq*2], 0.3).sum;
        sig = RLPF.ar(sig, freq*3, 0.2);
        sig = (sig * (3.0 * distAmt)).tanh; // add distortion
        sig = sig * env * amp * masterVol;
        Out.ar(out, sig!2);
    }).add;

    // RISER
    SynthDef(\riser, { |out=0, amp=0.3, dur=8|
        var env = Env.linen(0.1, dur-0.2, 0.1).ar(doneAction:2);
        var freqEnv = Env([200, 8000], [dur], \exp).ar;
        var sig = WhiteNoise.ar * BPF.ar(WhiteNoise.ar, freqEnv, 0.1);
        Out.ar(out, sig * env * amp!2);
    }).add;

    // PAD
    SynthDef(\pad, { |out=0, freq=220, amp=0.15|
        var env = Env.linen(1, 3, 1).ar(doneAction:2);
        var sig = Pulse.ar([freq, freq*1.005, freq*0.995], 0.5).sum * 0.3;
        sig = RLPF.ar(sig, freq*2.5, 0.25);
        sig = (sig * 1.8).tanh; // add soft saturation. tanh seems to be used a lot in supercollider - it's a function that looks a lot like a saturating sigmoid: shallow, then a steep bit, then a saturation part...
        Out.ar(out, sig * env * amp!2);
    }).add;

    s.sync;

    // PATTERNS
    Pdef(\kick, Pbind(\instrument, \fatKick, \dur, 1));
    
    Pdef(\clap, Pbind(\instrument, \hardClap, 
        \dur, Pseq([Rest(1),1,Rest(1),1], inf), \amp, 0.85));
    
    Pdef(\hat, Pbind(\instrument, \hat, 
        \dur, 0.25, 
        \amp, Pseq([0.3,0.2,0.28,0.2], inf),
        \tone, Pseq([9500,9000,9500,9000], inf)));
    
    Pdef(\openHat, Pbind(\instrument, \openHat, 
        \dur, Pseq([Rest(0.5),0.5], inf), \amp, 0.22));
    
    Pdef(\perc, Pbind(\instrument, \perc, 
        \dur, Pseq([Rest(0.75),0.25], inf), 
        \freq, Pseq([1200,1800,1500,1600], inf),
        \amp, 0.45));

    Pdef(\sub, Pbind(\instrument, \sub,
        \dur, 1,
        \freq, Pseq((root + [0,0,0,0]).midicps, inf),
        \amp, 0.85));

    Pdef(\bass, Pbind(\instrument, \grittyBass,
        \dur, Pseq([0.25,0.25,0.5,0.25,0.25,0.5], inf),
        \freq, Pseq((root + [0,12,7,0,12,5]).midicps, inf),
        \cutoff, Pseq([2400,2800,3000,2600,2900,2700], inf),
        \amp, 0.45));

    Pdef(\acid, Pbind(\instrument, \acid,
        \dur, Pseq([0.25,0.25,0.25,0.25]*4, inf), // Slow down the 'tune' here
        \freq, Pseq((root + [0,1,-1,-13,-3,-3,-3,-3]).midicps, inf), // Root is the base note for the midi sequence.
        \cutoff, Pseq([1600,2000,2200,1800,2100,1700,2300,2000], inf),
        \amp, 0.62));

    Pdef(\stab, Pbind(\instrument, \stab,
        \dur, Pseq([Rest(2),1,Rest(1)], inf),
        \freq, Pseq((root + [24,31,36]).midicps, inf),
        \amp, 0.22));

    Pdef(\pad, Pbind(\instrument, \pad,
        \dur, 4,
        \freq, Pseq((root + [12,17,19,15]).midicps, inf),
        \amp, 0.15));

    Pdef(\closeEncounters, Pbind(\instrument, \acid,
        \dur, 1,
        \freq, Pseq([62, 64, 60, 48, 55,55,55,55].midicps, inf),
        \cutoff, 2000,
        \amp, 0.85));

    // ARRANGEMENT
    ~start = {
        var beatTime = ~clock.beats;
        
        // INTRO: kick + hats + Close Encounters theme (8 bars)
        Pdef(\kick).play(~clock, quant:1);
        Pdef(\hat).play(~clock, quant:1);
        Pdef(\closeEncounters).play(~clock, quant:1);

        // BUILD: add sub, bass, perc (4 bars)
        ~clock.schedAbs(beatTime + 32, {
            Pdef(\sub).play(~clock, quant:1);
            Pdef(\bass).play(~clock, quant:1);
            Pdef(\perc).play(~clock, quant:1);
        });

        // GROOVE: full beat (16 bars)
        ~clock.schedAbs(beatTime + 48, {
            Pdef(\clap).play(~clock, quant:1);
            Pdef(\openHat).play(~clock, quant:1);
            Pdef(\acid).play(~clock, quant:1);
            // closeEncounters already playing
        });

        // BREAKDOWN: drop bass/clap, add pad (8 bars) - keep Close Encounters!
        ~clock.schedAbs(beatTime + 112, {
            [\sub,\bass,\clap,\acid].do({ |n| Pdef(n).stop });
            Pdef(\pad).play(~clock, quant:1);
            Pdef(\stab).play(~clock, quant:1);
        });

        // RISER before drop (last 4 bars of breakdown)
        ~clock.schedAbs(beatTime + 128, {
            Synth(\riser, [\dur, 16 * (60/126)]); // 4 bars
        });

        // DROP: everything back HARD (32 bars) - wait do we ever get to this?
        ~clock.schedAbs(beatTime + 144, {
            Pdef(\sub).play(~clock, quant:1);
            Pdef(\bass).play(~clock, quant:1);
            Pdef(\clap).play(~clock, quant:1);
            Pdef(\acid).play(~clock, quant:1);
            // closeEncounters already playing
            Pdef(\stab).play(~clock, quant:1);
        });

        // OUTRO: strip down (8 bars)
        ~clock.schedAbs(beatTime + 272, {
            [\sub,\bass,\clap,\acid,\closeEncounters,\stab,\openHat,\perc].do({ |n| Pdef(n).stop });
            Pdef(\pad).play(~clock, quant:1);
        });

        // END
        ~clock.schedAbs(beatTime + 304, {
            [\kick,\hat,\pad].do({ |n| Pdef(n).stop });
        });
    };

    ~stop = {
        [\kick,\clap,\hat,\openHat,\perc,\sub,\bass,\acid,\closeEncounters,\stab,\pad].do({ |n| Pdef(n).stop });
    };

    // CREATE GUI
    win = Window("Tech House Control", Rect(100, 100, 400, 300)).front;
    win.view.decorator = FlowLayout(win.view.bounds);
    
    StaticText(win, 380@20).string_("TECH HOUSE BANGER CONTROLS").align_(\center);
    win.view.decorator.nextLine;
    
    // Master Volume
    masterVol = EZSlider(win, 380@40, "Master Volume", ControlSpec(0, 2, \lin, 0.01, 1),
        action: { |ez| ~masterAmp.set(ez.value); },
        labelWidth: 120, numberWidth: 60);
    win.view.decorator.nextLine;
    
    // Bass Boost
    bassBoost = EZSlider(win, 380@40, "Bass Boost", ControlSpec(0, 4, \lin, 0.01, 1),
        action: { |ez| ~bassAmp.set(ez.value); },
        labelWidth: 120, numberWidth: 60);
    win.view.decorator.nextLine;
    
    // Distortion Drive
    driveKnob = EZSlider(win, 380@40, "Distortion Drive", ControlSpec(0, 4, \lin, 0.01, 1),
        action: { |ez| ~distAmt.set(ez.value); },
        labelWidth: 120, numberWidth: 60);
    win.view.decorator.nextLine;
    
    // Filter Frequency
    filterKnob = EZSlider(win, 380@40, "Filter Brightness", ControlSpec(0.3, 2, \lin, 0.01, 1),
        action: { |ez| ~filterFreq.set(ez.value); },
        labelWidth: 120, numberWidth: 60);
    win.view.decorator.nextLine;
    
    // Tempo Control
    tempoSlider = EZSlider(win, 380@40, "Tempo (BPM)", ControlSpec(100, 140, \lin, 1, 126),
        action: { |ez| ~clock.tempo_(ez.value / 60); },
        labelWidth: 120, numberWidth: 60);
    win.view.decorator.nextLine;
    
    win.view.decorator.nextLine;
    Button(win, 180@30)
        .states_([["START", Color.black, Color.green]])
        .action_({ ~start.(); });
    
    Button(win, 180@30)
        .states_([["STOP", Color.white, Color.red]])
        .action_({ ~stop.(); });

    ~start.();
});
)
