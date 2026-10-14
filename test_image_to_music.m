function test_image_to_music()
if exist('OCTAVE_VERSION','builtin'), pkg load image; end
[a,fs,s]=image_to_music(zeros(2),8000,2);
assert(all(s.notes==1)); assert(isequal(s.chords(1,:),[1 3 5]));
assert(s.rhythm==2); assert(numel(a)==sum(s.samples));
assert(all(isfinite(a))); assert(max(abs(a))<=1); assert(fs==8000);
% Independently compute first sample of the zero-image triad+arpeggio.
expected=(sum(sin(2*pi*s.frequencies([1 3 5])/fs))+sin(2*pi*s.frequencies(1)/fs))/2;
raw=(sum(sin(2*pi*s.frequencies([1 3 5])'*(0:s.samples(1)-1)/fs),1));
b=round(linspace(0,s.samples(1),4)); arp=zeros(size(raw));
for j=1:3, arp(b(j)+1:b(j+1))=sin(2*pi*s.frequencies(s.chords(1,j))*(0:b(j+1)-b(j)-1)/fs); end
assert(abs(a(2)-expected/max(abs((raw+arp)/2)))<1e-10);
for img={uint8(ones(3)*128),uint16(ones(3)*32768),ones(3)*.5,zeros(3,3,3),reshape(linspace(0,1,27),3,3,3)}
    [a,~,s]=image_to_music(img{1},8000,3); assert(all(isfinite(a)));assert(all(s.notes>=1 & s.notes<=8));assert(all(s.chords(:)>=1 & s.chords(:)<=8));
end
for img={[],NaN,ones(2,2,4),2,-1}
    caught=false;try,image_to_music(img{1},8000,2);catch,caught=true;end;assert(caught);
end
caught=false;try,image_to_music(zeros(2),NaN,2);catch,caught=true;end;assert(caught);
[preview,~,previewInfo]=image_to_music(zeros(3));assert(numel(previewInfo.notes)==256);assert(all(isfinite(preview)));
mkdir('results'); synthetic=reshape(linspace(0,1,256),16,16);
imwrite(synthetic,'results/synthetic.png');[a,fs]=image_to_music(synthetic,8000,4);audiowrite('results/synthetic.wav',a,fs);
fprintf('PASS: note/chord oracle, sample counts, finite audio, image types, invalid inputs, WAV output\n');
end
