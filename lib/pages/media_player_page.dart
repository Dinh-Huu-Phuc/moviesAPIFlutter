import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPlayerPage extends StatefulWidget {
  final String videoUrl;
  const MediaPlayerPage({super.key, required this.videoUrl});

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  late VideoPlayerController _controller;
  bool _ready = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    // In URL ra console để debug
    debugPrint('🎥 Play: ${widget.videoUrl}');

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: const {'Accept': 'video/*'},
    )
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      }).catchError((e) {
        if (!mounted) return;
        debugPrint('Video init error: $e');
        
        // ✅ HIỂN THỊ SNACKBAR BÁO LỖI KHI CÓ LỖI XẢY RA
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không phát được video: $e')),
        );
        // Đồng thời cập nhật UI để hiển thị text lỗi
        setState(() => _err = e.toString());
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem video')),
      body: Center(
        child: _err != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Không phát được video.\nLỗi: $_err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : !_ready
                ? const CircularProgressIndicator()
                : AspectRatio(
                    aspectRatio: _controller.value.aspectRatio > 0
                        ? _controller.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(_controller),
                  ),
      ),
      floatingActionButton: _ready && _err == null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}