import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DebugTestPlayerPage extends StatefulWidget {
  const DebugTestPlayerPage({super.key});

  @override
  State<DebugTestPlayerPage> createState() => _DebugTestPlayerPageState();
}

class _DebugTestPlayerPageState extends State<DebugTestPlayerPage> {
  late VideoPlayerController _c;
  bool _ready = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    // ĐỔI TÊN FILE này thành file .mp4 mà bạn chắc chắn xem được trên Chrome (emulator):
    const url = 'http://10.0.2.2:5099/uploads/test.mp4';
    debugPrint('🎥 TEST URL: $url');

    _c = VideoPlayerController.networkUrl(Uri.parse(url),
        httpHeaders: const {'Accept': 'video/*'})
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _c.play();
      }).catchError((e) {
        if (!mounted) return;
        debugPrint('Video init error: $e');
        setState(() => _err = e.toString());
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEBUG player')),
      body: Center(
        child: _err != null
            ? Text('Không phát được video.\n$_err', textAlign: TextAlign.center)
            : !_ready
                ? const CircularProgressIndicator()
                : AspectRatio(
                    aspectRatio: _c.value.aspectRatio == 0 ? 16 / 9 : _c.value.aspectRatio,
                    child: VideoPlayer(_c),
                  ),
      ),
      floatingActionButton: _ready
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _c.value.isPlaying ? _c.pause() : _c.play();
                });
              },
              child: Icon(_c.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}
