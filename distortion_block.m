function y = distortion_block(x, xdata)
%DISTORTION_BLOCK distortion function used for training
%   x: parameter list [gpre, gbias, kp, kn, gp, gn, gwet, gpost]'
%   xdata: input audio
%   ydata: output signal
fs = 44100;
gpre = x(1);
gbias = x(2);
tfunc_param = x(3:6);
gwet = x(7);
gdry = 1 - gwet;
gpost = x(8);

x_pre = xdata * gpre;

% bias chain
x_bias = abs(x_pre);
bias_lpf = LPF(10, 5, fs);
x_bias = filter(bias_lpf, x_bias);
x_bias = gbias * x_bias;

y = x_pre - x_bias;

y = gwet * tfunc(y, tfunc_param) + gdry * x_pre;

y = gpost * y; % return

end

