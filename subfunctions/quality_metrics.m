function [sci,psp,fpsp] = quality_metrics(handles,signal1,signal2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fcut_max = str2double(get(handles.edit_highcutoff,'string'));
similarity = xcorr(signal1,signal2,'unbiased');  %cross-correlate the two wavelength signals - both should have cardiac pulsations
if any(abs(similarity)>eps)
    % this makes the SCI=1 at lag zero when x1=x2 AND makes the power estimate independent of signal length, amplitude and Fs
    similarity = length(signal1)*similarity./sqrt(sum(abs(signal1).^2)*sum(abs(signal2).^2));  % this makes the SCI=1 at lag zero when x1=x2 AND makes the power estimate independent of signal length, amplitude and Fselse
else
    warning('Saturated signals');
end
[pxx,f] = periodogram(similarity,hamming(length(similarity)),length(similarity),handles.fs,'power');
[pwrest,idx] = max(pxx(f<fcut_max));
sci = similarity(length(signal1));
psp = pwrest;
fpsp = f(idx);

end

