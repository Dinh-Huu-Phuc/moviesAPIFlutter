import 'dart:io';

/// Đổi API_BASE_URL khi build:

class ApiBase {
  static final String base =
      const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5099');

  /// Ghép path vào base (giữ nguyên query)
  static Uri build(String path, [Map<String, String>? query]) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$b$p').replace(queryParameters: query ?? {});
  }

  /// Tạo URL /uploads/<name>
  static String uploads(String name) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final n = name.startsWith('/') ? name.substring(1) : name;
    return '$b/uploads/$n';
  }
}
