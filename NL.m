%% constants
fs = 44100;
L = 10 * fs;    % length of test signal
n = 1:L;        % linspace
f0 = 1000;
%% test signal
a_start = 1e-5;
a_end = 1;
a = ((a_end - a_start)/log(L)) .* log(n) + a_start;
xnl = a .* sin(2 .* pi .* f0 .* n./fs);

audiowrite("x_nl.wav", xnl, fs);
%% apply LTI Block
load('LTI_filter.mat');
xnl = conv(xnl, h_normalized);
%% read in wet file
[wet, Fs] = audioread('nl_wet.wav', 'double');
wet_pad = zeros(size(xnl));
wet_pad(1:length(wet)) = wet;
wet = wet_pad;

%% envolope extraction
[xnl_posenv, xnl_negenv] = get_envolope(xnl, fs);
[wet_posenv, wet_negenv] = get_envolope(wet, fs);

%%
pos0 = [1 0.2 0.5 1 0.5 1];
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt', 'MaxIterations', 100000, 'UseParallel', true, 'MaxFunctionEvaluations',100000);
xp = lsqcurvefit(@train_pos, pos0, xnl, wet_posenv, lbpos, ubpos, options)

%%
neg0 = [0.5 1];
xn = lsqcurvefit(@train_neg, neg0, xnl, wet_negenv,[], [], options)

%%
x0 = [xp(1), xp(2), xp(3), xn(1), xp(4), xn(2), xp(5), xp(6)];
x_final = lsqcurvefit(@train_everything, x0, xnl, [wet_posenv; wet_negenv], [], [], options)


function y = train_pos(x, xdata)
    % x = gpre, gbias, kp, gp, gwet, gpost
    fs = 44100;
    kn = 0.5;
    gn = 0.5;
    gpre = x(1);
    gbias = x(2);
    kp = x(3);
    gp = x(4);
    gwet = x(5);
    gpost = x(6);
    
    params = [gpre, gbias, kp, kn, gp, gn, gwet, gpost];
    output = distortion_block(params, xdata);
    [posenv, negenv] = get_envolope(output, fs);
    y = posenv;
end

function y = train_neg(x, xdata)
    % x = kn, gn
    fs = 44100;
    kn = x(1);
    gn = x(2);
    gpre = 23.4890;
    gbias = 0.0125;
    kp = 0.5904;
    gp = 18.9074;
    gwet = 1.0000;
    gpost = 0.2155;

    params = [gpre, gbias, kp, kn, gp, gn, gwet, gpost];
    output = distortion_block(params, xdata);
    [posenv, negenv] = get_envolope(output, fs);
    y = negenv;
end


function y = train_everything(x, xdata)
    fs = 44100;
    output = distortion_block(x, xdata);
    [posenv, negenv] = get_envolope(output, fs);
    y = [posenv;negenv];
end