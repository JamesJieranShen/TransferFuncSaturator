%% Import
dry = audioread('dryguitar.wav', 'double');
wet = audioread('wetguitar.wav', 'double');
dry = dry(:, 1); % only take one channel
%% Apply Processing
load('training result2.mat');
load('LTI_filter.mat');
model = conv(dry, h_normalized, 'same'); 
model = distortion_block(x_final, model);

%% Calculate ESR
Esys = sum(abs(wet).^2, 'all');
Eres = sum(abs(wet - model).^2, 'all');
ESR = Eres/Esys

%% cov
C = cov(wet, model);
covariance = C(1, 2);
std_model = std(model);
std_wet = std(wet);

rho = covariance/(std_model * std_wet)