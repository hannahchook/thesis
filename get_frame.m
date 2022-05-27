function frame = get_frame(im, pitches, locations, loudnesses, colors)
% GETS ONE FRAME FOR A VIDEO USING THE PITCHES, LOCATIONS, AND LOUDNESS 
% FOR EACH SOURCE
% Inputs:
%   im = base image for visualization
%   pitches = array (1x4) with pitches at the time of the frame
%   locations = array (1x4) with locations at the time of the frame
%   loudnesses = array (1x4) with loudnesses at the time of the frame
% Outputs:
%   frame = frame with circles representing the inputs
    
    % find x and y locaitons of each of the instruments using their
    % pitches and locations
    % find the loudness for the diameter of the circles
    y_loc_d = 800-pitches('drums');
    x_loc_d = locations('drums');
    loudness_d = loudnesses(1);
    drum_color = colors('drums');
    if y_loc_d<200
        drum_color = colors('drums') *((y_loc_d+500)/1000);
    end

    y_loc_b = 800-pitches('bass');
    x_loc_b = locations('bass');
    loudness_b = loudnesses(2);
    bass_color = colors('bass');
    if y_loc_b<200
        bass_color = colors('bass') *((y_loc_b+500)/1000);
    end

    y_loc_v = 800-pitches('vocals');
    x_loc_v = locations('vocals');
    loudness_v = loudnesses(3);
    vocals_color = colors('vocals');
    if y_loc_v<200
        vocals_color = colors('vocals') *((y_loc_v+500)/1000);
    end

    y_loc_o = 800 - pitches('other');
    x_loc_o = locations('other');
    loudness_o = loudnesses(4);
    other_color = colors('other');
    if y_loc_o<200
        other_color = colors('other') *((y_loc_o+500)/1000);
    end
    
    % insert shapes on image for each source
    % NOTE: drum does not move location
    drum = insertShape(im ,'FilledCircle',[500 500 loudness_d ...
            * 500],'color',drum_color);
    bass = insertShape(drum ,'FilledCircle',[x_loc_b y_loc_b loudness_b ...
            * 500],'color',bass_color);
    vocal = insertShape(bass ,'FilledCircle',[x_loc_v y_loc_v loudness_v ...
            * 500],'color',vocals_color);
    other = insertShape(vocal ,'FilledCircle',[x_loc_o y_loc_o loudness_o ...
            * 500],'color', other_color);
    positions = [0 0; 0 25; 0 50; 0 75];
    values = {'Bass', 'Drum', 'Other', 'Vocals'};
    colors = [bass_color; drum_color; other_color; vocals_color];
    RGB = insertText(other,positions,values,'AnchorPoint','LeftTop', 'TextColor', 'White', BoxColor=colors);
    
    % convert image to frame
    frame = im2frame(RGB);
end