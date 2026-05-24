import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuideNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Por defecto encendido

  void toggle() => state = !state;
}

final guideProvider = NotifierProvider<GuideNotifier, bool>(() => GuideNotifier());
