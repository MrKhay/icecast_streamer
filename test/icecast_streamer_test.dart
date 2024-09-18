import 'package:flutter_test/flutter_test.dart';
import 'package:icecast_streamer/icecast_streamer.dart';
import 'package:icecast_streamer/icecast_streamer_platform_interface.dart';
import 'package:icecast_streamer/icecast_streamer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIcecastStreamerPlatform
    with MockPlatformInterfaceMixin
    implements IcecastStreamerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final IcecastStreamerPlatform initialPlatform = IcecastStreamerPlatform.instance;

  test('$MethodChannelIcecastStreamer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIcecastStreamer>());
  });

  test('getPlatformVersion', () async {
    IcecastStreamer icecastStreamerPlugin = IcecastStreamer();
    MockIcecastStreamerPlatform fakePlatform = MockIcecastStreamerPlatform();
    IcecastStreamerPlatform.instance = fakePlatform;

    expect(await icecastStreamerPlugin.getPlatformVersion(), '42');
  });
}
