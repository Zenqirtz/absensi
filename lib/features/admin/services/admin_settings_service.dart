import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class AdminSettingsService {
  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? SupabaseConfig.client : null;

  Future<Map<String, dynamic>> getSettings() async {
    final client = _client;
    if (client == null) {
      return _defaults();
    }
    try {
      final res = await client
          .from('app_settings')
          .select()
          .eq('id', 'global')
          .maybeSingle();
      if (res == null) return _defaults();
      return Map<String, dynamic>.from(res);
    } catch (_) {
      return _defaults();
    }
  }

  Future<bool> saveSettings({
    required String workStartTime,
    required int lateThresholdMinutes,
    required double officeLat,
    required double officeLng,
    required int radiusMeters,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('app_settings').upsert({
        'id': 'global',
        'work_start_time': workStartTime,
        'late_threshold_minutes': lateThresholdMinutes,
        'office_latitude': officeLat,
        'office_longitude': officeLng,
        'radius_meters': radiusMeters,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _defaults() => {
        'work_start_time': '08:00',
        'late_threshold_minutes': 15,
        'office_latitude': -6.2,
        'office_longitude': 106.816666,
        'radius_meters': 100,
      };
}
