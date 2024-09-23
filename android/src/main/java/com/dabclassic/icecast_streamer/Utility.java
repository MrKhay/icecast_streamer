package com.dabclassic.icecast_streamer;

import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class Utility {
    static public void createNamedPipe(String pipePath) {
        File pipe = new File(pipePath);

        if (!pipe.exists()) {
            try {
                Runtime.getRuntime().exec("mkfifo " + pipePath).waitFor();
                Log.i("FFmpeg", "Pipe Created ✅");
            } catch (IOException | InterruptedException e) {
                Log.i("FFmpeg", "(1) " + e.getMessage());
                e.printStackTrace();
            }
        }
    }

    static public boolean createFile(String path) {
        File file = new File(path);

        if (!file.exists()) {
            try {
                boolean isCreated = file.createNewFile();
                return isCreated;
            } catch (IOException e) {
                Log.i("FFmpeg", "(1) " + e.getMessage());
                e.printStackTrace();
                return false;
            }
        } else {
            file.delete();
            return createFile(path); // create new file
        }
    }


    static public void DeletePipe(String path) {
        File pipe = new File(path);
        if (pipe.exists()) {
            try {
                pipe.delete();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Writes a specified duration of PCM 16-bit silence to a FileOutputStream.
     *
     * @param outputStream The FileOutputStream to write to.
     * @param durationMs   The duration of silence in milliseconds.
     * @param sampleRate   The sample rate in Hz (e.g., 44100).
     * @param numChannels  The number of audio channels (e.g., 1 for mono, 2 for stereo).
     * @throws IOException If an I/O error occurs.
     */
    public static void writePcm16Silence(FileOutputStream outputStream, int durationMs, int sampleRate, int numChannels) throws IOException {
        // Calculate the number of samples for the specified duration
        int totalSamples = (durationMs * sampleRate * numChannels) / 1000;

        // Each sample is 2 bytes (16-bit PCM)
        byte[] silenceBuffer = new byte[totalSamples * 2];

        // Write the silence buffer to the output stream
        outputStream.write(silenceBuffer);
    }


    /**
     * Generates a unique, well-formatted file name based on the current date and time.
     * The format of the filename will be: "yyyyMMdd_HHmmss" (e.g., 20240923_101501).
     *
     * @param parent    The path to the parent director
     * @param extension The extension of the file (e.g., ".pcm", ".mp3").
     * @return A unique file name as a string.
     */
    public static String generateFileName(String parent, String extension) {
        // Get the current date and time
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss", Locale.getDefault());
        Date now = new Date();
        String timestamp = formatter.format(now);

        // Return formatted file name
        return new File(parent, timestamp + extension).getAbsolutePath();
    }
}


