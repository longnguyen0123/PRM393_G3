/// Base URL cho API. Tự chọn theo platform:
/// - Web / iOS Simulator / Desktop: localhost
/// - Android Emulator: 10.0.2.2 (trỏ tới host machine)
String get apiBaseUrl => 'http://localhost:3000/api';
