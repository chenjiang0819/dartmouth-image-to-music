function [audio, Fs, info] = image_to_music(img, Fs, gridSize)
% 2026 maintenance of Chen Jiang's FFT/gradient/entropy musical mapping.
% No playback or file access; integer images scale by their type's range.
if nargin < 2, Fs = 44100; end
if nargin < 3, gridSize = 16; end
if ~isnumeric(img) && ~islogical(img), error('image_to_music:input','Expected numeric image'); end
if isempty(img) || any(~isfinite(img(:))) || ndims(img)>3 || (ndims(img)==3 && size(img,3)~=3)
    error('image_to_music:input','Expected finite grayscale or RGB image');
end
if ~isscalar(Fs) || ~isfinite(Fs) || Fs~=fix(Fs) || Fs<2000 || Fs>192000
    error('image_to_music:rate','Sample rate must be an integer between 2000 and 192000');
end
if ~isscalar(gridSize) || gridSize~=fix(gridSize) || gridSize<2 || gridSize>50
    error('image_to_music:grid','Grid size must be an integer between 2 and 50');
end
img = im2double(img);
if any(img(:)<0) || any(img(:)>1), error('image_to_music:range','Floating images must be in [0,1]'); end
if ndims(img)==3, img=rgb2gray(img); end
window=min([3 3],size(img));
img=medfilt2(img,window);
% Explicit Gaussian kernel is available in both MATLAB and Octave image packages.
img=imfilter(img,fspecial('gaussian',[13 13],2),'replicate');
img=imresize(img,[gridSize gridSize]);
F=abs(fft2(img));
notes=1+mod(floor(mod(F(:).*img(:)*100,14)),8);
frequencies=[261.63 293.66 329.63 349.23 392 440 493.88 523.25 587.33 659.25 698.46 739.99 783.99 830.61 880 932.33]/2;
frequencies=frequencies([1 3 5 6 8 10 12 13]);
[dx,dy]=gradient(img); g=hypot(dx(:),dy(:));
span=max(g)-min(g);
if span>eps, g=.5+1.5*(g-min(g))/span; else, g(:)=.5; end
lengths=.2+g;
e=entropy(img);
if e<=eps, rhythm=2; else, rhythm=min(max(1,1/e),2); end
samples=max(1,round(Fs*lengths/rhythm));
% Bound memory before allocation (50^2 notes at 192 kHz can be excessive).
if sum(samples)>30000000, error('image_to_music:memory','Reduce grid size or sample rate'); end
audio=zeros(1,sum(samples)); cursor=1; chords=zeros(numel(notes),3);
for i=1:numel(notes)
    chords(i,:)=1+mod(notes(i)-1+[0 2 4],8);
    f=frequencies(chords(i,:)); N=samples(i); t=(0:N-1)/Fs;
    chord=sum(sin(2*pi*f(:)*t),1);
    arpeggio=zeros(1,N); bounds=round(linspace(0,N,4));
    for j=1:3
        count=bounds(j+1)-bounds(j);
        arpeggio(bounds(j)+1:bounds(j+1))=sin(2*pi*f(j)*(0:count-1)/Fs);
    end
    audio(cursor:cursor+N-1)=(chord+arpeggio)/2; cursor=cursor+N;
end
peak=max(abs(audio));
if peak>0, audio=audio/peak; end
info=struct('notes',notes,'chords',chords,'samples',samples,'rhythm',rhythm,'processed',img,'frequencies',frequencies);
end
