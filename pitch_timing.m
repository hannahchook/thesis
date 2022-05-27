resynth = fullfile("MDB-melody-synth/audio_melody");
annotation = fullfile("MDB-melody-synth/annotation_melody");
threshold = 0.1;
window_size = 2048;
overlap = 50;
song = 'AimeeNorwich_Child_STEM_04.RESYN';
resynthTest_filedir = dir(strcat(resynth, '/',song, '.wav'));

%xcorr_method = pitch_detection(resynthTest_filedir.name, 2048, 0.1, 'crossCorrelation', 50);
%amdf_method = pitch_detection(resynthTest_filedir.name, 2048, 0.1, 'AMDF', 50);
sdf_method = pitch_detection(resynthTest_filedir.name, 2048, 0.1, 'SDF', 50);
