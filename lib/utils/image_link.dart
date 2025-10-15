/// Trả về URL ảnh trực tiếp nếu dán link từ Google Images / redirect.
/// Giữ nguyên nếu đã là ảnh trực tiếp. Trả null nếu không hợp lệ.
String? normalizeImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;

  final u = Uri.tryParse(s);
  if (u == null) return null;

  // Không hỗ trợ data: URI
  if (u.scheme == 'data') return null;

  // Nếu là thumbnail/mirror của Google thì vẫn là ảnh thật
  if (u.host.contains('gstatic.com') ||
      u.host.contains('googleusercontent.com')) {
    return s;
  }

  // Trường hợp 1: /imgres?imgurl=<đường-ảnh>&imgrefurl=...
  if (u.host.contains('google.') && u.path == '/imgres') {
    final img = u.queryParameters['imgurl'];
    if (img != null && img.isNotEmpty) return img;
  }

  // Trường hợp 2: /url?url=<đường-ảnh-hoặc-trang>
  if (u.host.contains('google.') && u.path == '/url') {
    final real = u.queryParameters['url'];
    if (real != null && real.isNotEmpty) {
      // nếu url thực là trang HTML chứ không phải ảnh, vẫn trả về để validator lọc tiếp
      return real;
    }
  }

  // Còn lại, trả về nguyên gốc
  return s;
}

/// Kiểm tra có phải URL ảnh "trực tiếp" có thể tải không (http/https + có host).
bool isLikelyDirectImageUrl(String? url) {
  if (url == null) return false;
  final u = Uri.tryParse(url);
  if (u == null) return false;
  final ok = (u.isScheme('http') || u.isScheme('https')) && u.host.isNotEmpty;
  return ok;
}
