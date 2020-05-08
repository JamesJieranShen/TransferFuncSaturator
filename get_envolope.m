function [posenv,negenv] = get_envolope(x,fs)
%GET_ENVOLOPE Extract Positive and Negative envolope of the function by
%lowpass filtering
x_pos = zeros(size(x));
x_neg = zeros(size(x));

for i = 1:length(x)
    if x(i) > 0
        x_pos(i) = x(i);
    else
        x_neg(i) = x(i);
    end
end

extractor = LPF(2, 5, fs);  % order of 2, fc = 5

posenv = filter(extractor, x_pos);
negenv = filter(extractor, x_neg);
end

