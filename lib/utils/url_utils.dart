// lib/utils/url_utils.dart
bool looksLikeImageUrl(String? u) {
  if (u == null || u.isEmpty) return false;
  final lower = u.toLowerCase();
  return lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif');
}
