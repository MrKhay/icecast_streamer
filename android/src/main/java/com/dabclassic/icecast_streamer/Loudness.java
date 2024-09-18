package com.dabclassic.icecast_streamer;

public class Loudness {

    // Calculate the RMS of the audio buffer
    public static double calculateRMS(byte[] buffer) {
        long sum = 0;
        for (int i = 0; i < buffer.length; i += 2) {
            // Convert two bytes to a single short (PCM)
            int sample = (buffer[i + 1] << 8) | (buffer[i] & 0xFF);
            sum += sample * sample;
        }
        double mean = sum / (double) (buffer.length / 2);
        return Math.sqrt(mean);
    }

    // Convert RMS to dB and map to -46 dB to 0 dB range
    public static double calculateVuMeter(double rmsValue) {
        double reference = 32768.0; // Reference value for PCM-16
        double dB = 20 * Math.log10(rmsValue / reference);

        // Clamp the dB value to -46 to 0
        if (dB < -46) dB = -46;
        if (dB > 0) dB = 0;

        return dB;
    }

    static public byte[] ScaleVolume(byte[] buffer, double volume) {
        short[] shortBuffer = new short[buffer.length / 2];
        byte[] modifiedBuffer = new byte[buffer.length];

        // Convert byte buffer to short array
        for (int i = 0; i < shortBuffer.length; i++) {
            shortBuffer[i] = (short) ((buffer[i * 2] & 0xFF) | (buffer[i * 2 + 1] << 8));
        }

        // Scale each sample by the volume factor
        for (int i = 0; i < shortBuffer.length; i++) {
            shortBuffer[i] = (short) (shortBuffer[i] * volume);
        }

        // Convert back to byte array
        for (int i = 0; i < shortBuffer.length; i++) {
            modifiedBuffer[i * 2] = (byte) (shortBuffer[i] & 0xFF);
            modifiedBuffer[i * 2 + 1] = (byte) ((shortBuffer[i] >> 8) & 0xFF);
        }

        return modifiedBuffer;
    }
}
