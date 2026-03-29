import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized Analytics Service
class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  static const bool _isTestMode = kDebugMode;

  /// Initialize analytics
  static Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      if (_isTestMode) {
        debugPrint('✅ Firebase Analytics initialized');
      }
    } catch (e) {
      debugPrint('❌ Analytics initialization error: $e');
    }
  }

  /// Helper method to safely log events
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      if (_isTestMode) {
        debugPrint('📊 Analytics Event: $name');
        debugPrint('   Parameters: $parameters');
      }
    } catch (e) {
      debugPrint('❌ Analytics error for event "$name": $e');
    }
  }

  static Future<void> trackAppOpen() async {
    await _analytics.logAppOpen();
  }
}
