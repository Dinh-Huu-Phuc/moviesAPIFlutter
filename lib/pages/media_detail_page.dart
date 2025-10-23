import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart'; // Đã cập nhật
import 'dart:io';

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

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = '';

  bool get _isVideo {
    final ext = (widget.media.fileExtension).toLowerCase();
    return ext.endsWith('.mp4') ||
        ext.endsWith('.mov') ||
        ext.endsWith('.m4v') ||
        ext.endsWith('.webm');
  }

  String get _title {
    if (widget.media.title != null && widget.media.title!.trim().isNotEmpty) {
      return widget.media.title!.trim();
    }
    final d = widget.media.fileDescription?.trim();
    if (d != null && d.isNotEmpty) return d;

    final name = widget.media.fileName;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }

  String get _intro {
    if (widget.media.intro != null && widget.media.intro!.trim().isNotEmpty) {
      return widget.media.intro!.trim();
    }
    if (widget.media.fileDescription?.trim().isNotEmpty == true) {
      return widget.media.fileDescription!.trim();
    }
    return 'Chưa có mô tả.';
  }

  Future<void> _loadRating() async {
    final sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _rating = sp.getDouble('media_rating_${widget.media.id}') ?? 0;
    });
  }

  Future<void> _saveRating(double v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('media_rating_${widget.media.id}', v);
    if (!mounted) return;
    setState(() => _rating = v);
  }

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

  // ✅ HÀM NÀY ĐÃ ĐƯỢC CẬP NHẬT HOÀN TOÀN
  Future<void> _downloadVideo() async {
    if (_isDownloading) return;

    final url = widget.media.fileUrl;
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy URL để tải về.')),
      );
      return;
    }

    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần cấp quyền truy cập để lưu video.'),
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = 'Đang tải... 0%';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${widget.media.fileName}';

      await Dio().download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = received / total;
              _statusMessage =
                  'Đang tải... ${(_downloadProgress * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _statusMessage = 'Đang lưu vào thư viện...';
      });

      // Thay thế ImageGallerySaver bằng SaverGallery
      // ✅ Sửa lại tên các tham số cho đúng với phiên bản mới
      final result = await SaverGallery.saveFile(
        filePath: tempPath,
        fileName: widget.media.fileName,
        skipIfExists: true, // Không lưu nếu file đã tồn tại
      );

      // Kiểm tra kết quả theo cách mới
      if (result.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tải về thành công! Đã lưu vào thư viện.'),
          ),
        );
      } else {
        throw Exception('Không thể lưu vào thư viện: ${result.errorMessage}');
      }
    } catch (e) {
      debugPrint('Lỗi tải file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tải về thất bại: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
        _statusMessage = '';
      });
    }
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
            expandedHeight: 460,
            title: const Text('Chi tiết'),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null && thumb.isNotEmpty)
                    Image.network(
                      thumb,
                      fit: BoxFit.cover,
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
                    _title,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isVideo ? 'VIDEO' : 'IMAGE',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
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
                  Text(
                    _intro,
                    style: const TextStyle(color: Colors.white70, height: 1.35),
                  ),
                  const SizedBox(height: 20),

                  if (_isDownloading)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.grey[800],
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        if (_isVideo)
                          ElevatedButton.icon(
                            onPressed: () {
                              if (url != null && url.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MediaPlayerPage(videoUrl: url),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Không tìm thấy URL của video.',
                                    ),
                                  ),
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
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.photo),
                            label: const Text('Xem ảnh'),
                          ),

                        const SizedBox(width: 12),

                        // Nút Tải về
                        if (_isVideo)
                          OutlinedButton.icon(
                            onPressed: _downloadVideo,
                            icon: const Icon(Icons.download),
                            label: const Text('Tải về'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    'Đánh giá',
                    style: TextStyle(color: Colors.white70),
                  ),
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
                    Text(
                      'Bạn chấm: ${_rating.toStringAsFixed(0)}/$_maxStars',
                      style: const TextStyle(color: Colors.white54),
                    ),
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
