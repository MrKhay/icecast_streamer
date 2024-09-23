// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/services.dart';

import 'package:icecast_streamer/model/input_device.dart';

import 'icecast_streamer_platform_interface.dart';

class IcecastStreamer {
  /// Input device id
  final String? inputDeviceId;

  /// Stream volume Range [0.0-1.0]
  final double volume;

  /// Streaming sampleRate `default is 44100 Hz`
  final int sampleRate;

  /// PCM-16 Chunk Channel (Mono = 1 and Stero = 2) `default is Stero`
  final int numChannels;

  /// Streaming bitrate `default is 128 kbps`
  final int bitrate;

  /// Icecast Server address
  final String serverAddress;

  /// Icecast username
  final String userName;

  /// Icecast port
  final int port;

  /// Icecast mount
  final String mount;

  /// Icecast password
  final String password;

  /// Error Callback when adding PCM-16 chunk to upload stream
  final void Function(String error)? onError;

  /// Call back for when amplitude changes
  final void Function(double value)? onLoudnessChange;

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
      default:
        throw MissingPluginException(
            'No implementation found for method ${call.method}');
    }
  }

  /// IcecastFlutter Constructor
  IcecastStreamer({
    this.inputDeviceId,
    this.bitrate = 128,
    this.numChannels = 2,
    this.sampleRate = 44100,
    required this.onError,
    required this.onLoudnessChange,
    required this.onComplete,
    required this.volume,
    required this.serverAddress,
    required this.port,
    required this.password,
    required this.userName,
    required this.mount,
  }) {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  /// Starts new Stream
  ///
  Future<void> init() async {
    return IcecastStreamerPlatform.instance.init();
  }

  /// Starts new Stream
  ///
  Future<void> startStream() async {
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

  IcecastStreamer updateParameters({
    String? inputDeviceId,
    double? volume,
    int? sampleRate,
    int? numChannels,
    int? bitrate,
    String? serverAddress,
    String? userName,
    int? port,
    String? mount,
    String? password,
    void Function(String error)? onError,
    void Function(double value)? onLoudnessChange,
    void Function()? onComplete,
  }) {
    return IcecastStreamer(
      inputDeviceId: inputDeviceId ?? this.inputDeviceId,
      volume: volume ?? this.volume,
      sampleRate: sampleRate ?? this.sampleRate,
      numChannels: numChannels ?? this.numChannels,
      bitrate: bitrate ?? this.bitrate,
      serverAddress: serverAddress ?? this.serverAddress,
      userName: userName ?? this.userName,
      port: port ?? this.port,
      mount: mount ?? this.mount,
      password: password ?? this.password,
      onError: onError ?? this.onError,
      onLoudnessChange: onLoudnessChange ?? this.onLoudnessChange,
      onComplete: onComplete ?? this.onComplete,
    );
  }
}
