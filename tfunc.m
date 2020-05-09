function y = tfunc(x, Params)
%TFUNC Transfer Function proposed by Eichas
%   Piecewise tanh function
%   Params = [kp, kn, gp, gn]
    kp = Params(1);
    kn = Params(2);
    gp = Params(3);
    gn = Params(4);

    y = zeros(size(x));

    idx1 = x >= kp;
    y(idx1) = tanh(kp) - (((tanh(kp)^2 - 1)/gp) * tanh(gp * (x(idx1) - kp)));
    idx2 = x <= -kn;
    y(idx2) = -tanh(kn) - (((tanh(kn)^2 - 1)/gn) * tanh(gn * (x(idx2) + kn))); 
    y(~(idx1 | idx2)) = tanh(x(~(idx1 | idx2)));
end
