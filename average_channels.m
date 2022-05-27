function single_channel = average_channels(left, right)
% TAKES IN LEFT AND RIGHT CHANNEL OF A STEREO WAVEFORM AND OUTPUTS A SINGLE
% CHANNEL WHICH CONTAINS THE AVERAGE OF THE CHANNELS
% Inputs:
%   left = left channel of audio
%   right = right channel of audio
% Outputs:
%   single_channel = averaged channels

    single_channel = zeros(length(left), 1);
    for i = 1:length(left)
        single_channel(i) = 0.5*(left(i) + right(i));
    end
end