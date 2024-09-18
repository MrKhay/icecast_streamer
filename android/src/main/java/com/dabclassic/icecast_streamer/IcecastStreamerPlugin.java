package com.dabclassic.icecast_streamer;

import static io.flutter.util.PathUtils.getFilesDir;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.media.AudioDeviceInfo;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.arthenica.mobileffmpeg.FFmpeg;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * IcecastStreamerPlugin
 */
public class IcecastStreamerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private Context context;
    private Activity activity;
    private MethodChannel channel;

    private String INPUT_DEVICE_ID;  // Sample rate in Hz
    private int SAMPLE_RATE = 44100;  // Sample rate in Hz
    private java.lang.Double VOLUME = 0.7;  // PCM-16 amplitude
    private int BIT_RATE = 128;  // Bit rate in kbps
    private int NUM_CHANNELS = 2;  // Channel
    private String ICECAST_PASSWORD;
    private String ICECAST_USERNAME;
    private int ICECAST_PORT;
    private String ICECAST_MOUNT;
    private String ICECAST_SERVER_ADDRESS;

    private FileOutputStream fos1;
    private FileOutputStream fos2;
    private Thread streamingThread;
    private Thread recorderThread;

    private String pipePath1;
    private String pipePath2;

    private AudioRecord recorder;
    private boolean isStreaming = false;
    private boolean isRecording = false;
    private boolean isStreamTwoActive = false;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "icecast_streamer");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @RequiresApi(api = Build.VERSION_CODES.P)
    @SuppressLint("MissingPermission")
    private void startStreaming() {
        Log.i("FFmpeg", "Called startStreaming ");
        try {

            // Get the app's private storage directory and create a named pipe
            File storageDir = new File(getFilesDir(context));
            pipePath1 = new File(storageDir, "audio_pipe_one").getAbsolutePath();
            pipePath2 = new File(storageDir, "audio_pipe_tow").getAbsolutePath();
            Utility.CreateNamedPipe(pipePath1);
            Utility.CreateNamedPipe(pipePath2);


            // Initialize Pipe 2
            new Thread(() -> {
                try {
                    fos2 = new FileOutputStream(pipePath2);
                } catch (FileNotFoundException e) {
                    Log.e("FFmpeg", "Failed to open output stream 2", e);
                }
            }).start();

            // Initialize and start Recorder
            recorderThread = new Thread(() -> {
                int BUFFER_SIZE = AudioRecord.getMinBufferSize(
                        SAMPLE_RATE, AudioFormat.CHANNEL_IN_STEREO, AudioFormat.ENCODING_PCM_16BIT);

                try {
                    AudioDeviceInfo deviceInfo = DeviceUtils.deviceInfoFromId(context, INPUT_DEVICE_ID);
                    recorder = new AudioRecord.Builder()
                            .setAudioSource(MediaRecorder.AudioSource.MIC)
                            .setAudioFormat(new AudioFormat.Builder()
                                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                    .setSampleRate(SAMPLE_RATE)
                                    .setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
                                    .build())
                            .setBufferSizeInBytes(BUFFER_SIZE)
                            .build();

                    if (deviceInfo != null) {
                        recorder.setPreferredDevice(deviceInfo);
                    }


                    if (recorder.getState() != AudioRecord.STATE_INITIALIZED) {
                        logError("Audio Record can't initialize!");
                        Log.e("FFmpeg", "Audio Record can't initialize!");
                        return;
                    }

                    recorder.startRecording();
                    // Initialize Pipe 1
                    fos1 = new FileOutputStream(pipePath1);
                    byte[] buffer = new byte[BUFFER_SIZE];
                    isRecording = true;
                    while (isRecording) {
                        int read = recorder.read(buffer, 0, buffer.length);
                        if (read > 0) {

                            // Scale the volume
                            byte[] modifiedBuffer = Loudness.ScaleVolume(buffer, VOLUME); // 'volume' is a float between 0.0 and 1.0

                            fos1.write(modifiedBuffer, 0, read);

                            // Calculate RMS
                            double rmsValue = Loudness.calculateRMS(modifiedBuffer);

                            // Calculate dB value for VU meter
                            double dBValue = Loudness.calculateVuMeter(rmsValue);

                            activity.runOnUiThread(() -> updateLoudness(dBValue));


                        }
                    }
                } catch (Exception e) {
                    Log.e("FFmpeg", "Start recorder", e);
                }
            });


            recorderThread.start();
            try {
                Thread.sleep(1000); // sleep for 1sec
            } catch (Exception e) {
            }


            // Start streaming thread
            streamingThread = new Thread(() -> {
                String[] command = {
                        "-thread_queue_size", "812",
                        "-f", "s16le",  // PCM 16-bit
                        "-ar", String.valueOf(SAMPLE_RATE),  // Set the sample rate
                        "-ac", String.valueOf(NUM_CHANNELS),  // Set the channel count
                        "-i", pipePath1,  // Input from the named pipe
                        "-c:a", "libmp3lame",  // Use the MP3 codec (LAME) for output
                        "-b:a", BIT_RATE + "k",  // Set the bitrate for MP3
                        "-f", "mp3",  // Set the output format to MP3
                        "icecast://" + ICECAST_USERNAME + ":" + ICECAST_PASSWORD + "@" + ICECAST_SERVER_ADDRESS + ":" + ICECAST_PORT + ICECAST_MOUNT
                };


                // Run the FFmpeg process
                try {
                    FFmpeg.executeAsync(command, new ExecuteCallback());

                } catch (Exception e) {
                    Log.i("FFmpeg", "Executing FFmpeg command");
                }
            });


            isStreaming = true;
            // Start streaming thread
            streamingThread.start();

        } catch (Exception e) {
            Log.e("FFmpeg", "Streaming failed" + e.getMessage());
        }
    }


    private String stopStreaming() {
        try {
            isStreaming = false;
            isRecording = false;

            if (recorder != null) {
                recorder.stop();
                recorder.release();
                recorder = null;
            }

            if (recorderThread != null) {
                recorderThread.interrupt();
                recorderThread = null;

            }

            if (streamingThread != null) {
                streamingThread.interrupt();
                streamingThread = null;

            }
            FFmpeg.cancel();
            if (fos1 != null) {
                fos1.close();
                fos1 = null;
            }
            if (fos2 != null) {
                fos2.close();
                fos2 = null;
            }
            Utility.DeletePipe(pipePath1);
            Utility.DeletePipe(pipePath2);
            return null;
        } catch (Exception e) {
            return "Stopping stream failed: " + e.getMessage();
        }
    }

    void logError(String msg) {
        // Create a map to hold error information
        Map<String, String> errorInfo = new HashMap<>();
        errorInfo.put("error", msg);  // Key should match what Dart expects
        channel.invokeMethod("onError", errorInfo);
    }

    void updateLoudness(Double value) {
        // Create a map to hold  information
        Map<String, Double> info = new HashMap<>();
        info.put("value", value);  // Key should match what Dart expects
        channel.invokeMethod("onLoudnessChange", info);
    }


    @RequiresApi(api = Build.VERSION_CODES.P)
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "startStreaming":
                BIT_RATE = call.argument("bitrate");
                VOLUME = call.argument("volume");
                NUM_CHANNELS = call.argument("numChannels");
                SAMPLE_RATE = call.argument("sampleRate");
                ICECAST_USERNAME = call.argument("userName");
                ICECAST_MOUNT = call.argument("mount");
                ICECAST_PASSWORD = call.argument("password");
                ICECAST_PORT = call.argument("port");
                ICECAST_SERVER_ADDRESS = call.argument("serverAddress");
                startStreaming();
                result.success(null);
                break;
            case "stopStreaming":
                String errorMsg = stopStreaming();
                result.success(errorMsg);
                break;
            case "getInputDevices":
                List<Map<String, String>> devices = DeviceUtils.listInputDevicesAsMap(context);
                result.success(devices);
                break;
            case "updateVolume":
                VOLUME = call.argument("volume");
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private class ExecuteCallback implements com.arthenica.mobileffmpeg.ExecuteCallback {
        @Override
        public void apply(long executionId, int returnCode) {
            // Handle completion
            if (returnCode == 0) {
                Log.i("FFmpeg", "Streaming completed successfully");
                channel.invokeMethod("onComplete", "Streaming completed successfully");
            } else {
                logError("Connection to Icecast failed");
                Log.e("FFmpeg", "Error in streaming with return code: " + returnCode);
            }
        }


    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }
}

