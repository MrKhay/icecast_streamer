import 'package:flutter/services.dart';
import 'package:icecast_streamer/model/input_device.dart';

import 'icecast_streamer_platform_interface.dart';

class IcecastStreamer {
  /// Input device id
  final String? _inputDeviceId;

  /// Stream volume Range [0.0-1.0]
  final double _volume;

  /// Streaming sampleRate `default is 44100 Hz`
  final int _sampleRate;

  /// PCM-16 Chunk Channel (Mono = 1 and Stero = 2) `default is Stero`
  final int _numChannels;

  /// Streaming bitrate `default is 128 kbps`
  final int _bitrate;

  /// Icecast Server address
  final String _serverAddress;

  /// Icecast username
  final String _userName;

  /// Icecast port
  final int _port;

  /// Icecast mount
  final String _mount;

  /// Icecast password
  final String _password;

  /// Error Callback when adding PCM-16 chunk to upload stream
  final void Function(String error)? _onError;

  /// Call back for when amplitude changes
  final void Function(double value)? _onLoudnessChange;

  ///  Callback for when streaming ends with no error
  final void Function()? _onComplete;

  static const MethodChannel _channel = MethodChannel('icecast_streamer');

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onError":
        String error = call.arguments['error'];
        _onError?.call(error);
        break;
      case "onComplete":
        _onComplete?.call();
        break;
      case "onLoudnessChange":
        double value = call.arguments['value'];
        _onLoudnessChange?.call(value);
        break;
      default:
        throw MissingPluginException(
            'No implementation found for method ${call.method}');
    }
  }

  /// IcecastFlutter Constructor
  IcecastStreamer({
    String? inputDeivceId,
    int bitrate = 128,
    int numChannels = 2,
    int sampleRate = 44100,
    void Function(String)? onError,
    void Function(double)? onLoudnessChange,
    void Function()? onComplete,
    required double volume,
    required String serverAddress,
    required int port,
    required String password,
    required String userName,
    required String mount,
  })  : _onComplete = onComplete,
        _onError = onError,
        _volume = volume,
        _password = password,
        _inputDeviceId = inputDeivceId,
        _onLoudnessChange = onLoudnessChange,
        _mount = mount,
        _port = port,
        _userName = userName,
        _serverAddress = serverAddress,
        _bitrate = bitrate,
        _numChannels = numChannels,
        _sampleRate = sampleRate {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  /// Starts new Stream
  ///
  Future<void> startStream() async {
    await IcecastStreamerPlatform.instance.startStream(
      inputDeviceId: _inputDeviceId,
      volume: _volume,
      bitrate: _bitrate,
      sampleRate: _sampleRate,
      numChannels: _numChannels,
      userName: _userName,
      port: _port,
      password: _password,
      mount: _mount,
      serverAddress: _serverAddress,
    );
  }

  /// Get all input devices
  ///
  /// Returns List of [InputDevice]
  Future<String?> stopStream() async {
    return await IcecastStreamerPlatform.instance.stopStream();
  }

  static Future<List<InputDevice>> getInputDevices() async {
    var responce = await IcecastStreamerPlatform.instance.getInputDevices();

    return responce.map(InputDevice.fromMap).toList();
  }

  Future<void> updateVolume(double value) =>
      IcecastStreamerPlatform.instance.updateVolume(value);
}
