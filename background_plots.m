[y, left, right, Fs] = read_in_audio('vocals.mp3');
time = 1:length(y);
time = time ./ Fs;
figure(1)
subplot(2, 1, 1)
plot(time, left)
xlabel("Time")
title("Left side of Audio Excerpt")
subplot(2, 1, 2)
plot(time, right)
xlabel("Time")
title("Right side of Audio Excerpt")