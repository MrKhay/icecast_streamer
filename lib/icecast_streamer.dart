// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/services.dart';

import 'package:icecast_streamer/model/input_device.dart';

import 'icecast_streamer_platform_interface.dart';

class IcecastStreamer {
  /// Error Callback when adding PCM-16 chunk to upload stream
  final void Function(String error)? onError;

  /// Call back for when amplitude changes
  final void Function(double value)? onLoudnessChange;

  /// Call back for when file streaming ends
  void Function(bool successful)? onFileStreamingComplete;

  /// Call back for streaming progress
  void Function(int time, double speed, double bitrate, double size)?
      onProgress;

  ///  Callback for when streaming ends with no error
  final void Function()? onComplete;

  static const MethodChannel _channel = MethodChannel('icecast_streamer');

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onError":
        String error = call.arguments['error'];
        onError?.call(error);
        break;
      case "onComplete":
        onComplete?.call();
        break;
      case "onLoudnessChange":
        double value = call.arguments['value'];
        onLoudnessChange?.call(value);
        break;
      case "onFileStreamingComplete":
        bool successful = bool.tryParse(call.arguments['successful']) ?? false;
        onFileStreamingComplete?.call(successful);
        break;
      case "onStreamingProgress":
        double speed = double.tryParse(call.arguments['speed']) ?? 0.0;
        int time = int.tryParse(call.arguments['time']) ?? 0;
        double bitrate = double.tryParse(call.arguments['bitrate']) ?? 0.0;
        double size = double.tryParse(call.arguments['size']) ?? 0.0;
        onProgress?.call(time, speed, bitrate, size);
        break;
      default:
        throw MissingPluginException(
            'No implementation found for method ${call.method}');
    }
  }

  /// IcecastFlutter Constructor
  IcecastStreamer({this.onComplete, this.onError, this.onLoudnessChange}) {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  /// Starts new Stream
  ///
  Future<void> init() async {
    return IcecastStreamerPlatform.instance.init();
  }

  /// Starts new Stream
  ///
  Future<void> startStream({
    /// Input device id
    String? inputDeviceId,

    /// Stream volume Range [0.0-1.0]
    required double volume,

    /// Streaming sampleRate `default is 44100 Hz`
    int sampleRate = 44100,

    /// PCM-16 Chunk Channel (Mono = 1 and Stero = 2) `default is Stero`
    int numChannels = 2,

    /// Streaming bitrate `default is 128 kbps`
    required int bitrate,

    /// Icecast Server address
    required String serverAddress,

    /// Icecast username
    required String userName,

    /// Icecast port
    required int port,

    /// Icecast mount
    required String mount,

    /// Icecast password
    required String password,
  }) async {
    await IcecastStreamerPlatform.instance.startStream(
      inputDeviceId: inputDeviceId,
      volume: volume,
      bitrate: bitrate,
      sampleRate: sampleRate,
      numChannels: numChannels,
      userName: userName,
      port: port,
      password: password,
      mount: mount,
      serverAddress: serverAddress,
    );
  }

  /// Stop stream to ICECAST
  ///
  Future<String?> stopStream() async {
    return await IcecastStreamerPlatform.instance.stopStream();
  }

  /// Get all connected [InputDevice]
  static Future<List<InputDevice>> getInputDevices() async {
    var responce = await IcecastStreamerPlatform.instance.getInputDevices();

    return responce.map(InputDevice.fromMap).toList();
  }

  /// Uplaod file to icecast
  /// returns true when no error
  Future<void> uplaodFileToServer({
    /// Callback for streaming stats
    void Function(int time, double speed, double bitrate, double size)?
        onProgress,

    /// Callback for when streaming ends
    void Function(bool successful)? onFileStreamingComplete,

    ///  Path to file to be uploaded
    required String path,

    /// Streaming bitrate `default is 128 kbps`
    required int bitrate,

    /// Icecast Server address
    required String serverAddress,

    /// Icecast username
    required String userName,

    /// Icecast port
    required int port,

    /// Icecast mount
    required String mount,

    /// Icecast password
    required String password,
  }) async {
    // init progress listener
    this.onProgress = onProgress;
    this.onFileStreamingComplete = onFileStreamingComplete;
    return IcecastStreamerPlatform.instance.uploadFileToServer(
      path: path,
      bitrate: bitrate,
      serverAddress: serverAddress,
      userName: userName,
      port: port,
      mount: mount,
      password: password,
    );
  }

  /// Stop upload to server
  static Future<void> cancelUploadToServer() =>
      IcecastStreamerPlatform.instance.cancelUploadToServer();

  /// Update streaming volume
  Future<void> updateVolume(double value) =>
      IcecastStreamerPlatform.instance.updateVolume(value);

  /// Start recording
  Future<void> startRecording() =>
      IcecastStreamerPlatform.instance.startRecording();

  /// Stop recording
  ///
  /// @returns path to recording
  Future<String?> stopRecording() =>
      IcecastStreamerPlatform.instance.stopRecording();

  /// Close and fress all resources
  Future<void> dispose() => IcecastStreamerPlatform.instance.dispose();
}
