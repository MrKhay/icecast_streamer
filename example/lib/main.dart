import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  bool isUploading = false;
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
              FilledButton.tonal(
                onPressed: () async {
                  if (isUploading) {
                    await IcecastStreamer.cancelUploadToServer();
                    return;
                  }
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.audio);

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    setState(() {
                      isUploading = true;
                    });

                    await _icecastStreamerPlugin.uplaodFileToServer(
                      path: file.path,
                      bitrate: bitRate,
                      serverAddress: serverAddress,
                      userName: username,
                      port: serverPort,
                      mount: mount,
                      password: password,
                      onFileStreamingComplete: (successful) {
                        setState(() {
                          isUploading = false;
                        });
                      },
                      onProgress: (time, speed, bitrate, size) {
                        debugPrint(
                            "Speed: $speed Time: $time Bitrate: $bitrate Size: $size");
                      },
                    );
                  } else {
                    // User canceled the picker
                  }
                },
                child: isUploading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Upload file',
                      ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 30),
              FilledButton.tonal(
                onPressed: () async {
                  await IcecastStreamer.cancelUploadToServer();
                },
                child: const Text(
                  'Stop Upload file',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
