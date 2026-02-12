import 'package:flutter/services.dart';

/// Centralised haptic & system sound feedback.
class FeedbackService {
  FeedbackService._();

  static void lightTap() => HapticFeedback.lightImpact();
  static void mediumTap() => HapticFeedback.mediumImpact();
  static void heavyTap() => HapticFeedback.heavyImpact();
  static void selectionClick() => HapticFeedback.selectionClick();

  /// Navigation tap – light haptic + system click.
  static void nav() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Success feedback – double light tap.
  static void success() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Error / warning feedback.
  static void error() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.mediumImpact();
    });
  }

  /// Pull-to-refresh threshold reached.
  static void refreshThreshold() => HapticFeedback.selectionClick();

  /// Data loaded after sync.
  static void dataLoaded() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }
}
