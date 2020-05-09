function res = get_res(model,params, xdata, ydata)
%GET_RES take a list of params, calculate the residual based on that
%   This function finds the residual of the signal by calculating
%   least-square residual after an envolope extraction.
    fs = 44100;
    model_output = model(params, xdata);
    [output_posenv, output_negenv] = get_envolope(model_output, fs);
    [y_posenv, y_negenv] = get_envolope(ydata, fs);
    
    posres = output_posenv - y_posenv;
    negres = output_negenv - y_negenv;
    
    % overal res is square sum of the two envolope residuals combined;
    res = sum(posres.^2, 'all') + sum(negres.^2, 'all');

end

