final window = _DummyWindow();

class _DummyWindow {
  final navigator = _DummyNavigator();
}

class _DummyNavigator {
  final mediaDevices = _DummyMediaDevices();
}

class _DummyMediaDevices {
  Future<Object> getUserMedia(Map<String, bool> constraints) async => Object();
}