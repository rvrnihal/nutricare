import 'smartwatch_service.dart';

class WatchWorkoutSyncService {
  /// Legacy entry point retained for compatibility.
  static Future<void> syncWorkoutFromWatch() async {
    final connected = await SmartwatchService.connectToHealthPlatform();
    if (!connected) return;
    await SmartwatchService.syncTodayMetrics();
  }
}
