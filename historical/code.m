clear;
clf;
close;
%%
% Load an image
img = imread('tangyuan1.jpg');
imshow(img);
title('Original Image');
% Convert image to grayscale
gray = rgb2gray(img);
figure; 
imshow(gray);
title('Grayscale Image');
% Denoise the image
denoised = medfilt2(gray);
figure; imshow(denoised);
title('Denoised Image');
% Smooth the image
smoothed = imgaussfilt(denoised, 2);
smoothed = double(smoothed);
figure; imshow(smoothed, []);
title('Smoothed Image');
% Resize the image
img_processing = imresize(smoothed, [50, 50]);
img_processed = img_processing/255;
% Create a figure and display the processed image
figure; 
imshow(img_processed, []);
title('Processed 50×50 Image');
% Adjust the display size to 300x300 pixels
truesize(gcf, [300 300]);
% Calculate the Fourier Transform
F = fft2(double(img_processed));

% Create a figure for Fourier Transform and display it
figure; 
imshow(log(1 + abs(F)), []);
title('Fourier Transform');
% Adjust the display size to 300x300 pixels
truesize(gcf, [300 300]);
% Get the absolute value - this corresponds to the magnitude of the frequencies
F = abs(F);
% Convert to a vector
F = F(:);
% Base frequencies for two octaves
frequencies = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25, 587.33, 659.25, 698.46, 739.99, 783.99, 830.61, 880.00, 932.33];
frequencies = frequencies / 2;
% Only use the frequencies in the Major scale to avoid dissonant half tones
frequencies = frequencies([1, 3, 5, 6, 8, 10, 12, 13]); 

%%
% Generate the note
note = (mod(F .* img_processed(:)*100, 14) + 1);  % Ensure note values are between 1 and 14
% Scale the note to be within 1 to 8 (corresponding to the number of base frequencies)
note = 1 + mod(floor(note), 8);

% Create a mapping from generated notes to actual notes
note_mapping = [1, 3, 5, 6, 8, 10, 12, 13];
% Map the generated notes to actual notes
note_actual = note_mapping(note);

% Create the histogram
bin_edges = [note_mapping, note_mapping(end)+1];
histogram_data = histcounts(note_actual, bin_edges);
figure;
bar(note_mapping, histogram_data);
xlabel('Note');
ylabel('Frequency');
title('Note Distribution');
[dx, dy] = gradient(img_processed);
% Compute the magnitude of the gradient
grad = sqrt(dx.^2 + dy.^2);
% Normalize the gradient to the range [0.5, 2]
grad = normalize(grad(:), 'range', [0.5 2]);

figure; 
imshow(dx, []);
title('Gradient Magnitude of the Image');
% Adjust the display size to 300x300 pixels
truesize(gcf, [300 300]);
imshow(dy, []);
title('Gradient Direction of the Image');
% Adjust the display size to 300x300 pixels
truesize(gcf, [300 300]);
%%
% Calculate lengths based on gradient magnitude
baseSpeed = 2; % Parameter for adjusting the base speed, smaller value makes the music faster
lengths = baseSpeed*0.1 + grad; 

% Determine the rhythm
entropyValue = entropy(img);
% Convert the entropy to a rhythm value
rhythm = abs(1 / entropyValue);
% Scale rhythm to between 1 and 2
rhythm = min(max(1, rhythm), 2);

% Generate a time vector for 60 seconds
Fs = 44100;
t = 0:1/(Fs*2):60/rhythm;

% Initialise the arrays
music = [];
music_chord = [];
music_mix = [];

for i = 1:length(note)
    % Select the appropriate chord based on the note frequency
    % A chord is a set of notes that are played simultaneously.
    chord_freqs = [frequencies(note(i)), frequencies(mod(note(i)+2,8)+1), frequencies(mod(note(i)+4,8)+1)];
    % Play all notes in the chord at once for the total length
    % This is creating a time series. The total length of a note is determined by lengths(i)/rhythm.
    t = 0:1/Fs:lengths(i)/rhythm;
    chord = zeros(size(t));
    for j = 1:length(chord_freqs)
        % Add the note to the chord
        % The sin function is used to generate a sine wave, which is a good approximation for a pure tone.
        % chord_freqs(j) gives the frequency of the note, and t is the time series.
        % Thus, sin(2*pi*chord_freqs(j)*t) generates a sine wave of frequency chord_freqs(j), representing a note.
        chord = chord + sin(2*pi*chord_freqs(j)*t);
    end
    % Concatenate to the music chord
    % Each chord is then added to the music sequence. This creates the effect of multiple notes being played at the same time.
    music_chord = [music_chord, chord];

    % Then play each note in the chord for a fraction of the total length
    chord_length = lengths(i)/rhythm / length(chord_freqs);
    for j = 1:length(chord_freqs)
        % Define a short time vector for a single note
        t = 0:1/Fs:chord_length;
        % Create a single note
        single_note = sin(2*pi*chord_freqs(j)*t);
        % Concatenate to the music
        music = [music, single_note];
    end

    len_diff = abs(length(music) - length(music_chord));

    if length(music) < length(music_chord)
        music = [music, zeros(1, len_diff)];
    elseif length(music_chord) < length(music)
        music_chord = [music_chord, zeros(1, len_diff)];
    end

    % Mix the current note and chord
    % Divided by 2 to control the peak of the frequency 
    mix_current = (music + music_chord) / 2;

    % Add the mixed track to the overall mixed music
    music_mix = [music_mix, mix_current];

    % Reset music and music_chord for the next iteration
    music = [];
    music_chord = [];
end

% Normalize the music
music_mix = music_mix / max(abs(music_mix));
%%
% Plotting the Spectrogram
figure;
spectrogram(music_mix, 256, [], [], Fs, 'yaxis');
title('Spectrogram of the Final Audio Signal');
% Plotting the music signal before it is played
figure;
plot(music_mix);
title('Final Audio Signal');
% Print the sheet music with actual notes
disp('Musical notes (in numerical representation):');
fprintf('%d ', note_actual);
fprintf('\n');
%%
% Play the music
soundsc(music_mix, Fs);

pause(60);
clear sound;