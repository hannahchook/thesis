% Hannah Chookaszian
function make_visual(original, drums, bass, vocals, other, outputFileName)
% MAKES VISUALIZATION USING SOURCE SEPARATED FILES
% Inputs:
%   original = non source separated audio file
%   drums = drums file
%   bass = bass file
%   vocals = vocals file
%   other = other file
%   outputFileName = string with name for output file
% Outputs:
%   outputs a file to the output filename  specified

close all
window_size = 2048;
window_size_loc = 10240;
frame_rate = 30;

% declare keys for maps
keys = {'drums', 'bass', 'vocals', 'other'};

drum_color = uisetcolor([1, 1, 0], 'Select a DRUMS color');
bass_color = uisetcolor([0, 0, 1], 'Select a BASS color');
vocals_color = uisetcolor([1, 0, 1], 'Select a VOCALS color');
other_color = uisetcolor([0, 1, 1], 'Select a OTHER color');
colors_array = {drum_color, bass_color, vocals_color, other_color};
colors = containers.Map(keys, colors_array);

% read in full audio file
full = read_in_audio(original);
Fs = full.Fs;
original_file = full.fullFile;
left = full.left;

% read drums file
location_d = find_loc(drums, window_size_loc);
pitches_d = pitch_detection(drums, window_size, 0.1, ...
    "crossCorrelation", 50);

% read bass file
location_b = find_loc(bass, window_size_loc);
pitches_b = pitch_detection(bass, window_size, 0.1, ...
    "crossCorrelation", 50);

% read vocals file
location_v = find_loc(vocals, window_size_loc);
pitches_v = pitch_detection(vocals, window_size, 0.1, ...
    "crossCorrelation", 50);

% read other file
location_o = find_loc(other, window_size_loc);
pitches_o = pitch_detection(other, window_size, 0.1, ...
    "crossCorrelation", 50);

% initialize pointer for locations
location_index = 1;
% create array of current locations
current_locations = [location_d(location_index), ...
    location_b(location_index), location_v(location_index)...
    , location_o(location_index)];
% current_locations_normalized = normalize(current_locations, 'range', [0.1,0.9]);

% initialize point for pitches
pitch_index = 1;
% create array of current pitches
current_pitches = [pitches_d(pitch_index), pitches_b(pitch_index),...
    pitches_v(pitch_index), pitches_o(pitch_index)];

% create maps for pitches and locations to easily update current parameters
pitches = containers.Map(keys, current_pitches);
locations = containers.Map(keys, current_locations);

% total_pitches = pitch_detection(left, right, window_size, 0.1, Fs);

%
% initialize first frame
% pitches and locations are limited in range [0, 1000] 
im = zeros(1000);

% Fs = samples/second

% Find number of samples that will be represented per frame
% Samples per frame = sampling rate/frame rate
samples_per_frame = round(Fs/frame_rate);

% initialize variable to keep track of average loudness for each instrument
% across each frame
loudness_sum_d = 0;
loudness_sum_b = 0;
loudness_sum_v = 0;
loudness_sum_o = 0;

% initialize video
% frame rate = [frames/second]
vid = VideoWriter('test');
vid.FrameRate = frame_rate;

% Open the video file
open(vid)
drums = read_in_audio(drums);
bass = read_in_audio(bass);
vocals = read_in_audio(vocals);
other = read_in_audio(other);

for i = 1:length(drums.fullFile)
    % check if pitch needs adjusting
    % pitch is recorded every (1/Fs)*window_size seconds
    % need to check pitch for visualization every window_size samples
    % check when the current index is a multiple of the window size
    if (rem(i, window_size) == 0)
        % Adjust location if the index is where a pitch is noted
        pitch_index = pitch_index + 1;
        pitches('drums') = pitches_d(pitch_index);
        pitches('bass') = pitches_b(pitch_index);
        pitches('vocals') = pitches_v(pitch_index);
        pitches('other') = pitches_o(pitch_index);
    end
    if (rem(i, window_size_loc) == 0)
        location_index = location_index + 1;
        locations('drums') = location_d(location_index);
        locations('bass') = location_b(location_index);
        locations('vocals') = location_v(location_index);
        locations('other') = location_o(location_index);
    end
    % add to sums for the loudnesses
    loudness_sum_d = loudness_sum_d + abs(drums.left(i)+drums.right(i));
    loudness_sum_b = loudness_sum_b + abs(bass.left(i)+bass.right(i));
    loudness_sum_v = loudness_sum_v + abs(vocals.left(i)+vocals.right(i));
    loudness_sum_o = loudness_sum_o + abs(other.left(i)+other.right(i));
    % check if frame should be written
    % frames are written at sampling rate/frame rate
    if (rem(i, samples_per_frame) == 0)
        % find average loudness for frame
        loudnesses = [loudness_sum_d, loudness_sum_b, loudness_sum_v, ...
            loudness_sum_o] ./ samples_per_frame;
        % get new frame
        frame = get_frame(im, pitches, locations, loudnesses, colors);
        % write frame to video
        writeVideo(vid, frame);
        % set loudness sums back to zero
        loudness_sum_d = 0;
        loudness_sum_b = 0;
        loudness_sum_v = 0;
        loudness_sum_o = 0;
    end
end
close(vid);

% create VideoFileReader object for adding in sound
videoFReader = vision.VideoFileReader('test.avi');
videoFWriter = vision.VideoFileWriter(outputFileName, ...
    'AudioInputPort', true, 'FrameRate', frame_rate);

% iterate through video file and add sound
k = 1;
num_frames = (1/samples_per_frame)*length(left);
for j=1:num_frames
  videoFrame = videoFReader();
  audio = original_file(k:k+samples_per_frame + 1);  
  videoFWriter(videoFrame, audio.');
  k = k + samples_per_frame;
end
release(videoFReader);
release(videoFWriter);

end
%implay('output.avi', frame_rate)