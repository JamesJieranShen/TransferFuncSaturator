function [f, P1] = ampSpectrum(X,fs)
%POWERSPECTRUM Plot Power spectrum of a signal, given Fs

Y = fft(X);
L = length(X);

P2 = abs(Y/L);
P1 = P2(1:L/2 + 1);

P1(2:end - 1) = P1(2 : end - 1);

f = fs * (0:(L/2))/L;
plot(f, P1);

xlabel('f (Hz)');
ylabel('Amplitude');

end
