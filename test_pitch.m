% Hannah Chookaszian
% Testing pitch detection algorithms on MBD Melody Synth Dataset
%% Defining things
resynth = fullfile("MDB-melody-synth/audio_melody");
annotation = fullfile("MDB-melody-synth/annotation_melody");
mix = fullfile("MDB-melody-synth/audio_melody");
threshold = 0.1;
algorithm = 'crossCorrelation';
window_size = 2048;
overlap = 50;
song = 'AimeeNorwich_Child_STEM_04.RESYN';

%% Test on small sample of music
annotationTest_filedir = dir(strcat(annotation,'/', song, '.csv'));
anno_test = load(annotationTest_filedir.name);
resynthTest_filedir = dir(strcat(resynth, '/',song, '.wav'));
resynth_test = audioread(resynthTest_filedir.name);
part = resynth_test(1190700:1323000);
audiowrite("excerpt.wav", part, 44100);
excerpt = fullfile("excerpt.wav");

xcorr_method = pitch_detection(resynthTest_filedir.name, 2048, 0.1, 'crossCorrelation', 50);
% amdf_method = pitch_detection(resynthTest_filedir.name, 2048, 0.1, 'AMDF', 50);
% sdf_method = pitch_detection(resynthTest_filedir.name, 2048, 0.1, 'SDF', 50);

%% Calculate Percent Error For Entire Dataset
% percent_error_dataset = [];
files = dir(strcat(annotation, '/*.csv'));
mean_sqrd_error = [];
RMSE = [];
mean_err = [];
pererr = [];
dy = [];
counter = 1;
for file = files'
    annotation_file = load(file.name);
    annotation_file_pitches = annotation_file(:, 2);
    [~, name] = fileparts(file.name);
    resynth_filedir = dir(strcat(resynth, '/',name, '.wav'));
    resynth_file = audioread(resynth_filedir.name);
%     window_size = round((length(resynth_file)/length(annotation_file))/(overlap/100));
    pitches_resynth = pitch_detection(resynth_filedir.name, window_size, threshold, algorithm, overlap);

    %     find ratio of pitches to annotations
    ratio = round(length(annotation_file)/length(pitches_resynth));
    new_ann_file = [];
    sum = 0;
    for a = 1:length(annotation_file)
        sum = sum + annotation_file(a, 2); 
        if (rem(a, ratio) == 0)
            sum = sum/ratio;
            new_ann_file(end+1) = sum;
            sum = 0;
        end
    end
    new_ann_file = new_ann_file.';

    if length(pitches_resynth) ~= length(new_ann_file)
        x = length(pitches_resynth);
        y = length(new_ann_file);
        diff = zeros(abs(y-x), 1);
        new_ann_file = vertcat(new_ann_file, diff);
    end

    dy(end+1) = mean(abs(new_ann_file-pitches_resynth)) ; % error 
    pererr_avg = 0;
    for ind = 1:length(new_ann_file)
        res = abs(new_ann_file(ind)-pitches_resynth(ind))./new_ann_file(ind)*100 ;   % percentage error 
        if isnan(res)
            pererr_avg = pererr_avg + 0;
        elseif isinf(res)
            pererr_avg = pererr_avg + 0;
        else
            pererr_avg = pererr_avg + res;
        end
    end
    pererr(end+1) = pererr_avg/length(new_ann_file);
    mean_err(end+1) = mean(abs(new_ann_file-pitches_resynth)) ;    % mean absolute error 
    RMSE(end+1) = sqrt(mean((new_ann_file-pitches_resynth).^2)) ; % Root mean square error 
    mean_sqrd_error(end+1) = immse(new_ann_file,pitches_resynth);

    mix_filename = dir(strcat(mix, '/',name, '.wav'));
    [mix_file,Fs] = audioread(mix_filename.name);
end