import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_dto.dart';
import 'media_player_page.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaInfoDTO media;
  const MediaDetailPage({super.key, required this.media});

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  static const _maxStars = 5;
  double _rating = 0;

  bool get _isVideo {
    final ext = (widget.media.fileExtension).toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov') ||
           ext.endsWith('.m4v') || ext.endsWith('.webm');
  }

  // ✅ CẬP NHẬT GETTER NÀY
  String get _title {
    // Ưu tiên 1: Lấy từ trường meta 'title'
    if (widget.media.title != null && widget.media.title!.trim().isNotEmpty) {
      return widget.media.title!.trim();
    }
    // Ưu tiên 2: Lấy từ mô tả file
    final d = widget.media.fileDescription?.trim();
    if (d != null && d.isNotEmpty) return d;
    
    // Fallback: Lấy từ tên file (bỏ đuôi)
    final name = widget.media.fileName;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  // ✅ THÊM GETTER NÀY
  String get _intro {
    // Ưu tiên 1: Lấy từ trường meta 'intro'
    if (widget.media.intro != null && widget.media.intro!.trim().isNotEmpty) {
      return widget.media.intro!.trim();
    }
    // Ưu tiên 2: Lấy từ mô tả file
    if (widget.media.fileDescription?.trim().isNotEmpty == true) {
      return widget.media.fileDescription!.trim();
    }
    // Fallback
    return 'Chưa có mô tả.';
  }

  Future<void> _loadRating() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _rating = sp.getDouble('media_rating_${widget.media.id}') ?? 0;
    });
  }

  Future<void> _saveRating(double v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('media_rating_${widget.media.id}', v);
    setState(() => _rating = v);
  }

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  @override
  Widget build(BuildContext context) {
    final thumb = widget.media.thumbnailUrl;
    final url = widget.media.fileUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 550, // Bạn có thể tăng giá trị này
            title: const Text(''),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null && thumb.isNotEmpty)
                    Image.network(thumb, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[900]),
                    )
                  else
                    Container(color: Colors.grey[900]),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title, // <-- Đã dùng getter mới
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10, borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isVideo ? 'VIDEO' : 'IMAGE',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (widget.media.fileExtension).toUpperCase(),
                        style: const TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ✅ CẬP NHẬT LẠI WIDGET NÀY
                  Text(
                    _intro, // <-- Dùng getter mới
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (_isVideo)
                        ElevatedButton.icon(
                          onPressed: () {
                            if (url != null && url.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MediaPlayerPage(videoUrl: url),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Không tìm thấy URL của video.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Xem ngay'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () {
                            if (url != null && url.isNotEmpty) {
                                showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.black,
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Xem ảnh'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Đánh giá', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_maxStars, (i) {
                      final idx = i + 1;
                      final filled = idx <= _rating;
                      return IconButton(
                        onPressed: () => _saveRating(idx.toDouble()),
                        icon: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: filled ? Colors.amber : Colors.white38,
                          size: 28,
                        ),
                      );
                    }),
                  ),
                  if (_rating > 0)
                    Text('Bạn chấm: ${_rating.toStringAsFixed(0)}/$_maxStars',
                        style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}