function out = read_in_audio(filename)
% READS IN STEREO AUDIO FILES AND OUTPUTS THE STEREO WAVEFORM ALONG WITH
% THE SEPARATE CHANNELS AND THE SAMPLING RATE
% Inputs:
%   filename = name of audio file
% Outputs:
%   left = information from left channel of waveform
%   right = information from right channel of waveform
%   Fs = sampling frequency of audio file

    % read in audio file
    [y,Fs] = audioread(filename);
    % split up into left and right channels
    info = audioinfo(filename);
    out = struct;
    out.Fs = Fs;
    out.fullFile = y;
    if info.NumChannels == 2
        left = y(:,1);
        right = y(:,2);
        out.left = left;
        out.right = right;
        out.NumChannels = 2;
    else
        out.NumChannels = 1;
    end
    
end