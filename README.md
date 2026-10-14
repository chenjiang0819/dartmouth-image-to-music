# Image to Music

An artistic MATLAB experiment that turns image structure into notes, chords and
rhythm. Chen Jiang designed and implemented this individual Dartmouth ENGS111
Digital Image Processing final project in 2023.

## Approach

Grayscale conversion and median/Gaussian filtering feed FFT, gradient and entropy
measurements. These determine major-scale frequencies, chord selection, note
duration and rhythm before waveform mixing. The original musical mapping remains
in the maintained `image_to_music` function.

## Run

Use MATLAB with Image Processing Toolbox, or Octave 7 with the image package.
In Octave, first run `pkg load image`.

```matlab
img = reshape(linspace(0,1,256),16,16);
[audio, Fs, info] = image_to_music(img,8000,4);
audiowrite('example.wav',audio,Fs);
```

The default preview grid is 16×16; the original 50×50 grid is configurable.
Sample rates range from 2000 to 192000 Hz, with a 30-million-sample allocation
cap. Playback is optional through `soundsc(audio,Fs)`.

## Checks and examples

Run `test_image_to_music`. Octave 7.3 checks passed note/chord and duration
oracles, finite audio, integer/float and RGB/grayscale inputs, invalid inputs
and WAV output. A constant 2×2 input at 8 kHz produces 11,200 samples for four
0.35-second notes. [Examples](examples) include generated image/audio output.

## 2026 maintenance

AI-assisted maintenance corrected note/chord indexing and zero-gradient/entropy
cases, handled image type ranges, bounded allocation and preallocated audio.
The pure function keeps playback, plotting and file reads separate. Selected
handwritten source remains in [historical/code.m](historical/code.m); running
that original script requires its image input and interactive MATLAB functions.
