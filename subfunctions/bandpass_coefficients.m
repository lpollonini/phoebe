function [B,A] = bandpass_coefficients(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fcut_min = str2double(get(handles.edit_lowcutoff,'string'));
fcut_max = str2double(get(handles.edit_highcutoff,'string'));
if fcut_max >= (handles.fs)/2
    fcut_max = (handles.fs)/2 - eps;
    set(handles.edit_highcutoff,'string',num2str(fcut_max));
    uiwait(warndlg('The highpass cutoff has been reduced to Nyquist sampling rate. This setting will be saved for future use.'));
end

[B,A]=butter(1,[fcut_min*(2/handles.fs) fcut_max*(2/handles.fs)]);

end

