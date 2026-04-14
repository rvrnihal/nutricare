import 'smartwatch_service.dart';

class HealthSyncService {
  /// Legacy entry point retained for compatibility.
  static Future<void> syncTodayHealthData() async {
    final connected = await SmartwatchService.connectToHealthPlatform();
    if (!connected) return;
    await SmartwatchService.syncTodayMetrics();
  }
}
