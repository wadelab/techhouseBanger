# Tech House Banger

An interactive tech house track generator built in SuperCollider.

## Requirements

- SuperCollider 3.14+ (tested on macOS)

## Running

Execute the script:
```bash
/Applications/SuperCollider.app/Contents/MacOS/sclang banger.scd
```

Or open `banger.scd` in the SuperCollider IDE and evaluate it (Cmd+Enter).

## Interactive Controls

The GUI provides real-time control over:

- **Master Volume** (0-2): Overall output level
- **Bass Boost** (0-2): Amplifies sub-bass and mid-bass elements
- **Distortion Drive** (0-2): Controls saturation intensity on tonal elements
- **Filter Brightness** (0.3-2): Adjusts filter cutoff frequencies for darker/brighter sound
- **Tempo** (100-140 BPM): Real-time tempo adjustment

Use the **START** button to launch the arrangement, **STOP** to halt playback.

## Track Structure

- **Intro** (8 bars): Kick + hats
- **Build** (4 bars): Adds sub-bass, gritty bass, percussion
- **Groove** (16 bars): Full beat with claps, open hats, acid lead
- **Breakdown** (8 bars): Stripped back with pads and stabs
- **Riser** (4 bars): Builds tension before the drop
- **Drop** (32 bars): Everything back at full intensity
- **Outro** (8 bars): Gradual fadeout

Total duration: ~4.5 minutes at 126 BPM

## Tips

- Crank the distortion and bass boost during the drop for maximum impact
- Lower the filter brightness during the breakdown for atmosphere
- Adjust tempo in real-time to match energy levels

## License

MIT
