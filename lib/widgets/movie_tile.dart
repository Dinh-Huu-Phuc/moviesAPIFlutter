// lib/widgets/movie_tile.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_api_flutter/theme/movie_form_page.dart';
import 'package:provider/provider.dart';

// Imports cho MovieTile
import '../models/movie_dto.dart';
import '../providers/movie_provider.dart';


// Imports cho MediaTile (mới)
import '../models/media_dto.dart';
import '../providers/media_provider.dart';
import '../pages/media_player_page.dart';


// ====================================================================
// PHẦN CODE CŨ CỦA BẠN (GIỮ NGUYÊN)
// ====================================================================

const String kApiBase = 'http://10.0.2.2:5099';

/// Xử lý URL ảnh: bóc link gốc từ Google, ghép base URL cho link tương đối.
String? normalizePoster(String? url) {
  if (url == null || url.isEmpty) return null;

  if (url.startsWith('/')) return '$kApiBase$url';
  if (!url.startsWith('http')) return '$kApiBase/$url';

  final u = Uri.tryParse(url);
  if (u == null) return null;

  if (u.host.contains('googleusercontent.com') || u.host.contains('gstatic.com')) {
    return url;
  }
  if (u.host.contains('google.') && u.path == '/imgres') {
    final img = u.queryParameters['imgurl'];
    if (img != null && img.isNotEmpty) return img;
  }
  if (u.host.contains('google.') && u.path == '/url') {
    final real = u.queryParameters['url'];
    if (real != null && real.isNotEmpty) return real;
  }
  return url;
}

class MovieTile extends StatelessWidget {
  final MovieWithCastAndStudioDTO movie;
  final VoidCallback? onTap;
  const MovieTile({super.key, required this.movie, this.onTap});

  @override
  Widget build(BuildContext context) {
    final poster = normalizePoster(movie.posterUrl);

    final leading = poster != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: poster,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                width: 50,
                height: 70,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => const Icon(Icons.movie, size: 40),
            ),
          )
        : const Icon(Icons.movie, size: 40);

    return ListTile(
      leading: leading,
      title: Text(movie.title ?? '(Không tên)'),
      subtitle: Text('⭐ ${movie.rating?.toString() ?? 'N/A'} • ${movie.studioName}'),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final ok = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieFormPage(
                    mode: MovieFormMode.edit,
                    movieId: movie.id,
                    preset: movie,
                  ),
                ),
              );
              if (ok == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật')),
                );
                context.read<MovieProvider>().refresh();
              }
            },
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xóa phim?'),
                  content: Text('Bạn có chắc muốn xóa "${movie.title ?? 'không tên'}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
              if (yes == true && context.mounted) {
                await context.read<MovieProvider>().remove(movie.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa phim')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}


// ====================================================================
// ✅ PHẦN CODE MỚI ĐƯỢC THÊM VÀO ĐÂY
// ====================================================================

class MediaTile extends StatelessWidget {
  final MediaInfoDTO media;
  const MediaTile({super.key, required this.media});

  String _titleOf(MediaInfoDTO m) {
    final t = (m.fileDescription ?? '').trim();
    if (t.isNotEmpty) return t;
    return (m.fileName ?? 'Untitled').trim();
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.read<MediaProvider>();
    final isVideo = pv.isVideo(media);
    final url = pv.urlOf(media);

    return InkWell(
      onTap: () {
        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MediaPlayerPage(videoUrl: url)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(backgroundColor: Colors.black),
                body: Center(
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      httpHeaders: const {'User-Agent': 'Mozilla/5.0'},
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white70, size: 64),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh/thumbnail
                  CachedNetworkImage(
                    imageUrl: url,
                    httpHeaders: const {'User-Agent': 'Mozilla/5.0'},
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1C1C1C),
                      child: Icon(
                        isVideo ? Icons.videocam : Icons.image,
                        color: Colors.white30,
                        size: 36,
                      ),
                    ),
                  ),
                  // Icon play nếu là video
                  if (isVideo)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
                  // Gradient đáy
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Tên phim
          Text(
            _titleOf(media),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}