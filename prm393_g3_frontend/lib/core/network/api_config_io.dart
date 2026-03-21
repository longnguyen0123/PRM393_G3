import 'dart:io' show Platform;

/// Dùng khi chạy trên mobile/desktop (có dart:io).
/// Android Emulator: 10.0.2.2, còn lại: localhost
String get apiBaseUrl =>
    Platform.isAndroid ? 'http://10.0.2.2:3000/api' : 'http://localhost:3000/api';
