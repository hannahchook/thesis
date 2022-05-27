function new_visualization(mixFilePath, outFileName)
    original = mixFilePath;
    drums = fullfile("separated/mdx_extra_q/mixture/drums.wav");
    bass = fullfile("separated/mdx_extra_q/mixture/bass.wav");
    other = fullfile("separated/mdx_extra_q/mixture/other.wav");
    vocals = fullfile("separated/mdx_extra_q/mixture/vocals.wav");

    make_visual(original, drums, bass, vocals, other, outFileName);