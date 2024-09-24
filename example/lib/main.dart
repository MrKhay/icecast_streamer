import 'package:flutter/material.dart';
import 'package:icecast_streamer/icecast_streamer.dart';

import 'key.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IcecastStreamer _icecastStreamerPlugin;
  final int bitRate = 128;
  final int sampleRate = 44100;
  final int numChannels = 2;
  bool isStreaming = false;
  bool isRecording = false;
  double loudness = -50;
  double volume = 1.0;

  @override
  void initState() {
    _icecastStreamerPlugin = IcecastStreamer(
      onLoudnessChange: (loudness) {
        // debugPrint("Loudness: $loudness");
        setState(() {
          this.loudness = loudness;
        });
      },
      onError: (error) {
        debugPrint("Streaming Error: $error");
      },
      onComplete: () {
        print("Streaming Completed 🟢");
      },
    );

    _icecastStreamerPlugin.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Volume: ($volume)"),
              const SizedBox(height: 30),
              FilledButton.tonal(
                onPressed: () async {
                  if (!isStreaming) {
                    await _icecastStreamerPlugin.startStream(
                      password: password,
                      userName: username,
                      volume: volume,
                      serverAddress: serverAddress,
                      mount: mount,
                      port: serverPort,
                      bitrate: bitRate,
                      sampleRate: sampleRate,
                      numChannels: numChannels,
                    );

                    setState(() {
                      isStreaming = true;
                    });
                  } else {
                    await _icecastStreamerPlugin.stopStream();

                    setState(() {
                      isStreaming = false;
                    });
                  }
                },
                child: Text(
                  isStreaming
                      ? 'Stop streaming ($loudness)'
                      : 'Start streaming ($loudness)',
                ),
              ),
              const SizedBox(height: 30),
              FilledButton.tonal(
                onPressed: () async {
                  if (!isRecording) {
                    await _icecastStreamerPlugin.startRecording();

                    setState(() {
                      isRecording = true;
                    });
                  } else {
                    var responce = await _icecastStreamerPlugin.stopRecording();
                    debugPrint("Recoding path: $responce");

                    setState(() {
                      isRecording = false;
                    });
                  }
                },
                child: Text(
                  isRecording ? 'Stop recording' : 'Start recording',
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
