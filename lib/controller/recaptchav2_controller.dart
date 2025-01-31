import 'package:flutter/material.dart';

class RecaptchaV2Controller extends ChangeNotifier {
  bool isDisposed = false;
  List<VoidCallback> _listeners = [];

  bool _visible = false;
  bool get visible => _visible;

  void show() {
    _visible = true;
    if (!isDisposed) notifyListeners();
  }

  void hide() {
    _visible = false;
    if (!isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    //_listeners = [];
    //isDisposed = true;
    super.dispose();
  }

  @override
  void addListener(listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    //_listeners.remove(listener);
    super.removeListener(listener);
  }
}
