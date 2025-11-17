// lib/utils/app_analytics.dart

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AppAnalytics {
  static FirebaseAnalytics? _analytics;
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
      debugPrint('[Analytics] Firebase initialized');
    } catch (e) {
      debugPrint('[Analytics] Initialization error: $e');
    }
  }

  static Map<String, Object> _sanitizeParameters(Map<String, Object?> params) {
    return Map.fromEntries(
      params.entries
          .where((e) => e.value != null)
          .map((e) {
        final v = e.value!;
        if (v is bool) return MapEntry(e.key, v ? 1 : 0); // bool -> int
        if (v is String || v is num) return MapEntry(e.key, v);
        return MapEntry(e.key, v.toString());
      }),
    );
  }

  static Future<void> logEvent(
      String name, {
        Map<String, Object?>? parameters,
      }) async {
    debugPrint('[Analytics][$name] $parameters');
    try {
      await ensureInitialized();
      await _analytics?.logEvent(
        name: name,
        parameters: parameters == null ? null : _sanitizeParameters(parameters),
      );
    } catch (e) {
      debugPrint('[Analytics][Error] $e');
    }
  }

  static Future<void> logScreenView(
      String screenName, {
        String? screenClass,
      }) async {
    debugPrint('[Analytics][screen_view] $screenName (${screenClass ?? screenName})');
    try {
      await ensureInitialized();
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('[Analytics][ScreenViewError] $e');
    }
  }
}
