package com.dabclassic.icecast_streamer;

public interface FfmpegProcessListener {
    void onThreadComplete(boolean successful);

    // @params time - Milliseconds
    void onProgress(int time, double speed, double bitrate);
}
