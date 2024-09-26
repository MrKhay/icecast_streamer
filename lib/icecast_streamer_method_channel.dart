import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'icecast_streamer_platform_interface.dart';

/// An implementation of [IcecastStreamerPlatform] that uses method channels.
class MethodChannelIcecastStreamer extends IcecastStreamerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('icecast_streamer');

  @override
  Future<void> init() async {
    await methodChannel.invokeMethod<String?>('init');
    return;
  }

  @override
  Future<void> startStream({
    String? inputDeviceId,
    required double volume,
    required int bitrate,
    required int numChannels,
    required int sampleRate,
    required String userName,
    required int port,
    required String password,
    required String mount,
    required String serverAddress,
  }) async {
    try {
      await methodChannel.invokeMethod<String?>('startStreaming', {
        "inputDeviceId": inputDeviceId,
        "volume": volume,
        "bitrate": bitrate,
        "numChannels": numChannels,
        "sampleRate": sampleRate,
        "userName": userName,
        "port": port,
        "mount": mount,
        "password": password,
        "serverAddress": serverAddress,
      });
      return;
    } on PlatformException catch (e) {
      debugPrint("Icecast FLutter Error: ${e.code}, ${e.message}");
    }
  }

  @override
  Future<String?> stopStream() async {
    try {
      await methodChannel.invokeMethod<String?>('stopStreaming');
    } on PlatformException catch (e) {
      debugPrint("Error: ${e.code}, ${e.message}");
      return e.message;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getInputDevices() async {
    try {
      var responce =
          await methodChannel.invokeMethod<List<dynamic>?>('getInputDevices') ??
              [];

      // Convert the dynamic list to a List<Map<String, String>>
      return List<Map<String, dynamic>>.from(
        responce.map((device) => Map<String, dynamic>.from(device)),
      );
    } on PlatformException catch (e) {
      debugPrint("Error: ${e.code}, ${e.message}");
      return [];
    }
  }

  @override
  Future<void> updateVolume(double value) async {
    await methodChannel
        .invokeMethod<String?>('updateVolume', {"volume": value});
    return;
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod<String?>('dispose');
    return;
  }

  @override
  Future<void> startRecording() async {
    await methodChannel.invokeMethod<String?>('startRecording');
    return;
  }

  @override
  Future<String?> stopRecording() async {
    var recordingPath =
        await methodChannel.invokeMethod<String?>('stopRecording');
    return recordingPath;
  }

  @override
  Future<void> uploadFileToServer({
    required String path,
    required int bitrate,
    required String userName,
    required int port,
    required String password,
    required String mount,
    required String serverAddress,
  }) async {
    await methodChannel.invokeMethod('uploadFileToServer', {
      "path": path,
      "bitrate": bitrate,
      "userName": userName,
      "port": port,
      "password": password,
      "mount": mount,
      "serverAddress": serverAddress
    });

    return;
  }

  @override
  Future<void> cancelUploadToServer() async {
    await methodChannel.invokeMethod<String?>('cancelUploadToServer');
    return;
  }
}
