function [fs, s ] = estimateFs(t_ms)
% estimateFs Estimates the sampling frequency (fs).
%
%  Call:
%    [fs, s] = estimateFs(t_ms);
%
%    where t_ms is a strictly monotonically increasing timevector in ms and
%    fs the estimated sampling frequency. The struct s contains extra
%    information about the fs estimation.
%
%--------------------------------------------------------------------------


%% Estimate the Fs:

% Check input:
assert(size(t_ms,2)==1,'t_ms must be a 1 column vector.');
assert(all(diff(t_ms)>0)...
    ,'t_ms must be strictly monotonically increasing.');

% Calc the different between the samples, then estimate the dt and fs:
diff_t_ms = diff(t_ms);
dt_ms     = median(diff_t_ms);
fs        = round(1000/dt_ms, 2);

% If more info was requested, calculate some metadata about the estimated
% fs:
if nargout > 1
    
    % Get the error between the t_ms as and what is should be given the
    % estimated fs:
    t_ms_2                       = t_ms;
    t_ms_2(2:end)                = t_ms(1:end-1) + dt_ms;
    s.dt_error_ms                = t_ms - t_ms_2;
    s.dt_ms                      = dt_ms;
    
    % Calculate how many samples are off by more than half an dt:
    s.offByMoreThanHalfFs        = abs(s.dt_error_ms) > 0.5 * dt_ms;
    s.percentOffByMoreThanHalfFs = 100*sum(s.offByMoreThanHalfFs)...
        /numel(t_ms);
    
end

end