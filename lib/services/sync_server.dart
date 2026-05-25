import 'dart:convert';
import 'dart:io';

import '../models/watch_face_config.dart';

/// A tiny HTTP server embedded in the phone app so the Wear OS watch
/// (on a separate emulator/device) can poll the current design config.
///
/// The watch reaches the phone via the Android emulator's host bridge:
///   http://10.0.2.2:8080/config
///
/// If phone is on iOS simulator and watch on Android emulator this works
/// automatically — 10.0.2.2 routes to the Mac's localhost where the iOS
/// simulator is running.
///
/// If both are on Android emulators, first run once:
///   adb -s `phone_emulator_id` forward tcp:8080 tcp:8080
class SyncServer {
  SyncServer._();
  static final instance = SyncServer._();

  static const port = 8080;

  HttpServer? _server;
  WatchFaceConfig _config = WatchFaceConfig.defaultConfig();

  /// Update the config that the watch will receive on its next poll.
  void push(WatchFaceConfig config) {
    _config = config;
  }

  Future<void> start() async {
    if (_server != null) return;

    // Load last-saved config so the server is correct even after a restart
    _config = await WatchFaceConfig.load();

    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    } catch (_) {
      // Port already in use — try to reuse it
      _server =
          await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
    }

    _server!.listen(_handle);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  void _handle(HttpRequest req) {
    req.response
      ..headers.add('Access-Control-Allow-Origin', '*')
      ..headers.contentType = ContentType.json
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode(_config.toJson()));
    req.response.close();
  }
}
