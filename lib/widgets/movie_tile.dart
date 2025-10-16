// lib/widgets/movie_tile.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_api_flutter/theme/movie_form_page.dart';
import 'package:provider/provider.dart';

// Imports cho MovieTile
import '../models/movie_dto.dart';
import '../providers/movie_provider.dart';


// Imports cho MediaTile
import '../models/media_dto.dart';
import '../providers/media_provider.dart';
import '../pages/media_player_page.dart';
import '../pages/media_detail_page.dart';

// ====================================================================
// PHẦN CODE CŨ CỦA BẠN (GIỮ NGUYÊN)
// ====================================================================

const String kApiBase = 'http://10.0.2.2:5099';

String? normalizePoster(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('/')) return '$kApiBase$url';
  if (!url.startsWith('http')) return '$kApiBase/$url';
  final u = Uri.tryParse(url);
  if (u == null) return null;
  if (u.host.contains('googleusercontent.com') ||
      u.host.contains('gstatic.com')) {
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
      subtitle: Text(
        '⭐ ${movie.rating?.toString() ?? 'N/A'} • ${movie.studioName}',
      ),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
                context.read<MovieProvider>().refresh();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xóa phim?'),
                  content: Text(
                    'Bạn có chắc muốn xóa "${movie.title ?? 'không tên'}"?',
                  ),
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã xóa phim')));
              }
            },
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// ✅ PHẦN CODE MỚI ĐƯỢC CẬP NHẬT
// ====================================================================

class MediaTile extends StatelessWidget {
  final MediaInfoDTO media;
  const MediaTile({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final pv = context.read<MediaProvider>();
    final isVideo = pv.isVideo(media);
    final posterUrl = pv.posterOf(media);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MediaDetailPage(media: media)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Thumbnail được giữ nguyên
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: posterUrl,
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
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // ✅ TIÊU ĐỀ ĐƯỢC CẬP NHẬT
          Text(
            (media.title?.trim().isNotEmpty == true)
                ? media.title!.trim()
                : (media.fileDescription?.trim().isNotEmpty == true)
                    ? media.fileDescription!.trim()
                    // Lấy tên file và bỏ phần mở rộng
                    : media.fileName.split('.').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          // ✅ THÊM THỂ LOẠI (GENRE) NẾU CÓ
          if (media.genre != null && media.genre!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                media.genre!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}