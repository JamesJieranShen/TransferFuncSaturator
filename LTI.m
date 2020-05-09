%% Generate Exponential Sweep

fs = 44100;
fstart = 100;
fstop = 20000;

w1 = 2 * pi * fstart / fs;
w2 = 2 * pi * fstop / fs;

L = fs * 10;    % sweep is 10 seconds long;
n = 1:L;
x = 0.01 * sin(w1 * (L) * (exp(n .* log(w2/w1) / (L))-1) / log(w2/w1));

audiowrite("exponential sweep.wav", x, fs);


%% read in frequency response
[response, Fs] = audioread('freq_response.wav', 'double');
% spectrogram(response, 1024, 120, 4096, fs)
inverse = x(L + 1 - n) .* (w2/w1).^(-n/(L));
% spectrogram(inverse, 1024, 120, 4096, fs)
h_unnorm = conv(inverse, response);

%%
% the non-harmonic freq response starts with the highest transient;
[maxv, maxidx] = max(h_unnorm);
h_segmented = h_unnorm(maxidx:end);
% normalize the maximum magnitude to 0 dB

[freq,h_fft] = ampSpectrum(h_segmented, fs);
[maxv, maxidx] = max(h_fft);

%%
textwrite("wetsignal.csv", h_segmented);

%%
h = h_segmented(1:512);
T = fs;
t = 1:T;
freq = 500:0.01:800;
amps = zeros(size(freq));
parfor i = 1 : length(freq)
    w = freq(i)* 2 * pi / fs;
    testsig = sin(w .* t);
    ret = conv(testsig, h);
    amps(i) = max(ret);
end

plot(freq, amps);

h_normalized = h ./ max(amps);

figure;
parfor i = 1 : length(freq)
    w = freq(i)* 2 * pi / fs;
    testsig = sin(w .* t);
    ret = conv(testsig, h_normalized);
    amps(i) = max(ret);
end

plot(freq, amps);

%%
save LTI_filter.mat h_normalized;