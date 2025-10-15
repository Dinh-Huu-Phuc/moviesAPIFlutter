class Env {
  // Android emulator dùng 10.0.2.2, iOS simulator dùng localhost
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5099',
  );
}
