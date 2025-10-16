import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// --- Giả lập các nguồn video chất lượng khác nhau ---
class VideoQuality {
  final String label;
  final String url;
  VideoQuality(this.label, this.url);
}

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

  // --- Các biến trạng thái cho bộ điều khiển ---
  bool _showControls = true;
  Timer? _hideControlsTimer;
  double _currentPlaybackSpeed = 1.0;
  bool _isVideoFinished = false;
  bool _isFullScreen = false;

  // --- Các biến cho việc chọn chất lượng video ---
  late List<VideoQuality> _qualityOptions;
  late VideoQuality _selectedQuality;

  @override
  void initState() {
    super.initState();
    debugPrint('🎥 Play: ${widget.videoUrl}');

    _qualityOptions = [
      VideoQuality('1080p', widget.videoUrl.replaceAll('720p', '1080p')),
      VideoQuality('720p', widget.videoUrl),
      VideoQuality('480p', widget.videoUrl.replaceAll('720p', '480p')),
    ];
    _selectedQuality = _qualityOptions.firstWhere((q) => q.url == widget.videoUrl, orElse: () => _qualityOptions[1]);

    // Khởi tạo controller với video ban đầu
    _initializeController(_selectedQuality.url);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  
  void _initializeController(String url, {Duration startAt = Duration.zero}) {
    // Tạm thời dispose controller cũ nếu có
    if (_ready) {
      _controller.dispose();
    }
    
    // Reset trạng thái để hiển thị loading
    setState(() {
      _ready = false;
      _err = null;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        _addControllerListener();
        _controller.seekTo(startAt);
        _controller.setPlaybackSpeed(_currentPlaybackSpeed);
        _controller.play();
        
        setState(() => _ready = true);
        _startHideControlsTimer();
      }).catchError((e) {
        if (!mounted) return;
        debugPrint('Video init error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không phát được video: $e')),
        );
        setState(() => _err = e.toString());
      });
  }

  void _addControllerListener() {
    _controller.addListener(() {
      if (!_controller.value.isInitialized) return;
      
      bool isFinishedNow = _controller.value.position >= _controller.value.duration;
      if (isFinishedNow != _isVideoFinished) {
        setState(() {
          _isVideoFinished = isFinishedNow;
          if (isFinishedNow) _showControls = true;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideControlsTimer();
      else _hideControlsTimer?.cancel();
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (_controller.value.isPlaying && !_isVideoFinished) {
        setState(() => _showControls = false);
      }
    });
  }
  
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _hideControlsTimer?.cancel();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayerWidget = !_ready
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : AspectRatio(
            aspectRatio: _controller.value.aspectRatio > 0
                ? _controller.value.aspectRatio
                : 16 / 9,
            child: GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildControls(),
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen ? null : AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        title: const Text(''),
      ),
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
            : (_isFullScreen 
                ? videoPlayerWidget 
                : SafeArea(child: videoPlayerWidget)),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Column(
        children: [
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                if (_isVideoFinished) {
                  _controller.seekTo(Duration.zero);
                  _controller.play();
                } else {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                }
                _startHideControlsTimer();
              });
            },
            icon: Icon(
              _isVideoFinished
                  ? Icons.replay_circle_filled
                  : (_controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
              color: Colors.white,
              size: 64,
            ),
            padding: EdgeInsets.zero,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.white54,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  color: Colors.black87,
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onSelected: (value) {
                    if (value.startsWith('speed_')) {
                      final speed = double.parse(value.substring(6));
                      setState(() {
                        _currentPlaybackSpeed = speed;
                        _controller.setPlaybackSpeed(speed);
                      });
                    } else if (value.startsWith('quality_')) {
                      final newQuality = _qualityOptions.firstWhere((q) => value.contains(q.url));
                      if (_selectedQuality.url != newQuality.url) {
                        final currentPosition = _controller.value.position;
                        _initializeController(newQuality.url, startAt: currentPosition);
                        setState(() => _selectedQuality = newQuality);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text('Tốc độ phát', style: TextStyle(color: Colors.grey[400])),
                    ),
                    _buildSpeedMenuItem(1.0, 'Chuẩn'),
                    _buildSpeedMenuItem(1.25),
                    _buildSpeedMenuItem(1.5),
                    _buildSpeedMenuItem(2.0),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      enabled: false,
                      child: Text('Chất lượng', style: TextStyle(color: Colors.grey[400])),
                    ),
                    ..._qualityOptions.map((quality) => PopupMenuItem(
                      value: 'quality_${quality.url}',
                      child: Text(
                        quality.label,
                        style: TextStyle(
                          fontWeight: _selectedQuality.url == quality.url
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ],
                ),
                IconButton(
                  icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // ✅ THÊM LẠI HÀM HELPER BỊ THIẾU
  PopupMenuItem<String> _buildSpeedMenuItem(double speed, [String? label]) {
    return PopupMenuItem(
      value: 'speed_$speed',
      child: Text(
        '${label ?? speed.toString()}x',
        style: TextStyle(
          fontWeight: _currentPlaybackSpeed == speed ? FontWeight.bold : FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}