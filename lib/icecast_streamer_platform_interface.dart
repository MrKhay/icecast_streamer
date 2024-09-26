import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'icecast_streamer_method_channel.dart';

abstract class IcecastStreamerPlatform extends PlatformInterface {
  /// Constructs a IcecastStreamerPlatform.
  IcecastStreamerPlatform() : super(token: _token);

  static final Object _token = Object();

  static IcecastStreamerPlatform _instance = MethodChannelIcecastStreamer();

  /// The default instance of [IcecastStreamerPlatform] to use.
  ///
  /// Defaults to [MethodChannelIcecastStreamer].
  static IcecastStreamerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IcecastStreamerPlatform] when
  /// they register themselves.
  static set instance(IcecastStreamerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startStream({
    String? inputDeviceId,
    required int bitrate,
    required double volume,
    required int numChannels,
    required int sampleRate,
    required String userName,
    required int port,
    required String password,
    required String mount,
    required String serverAddress,
  }) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> stopStream() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startRecording() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> stopRecording() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Map>> getInputDevices() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> cancelUploadToServer() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> uploadFileToServer({
    required String path,
    required int bitrate,
    required String userName,
    required int port,
    required String password,
    required String mount,
    required String serverAddress,
  }) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> updateVolume(double value) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
