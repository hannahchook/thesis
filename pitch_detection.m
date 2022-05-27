function pitches = pitch_detection(audioIn, window_size, threshold, algorithm, overlap)
% FINDS PITCHES OF A WAVEFORM USING AUTOCORRELATION WITH 50% OVERLAP
% Inputs:
%   audioIn = name of audio file
%   window_size = size of window for autocorrelation
%   threshold = minimum value for a peak to be counted in pitch estimation
%               (between 0 and 1)
%   algorithm = pitch detection algorithm (options: crossCorrelation, AMDF,
%   and SDF)
%   overlap = percent overlap between windows
% Outputs:
%   pitches = fundamental frequencies at every (1/Fs)*window_size seconds
audio_input = read_in_audio(audioIn);
if audio_input.NumChannels == 2
    audio = average_channels(audio_input.left, audio_input.right);
else
    audio = audio_input.fullFile;
end
current_index = 1;
pitches = zeros(ceil((length(audio)/window_size)*2), 1);
pitchind = 1;
h = hamming(window_size);
% figure(2)
% plot(h);
% title('Hamming Window')
% xlabel('n')
% ylabel('h(n)')

switch algorithm
    case "crossCorrelation"
        while current_index < length(audio)
            % segment and window the audio 
            if (current_index + window_size < length(audio))
                windowed = audio(current_index:current_index+window_size-1).*h;
            else
                windowed = audio(current_index:end).*hamming(length(audio(current_index:end)));
            end
            if nnz(windowed) < length(windowed)/2
%                 if nnz(windowed) > 0
%                     [ac, LAGS] = xcorr(windowed, 'normalized');
%                     figure(2)
%                     plot(LAGS, ac);
%                     xlabel('Lag')
%                     ylabel('Autocorrelation')
%                     title('Autocorrelation Result with >50% Silence')
%                 end
                pitches(pitchind) = 0; 
                pitchind = pitchind + 1;
                % 50 percent overlap
                current_index = current_index + round(window_size*(1-overlap/100));
                continue
            end
            % take autocorrleation of window and normalize
%             figure(90)
%             plot(windowed, 'LineWidth',1);
%             hold on
%             plot(audio(current_index:current_index+window_size-1), '--')
%             hold off
%             title('Windowed Audio vs Original Audio')
%             xlabel('n')
%             ylabel('w(n)')
%             legend('Windowed Audio Waveform', 'Original Audio Waveform')
            [ac, LAGS] = xcorr(windowed, 'normalized');
%             figure(10)
%             plot(LAGS, ac);
%             xlabel('Lag')
%             ylabel('Autocorrelation')
%             plot(ac);
%             title('Autocorrelation')
            % set values below threshold = 0
            % ac(ac<threshold) = 0;
            % find all the peaks in the autocorrelation on one side
            [peaks, locs] = findpeaks(ac(ceil(length(ac)/2):end), ...
                'NPeaks', 5, 'SortStr', 'descend', 'MinPeakHeight', threshold);
            % find largest peak 
            ind = locs(peaks==max(peaks));
            if isempty(ind) == 0
            % pitch is equal to the sampling frequency divided by the peak
            % index
                fundamental_freq = audio_input.Fs/ind(1); %finds fundamental frequency
            else
                fundamental_freq = 0;
            end

            if (fundamental_freq < 1000)
                pitches(pitchind) = fundamental_freq; 
            else
                ac_filt = medfilt1(ac, 20);
%                 figure(10)
%                 plot(LAGS, ac);
%                 hold on
%                 plot(LAGS, ac_filt)
%                 hold off
%                 xlabel('Lag')
%                 ylabel('Autocorrelation')
%                 title('Filtered vs Unfiltered Autocorrelation')
%                 legend('Unfiltered', 'Filtered')

                [peaks, locs] = findpeaks(ac_filt(ceil(length(ac)/2):end), ...
                'NPeaks', 5, 'SortStr', 'descend', 'MinPeakHeight', threshold,'MinPeakWidth', 50);
                ind = locs(peaks==max(peaks));
                if isempty(ind) == 0
                    fundamental_freq = audio_input.Fs/ind(1); %finds fundamental frequency
                    if fundamental_freq > 1000
                        fundamental_freq = 0;
                    end
                else
                    fundamental_freq = 0;
                end
                pitches(pitchind) = fundamental_freq; 
            end
            pitchind = pitchind + 1;
            % 50 percent overlap
            current_index = current_index + round(window_size*(1-overlap/100));
        end

    case "AMDF"
        while current_index < length(audio)
            amdf = zeros(1, length(window_size));
            if (current_index + window_size < length(audio))
                frame = audio(current_index:current_index+window_size-1) .* h;
            else
                frame = audio(current_index:end) .* hamming(length(audio(current_index:end)));
            end
            if nnz(frame) < length(frame)/2
                pitches(pitchind) = 0; 
                pitchind = pitchind + 1;
                % 50 percent overlap
                current_index = current_index + round(window_size*(1-overlap/100));
                continue
            end
            for k = 1:length(frame)-1
                shifted = circshift(frame, k);
                amdf(k) = sum(abs(frame - shifted));
            end
%             figure(100)
%             plot(amdf);
%             xlabel('Lag')
%             ylabel('AMDF Value')
%             title('Average Magnitude Difference Function')
%             amdf_filtered = medfilt1(amdf, 20);
            [min_loc, ~] = islocalmin(amdf, ...
                'MaxNumExtrema', 5);
            % find largest peak 
            ind = find(min_loc==1);
            if isempty(ind) == 0
            % pitch is equal to the sampling frequency divided by the peak
            % index
                fundamental_freq = audio_input.Fs/ind(1); %finds fundamental frequency
            else
                fundamental_freq = 0;
            end
            if (fundamental_freq < 1000)
                pitches(pitchind) = fundamental_freq; 
            else
                amdf_filt = medfilt1(amdf, 20);
%                 figure(10)
%                 plot(amdf);
%                 hold on
%                 plot(amdf_filt)
%                 hold off
%                 xlabel('Lag')
%                 ylabel('AMDF Value')
%                 title('Filtered vs Unfiltered AMDF')

                [min_loc, ~] = islocalmin(amdf, ...
                'MaxNumExtrema', 5);
                % find largest peak 
                ind = find(min_loc==1);
                if isempty(ind) == 0
                % pitch is equal to the sampling frequency divided by the peak
                % index
                    fundamental_freq = audio_input.Fs/ind(1); %finds fundamental frequency
                else
                    fundamental_freq = 0;
                end
                pitches(pitchind) = fundamental_freq; 
            end
            pitchind = pitchind + 1;
            % 50 percent overlap
            current_index = current_index + round(window_size*(1-overlap/100));
        end
    case "SDF"
        while current_index < length(audio)
            sdf = zeros(1, length(window_size));
            if (current_index + window_size < length(audio))
                frame = audio(current_index:current_index+window_size-1).*h;
            else
                frame = audio(current_index:end).* hamming(length(audio(current_index:end)));
            end
            if nnz(frame) < length(frame)/2
                pitches(pitchind) = 0; 
                pitchind = pitchind + 1;
                % 50 percent overlap
                current_index = current_index + round(window_size*(1-overlap/100));
                continue
            end
            for k = 1:length(frame)-1
                shifted = circshift(frame, k);
                sdf(k) = sum((frame - shifted).^2);
            end
%             figure(200)
%             plot(sdf);
%             xlabel('Lag')
%             ylabel('SDF Value')
%             title('Square Difference Function')
%             sdf_filtered = medfilt1(sdf, 20);
            [min_loc, ~] = islocalmin(sdf, ...
                'MaxNumExtrema', 5);
            % find largest peak 
            ind = find(min_loc==1);
            if isempty(ind) == 0
            % pitch is equal to the sampling frequency divided by the peak
            % index
                fundamental_freq = audio_input.Fs/ind(1); %finds fundamental frequency
            else
                fundamental_freq = 0;
            end
            if (fundamental_freq < 1000)
                pitches(pitchind) = fundamental_freq; 
            else
                sdf_filt = medfilt1(sdf, 20);
%                 figure(10)
%                 plot(sdf);
%                 hold on
%                 plot(sdf_filt)
%                 hold off
%                 xlabel('Lag')
%                 ylabel('SDF Value')
%                 title('Filtered vs Unfiltered SDF')

                [min_loc, ~] = islocalmin(sdf, ...
                'MaxNumExtrema', 5);
                % find largest peak 
                ind = find(min_loc==1);
                if isempty(ind) == 0
                % pitch is equal to the sampling frequency divided by the peak
                % index
                    fundamental_freq = audio_input.Fs/ind(1); %finds fundamental frequency
                else
                    fundamental_freq = 0;
                end
                pitches(pitchind) = fundamental_freq; 
            end
            pitchind = pitchind + 1;
            % 50 percent overlap
            current_index = current_index + round(window_size*(1-overlap/100));
        end

end
end
