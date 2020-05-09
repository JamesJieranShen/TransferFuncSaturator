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
xnl = xnl';
audiowrite("x_nl.wav", xnl, fs);
%% apply LTI Block
load('LTI_filter.mat');
xnl = conv(xnl, h_normalized, "same");
%% read in wet file
[wet, Fs] = audioread('nl_wet.wav', 'double');

%% envolope extraction
[xnl_posenv, xnl_negenv] = get_envolope(xnl, fs);
[wet_posenv, wet_negenv] = get_envolope(wet, fs);

%%
x0 = [1 0.01 0.3 0.3 2 2 1 1];

%%
[res_grid, prespace, postspace] = gain_search(@distortion_block, [0.001 0.001], [100 1], 1, 0.1, x0, xnl, wet);
%%
[row, col] = find(ismember(res_grid, min(res_grid(:))));
searched_pre = prespace(row)
searched_post = postspace(col)

x0 = [searched_pre, x0(2:7), searched_post];
%% Training Postivie Coefficients
pos0 = [0.5 2];
neg0 = [0.5, 2];
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt', ...
    'MaxIterations', 100000, 'UseParallel', true, 'MaxFunctionEvaluations',100000, 'FunctionTolerance', 1e-8);
xp = lsqcurvefit(@(param, input)train_pos(param, input, x0), pos0, xnl, wet_posenv, [], [], options)
xn = lsqcurvefit(@(neg_param, input)train_neg(neg_param, input, x0), neg0, xnl, wet_negenv, [], [], options)

%%
x0(3) = xp(1);
x0(4) = xn(1);
x0(5) = xp(2);
x0(6) = xn(2);
%%
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt', ...
    'MaxIterations', 100000, 'UseParallel', true, 'MaxFunctionEvaluations',100000, 'FunctionTolerance', 1e-6);
x_final = lsqcurvefit(@train_everything, x0, xnl, [wet_posenv; wet_negenv], [], [], options)

%%
function y = train_pos(x, xdata, x0)
    % x = kp, gp
    fs = 44100;
    kn = 0.5;
    gn = 0.5;
    gpre = x0(1);
    gbias = x0(2);
    kp = x(1);
    gp = x(2);
    gwet = x0(7);
    gpost = x0(8);
    
    params = [gpre, gbias, kp, kn, gp, gn, gwet, gpost];
    output = distortion_block(params, xdata);
    [posenv, negenv] = get_envolope(output, fs);
    y = posenv;
end

function y = train_neg(x, xdata, x0)
    % x = kn, gn
    fs = 44100;
    kn = x(1);
    gn = x(2);
    gpre = x0(1);
    gbias = x0(2);
    kp = x0(3);
    gp = x0(5);
    gwet = x0(7);
    gpost = x0(8);

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

function [res_grid, prespace, postspace] = gain_search(model, lb, ub, dpre, dpost, x0, xdata, ydata)
% GAIN_SEARCH This function does a grid search for gpre and gpost
fprintf("STARTING...\n");
prespace = lb(1):dpre:ub(1);
postspace = lb(2):dpost:ub(2);

res_grid = zeros(length(prespace), length(postspace));
row_length = size(res_grid, 2);
parfor i = 1:size(res_grid, 1)
    for j = 1:row_length
        params = [prespace(i) x0(2:7) postspace(j)];
        res_grid(i, j) = get_res(model,params, xdata, ydata);
    end
end

fprintf('Completed Grid Search\n');
end