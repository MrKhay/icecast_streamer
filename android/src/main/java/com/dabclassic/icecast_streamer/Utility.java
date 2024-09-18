package com.dabclassic.icecast_streamer;

import android.util.Log;

import java.io.File;
import java.io.IOException;

public class Utility {
    static public void CreateNamedPipe(String pipePath) {
        File pipe = new File(pipePath);
        if (!pipe.exists()) {
            try {
                Runtime.getRuntime().exec("mkfifo " + pipePath).waitFor();
            } catch (IOException | InterruptedException e) {
                Log.i("FFmpeg", "(1) " + e.getMessage());
                e.printStackTrace();
            }
        }
    }


    static      public void DeletePipe(String path) {
        File pipe = new File(path);
        if (pipe.exists()) {
            try {
                pipe.delete();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
