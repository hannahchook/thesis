function locations = find_loc(audioIn, window_size)
% FINDS RELATIVE LOCATION OF SOUND FROM AUDIO FILE
% Inputs:
%   audioIn = name of audio file
%   window_size = size of frames for measurements
% Outputs:
%   location = panning potentiometer location on a 0-1000 scale
    audio_input = read_in_audio(audioIn);
    if audio_input.NumChannels == 2
        left = audio_input.left;
        right = audio_input.right;
    else
        error('File must be stereophonic')
    end

    % initialize counter for index in song
    current_index = 1;

    % initialize array to hold locations at each frame
    locations = zeros(1, ceil((length(left)/window_size)*2));

    % initialize index counter for locations array
    loc_ind = 1;

    % loop through song
    while current_index < length(left)
        % checking if the frame reaches past the end of the song
        if (current_index + window_size < length(left))
            windowed_l =  left(current_index:current_index+window_size-1);
            windowed_r = right(current_index:current_index+window_size-1);
        else
            windowed_l = left(current_index:end);
            windowed_r = right(current_index:end);
        end
        if nnz(~windowed_l) > length(windowed_l)/2 && nnz(~windowed_r) > length(windowed_r)/2
            if loc_ind > 1
                locations(loc_ind) = locations(loc_ind-1);
            else
                locations(loc_ind) = 0;
            end
            loc_ind = loc_ind + 1;
            current_index = current_index + (window_size/2);
            continue
        end
        % calculating panning potenitometer value
        % add 90 to avoid negative nums (changes scale from -90 to 90 to 0
        % to 180
        theta = atand(mean(windowed_r)/mean(windowed_l)) + 90;

        % add location to locations array
        locations(loc_ind) = theta;

        % increase counters
        % current index counter for song increases by half of window size
        % to make a 50% overlap between frames
        loc_ind = loc_ind + 1;
        current_index = current_index + (window_size/2);
    end

    % rescale locations to fall between 100 and 900 for the visualization
    locations = rescale(locations, 100, 900);
end