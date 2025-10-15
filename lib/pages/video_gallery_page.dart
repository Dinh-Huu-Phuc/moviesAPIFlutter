import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/media_provider.dart';
import '../models/media_dto.dart';
import 'media_player_page.dart';

class VideoGalleryPage extends StatelessWidget {
  const VideoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<MediaProvider>();

    // Lọc ra chỉ các media là video
    final List<MediaInfoDTO> videos =
        pv.items.where((m) => pv.isVideo(m)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // nền tối
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 222, 226),
        elevation: 0,
        title: const Text(
          'Video của bạn',
          style: TextStyle(color: Colors.white70),
        ),
      ),
      body: pv.loading
          ? const Center(child: CircularProgressIndicator())
          : pv.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Lỗi: ${pv.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : videos.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có video nào.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 16 / 11,
                      ),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final m = videos[index];
                        final url = pv.urlOf(m);
                        final title = (m.fileDescription?.isNotEmpty ?? false)
                            ? m.fileDescription!
                            : m.fileName;

                        return _VideoTile(
                          title: title,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MediaPlayerPage(videoUrl: url),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F25),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            // khu thumbnail
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111418),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.videocam, size: 56, color: Colors.white70),
                  ),
                  const Positioned(
                    right: 10,
                    bottom: 10,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.play_arrow, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            // tiêu đề
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.2,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
