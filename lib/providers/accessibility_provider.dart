import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessibilityState {
  final double textScale;
  final bool highContrast;
  final bool voiceSearch;
  final bool nightMode;
  final String language;

  AccessibilityState({
    this.textScale = 0.5,
    this.highContrast = false,
    this.voiceSearch = true,
    this.nightMode = false,
    this.language = 'Español',
  });

  AccessibilityState copyWith({
    double? textScale,
    bool? highContrast,
    bool? voiceSearch,
    bool? nightMode,
    String? language,
  }) {
    return AccessibilityState(
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      voiceSearch: voiceSearch ?? this.voiceSearch,
      nightMode: nightMode ?? this.nightMode,
      language: language ?? this.language,
    );
  }
}

class AccessibilityNotifier extends Notifier<AccessibilityState> {
  @override
  AccessibilityState build() {
    return AccessibilityState();
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
  }

  void setHighContrast(bool value) {
    state = state.copyWith(highContrast: value);
  }

  void setVoiceSearch(bool value) {
    state = state.copyWith(voiceSearch: value);
  }

  void setNightMode(bool value) {
    state = state.copyWith(nightMode: value);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void reset() {
    state = AccessibilityState();
  }
}

final accessibilityProvider = NotifierProvider<AccessibilityNotifier, AccessibilityState>(() {
  return AccessibilityNotifier();
});
