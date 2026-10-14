# Image to Music

## Overview
An artistic image-to-music experiment: grayscale → median/Gaussian filtering → FFT, gradient and entropy → notes/chords/rhythm → synthesized audio.

## Academic Context
University: Dartmouth College, Thayer School of Engineering  
Course: ENGS111 Digital Image Processing  
Year: 2023 (project report dated May 28)  
Project type: Individual final project

## My Contribution
Chen Jiang designed and implemented the image-processing and musical mapping experiment in MATLAB, including note/chord generation, gradient-based duration, entropy-based rhythm and waveform mixing.

## Original Implementation
`historical/code.m` preserves the selected handwritten source byte-for-byte. The supplied original audio, report and live script are retained privately; the historical photo and huge generated MAT file were not acquired or bundled. The public historical selection omits those files and is not the complete original project.

## Technical Approach
The original major-scale frequency selection and FFT/gradient/entropy concept are retained. This is an artistic mapping, not a validated measure of personality or musical quality.

## Build / Run
MATLAB with Image Processing Toolbox, or Octave 7 with its image package. In Octave first run `pkg load image`.

```matlab
img = reshape(linspace(0,1,256),16,16); % original synthetic fixture
[audio, Fs, info] = image_to_music(img,8000,4);
audiowrite('example.wav',audio,Fs);
```

Default preview grid is 16×16; the historical 50×50 grid remains configurable; use a smaller grid for shorter output. Sample rate must be 2000–192000 Hz. A 30-million-sample cap bounds allocation. Playback is opt-in via `soundsc(audio,Fs)`.

## Verification / Testing
Run `test_image_to_music`. Octave 7.3 with image 2.14 passed note/chord oracles, sample-count checks, finite audio, integer/float/RGB/grayscale input, invalid input and WAV output. Synthetic sample generation is tested; original MATLAB GUI/playback and spectrogram were NOT VERIFIED.

## 2026 AI-Assisted Maintenance
Corrected zero-based modulo mapping and chord offsets, guarded constant-gradient/zero-entropy/zero-peak cases, scaled integer images by type range, accepted grayscale input, bounded sample allocation and replaced repeated concatenation with preallocation. Playback, figure creation and filesystem reads are outside the maintained pure function. The Gaussian kernel is explicit for MATLAB/Octave portability. Small-image filtering was repaired after an actual Octave regression failure.

## Known Limitations
The maintained function is verified in Octave, not native MATLAB. The original script needs the omitted input photo and interactive MATLAB functions; its Octave baseline stopped in headless plotting. Synthetic images/audio replace historical media. No subjective musical-quality evaluation is claimed.

## Attribution
Original project: Chen Jiang. MATLAB/Octave image-processing libraries. No instructor assignment, photo, report or third-party recording is redistributed.

## Original Snapshot
`archive/public-original-sanitized` contains a selected historical snapshot, NOT a byte-identical copy of the full project. Exact acquired-source hashes and local Git originals remain private. Maintenance is on `ai/project-hardening` and explicitly dated 2026.
