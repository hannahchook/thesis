single = audioread('single_note.wav');
avg = average_channels(single(:, 1), single(:, 2));

figure(1)
plot(avg)
title('Envelope of Musical Note')
xlabel('samples')
ylabel('amplitude')

figure(2)
spectrogram(avg)
