import 'package:flutter/material.dart';

import 'package:icecast_streamer/icecast_streamer.dart';
import 'package:icecast_streamer_example/key.dart';

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
  double loudness = -50;
  double volume = 0.0;

  @override
  void initState() {
    _icecastStreamerPlugin = IcecastStreamer(
      inputDeivceId: "18",
      password: password,
      userName: username,
      volume: volume,
      serverAddress: serverAddress,
      mount: mount,
      port: serverPort,
      bitrate: bitRate,
      sampleRate: sampleRate,
      numChannels: numChannels,
      onLoudnessChange: (loudness) {
        print("Loudness: $loudness");
        setState(() {
          this.loudness = loudness;
        });
      },
      onError: (error) {
        print("Streaming Error: $error");
      },
      onComplete: () {
        print("Streaming Completed 🟢");
      },
    );
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
                    await _icecastStreamerPlugin.startStream();

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
                child: Text(isStreaming
                    ? 'Stop streaming ($loudness)'
                    : 'Start streaming'),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      var responce =
                          await _icecastStreamerPlugin.getInputDevices();
                      print(responce);
                    },
                    icon: const Icon(Icons.plus_one),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
