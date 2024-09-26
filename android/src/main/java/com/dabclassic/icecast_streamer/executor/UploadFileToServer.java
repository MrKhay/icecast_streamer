package com.dabclassic.icecast_streamer.executor;

import android.app.Activity;
import android.util.Log;

import com.arthenica.mobileffmpeg.FFmpeg;
import com.dabclassic.icecast_streamer.FfmpegProcessListener;
import com.arthenica.mobileffmpeg.ExecuteCallback;
import com.arthenica.mobileffmpeg.Config;

public class UploadFileToServer implements Runnable {
    private final FfmpegProcessListener listener;
    private final String TAG = "FFmpeg";
    private final String path;
    private final int bitrate;
    private final String userName;
    private final int port;
    private final String password;
    private final String mount;
    private final String serverAddress;

    private final Activity activity;

    public UploadFileToServer(FfmpegProcessListener listener, Activity activity, String path, int bitrate, String userName, int port, String password, String mount, String serverAddress) {
        this.bitrate = bitrate;
        this.listener = listener;
        this.path = path;
        this.userName = userName;
        this.port = port;
        this.password = password;
        this.mount = mount;
        this.serverAddress = serverAddress;
        this.activity = activity;
    }

    @Override
    public void run() {
        String[] command = {
                "-re",  // Read the input file at its native frame rate (useful for streaming).
                "-i", path,  // Input the audio file instead of a named pipe
                "-c:a", "libmp3lame",  // Use the MP3 codec (LAME) for output
                "-b:a", bitrate + "k",  // Set the bitrate for MP3
                "-f", "mp3",  // Set the output format to MP3
                "icecast://" + userName + ":" + password + "@" + serverAddress + ":" + port + mount
        };

        // Execute FFmpeg asynchronously to capture progress
        FFmpeg.executeAsync(command, new ExecuteCallback() {
            @Override
            public void apply(long executionId, int returnCode) {
                // This is executed when FFmpeg execution finishes
                Log.i(TAG,"FFmpeg finished with return code: " + returnCode);

                // Notify listener when thread finishes
                if (listener != null) {

                    activity.runOnUiThread(() -> listener.onThreadComplete(returnCode == 0));
                }
            }
        });


        // Set a statistics callback to monitor the progress in detail
        Config.enableStatisticsCallback(statistics -> {
            int timeInSeconds = statistics.getTime() / 1000;  // time is in milliseconds
            double bitrate = statistics.getBitrate();
            double speed = statistics.getSpeed(); // Speed as provided by statistics
            long sizeInBytes = statistics.getSize(); // Speed as provided by statistics

            // Convert size to kilobytes or megabytes for easier readability
            double sizeInKilobytes = sizeInBytes / 1024.0;

            activity.runOnUiThread(() -> listener.onProgress(timeInSeconds, speed, bitrate,sizeInKilobytes));
        });
    }
}
