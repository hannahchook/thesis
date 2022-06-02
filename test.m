original = fullfile("MUS/train/A Classic Education - NightOwl/mixture.wav");
drums = fullfile("MUS/train/A Classic Education - NightOwl/drums.wav");
bass = fullfile("MUS/train/A Classic Education - NightOwl/bass.wav");
other = fullfile("MUS/train/A Classic Education - NightOwl/other.wav");
vocals = fullfile("MUS/train/A Classic Education - NightOwl/vocals.wav");
window_size = 2048;
frame_rate = 48;

% read in separate audio files
[drums_total, left_d, right_d, Fs_d] = read_in_audio(drums);
[bass_total, left_b, right_b, Fs_b] = read_in_audio(bass);
[total, left, right, Fs] = read_in_audio(original);

% declare keys for maps
keys = {'drums', 'bass'};

% read drums file
location_d = find_loc(left_d, right_d, 4096);
pitches_d = pitch_detection(left_d, right_d, window_size, 0.01, Fs_d, 'crossCorrelation');

