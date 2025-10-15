import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_api_flutter/widgets/movie_tile.dart';
import 'package:provider/provider.dart';

import '../providers/media_provider.dart';
import '../models/media_dto.dart';


class MediaGalleryPage extends StatefulWidget {
  const MediaGalleryPage({super.key});

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách media khi trang được mở
    Future.microtask(() => context.read<MediaProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<MediaProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: pv.loading
          ? const Center(child: CircularProgressIndicator())
          : pv.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Lỗi: ${pv.error}', style: const TextStyle(color: Colors.white)),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // ====== BANNER (SliverAppBar) ======
                    SliverAppBar(
                      backgroundColor: Colors.black,
                      pinned: true,
                      floating: false,
                      expandedHeight: 240,
                      centerTitle: false,
                      // ✅ ĐỔI MÀU NÚT BACK VÀ CÁC ICON KHÁC THÀNH MÀU TRẮNG
                      iconTheme: const IconThemeData(color: Colors.white),
                      title: const Text(
                        'Phim Lậu 🎬', 
                          style: TextStyle(fontWeight: FontWeight.w700,
                          color: Colors.white
                        ),
                      ),
                      // ✅ SỬ DỤNG BANNER CỐ ĐỊNH TỪ ASSETS
                      flexibleSpace: const FlexibleSpaceBar(
                        background: _Banner(),
                      ),
                    ),

                    // ====== LƯỚI POSTER ======
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.66,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final m = pv.items[index];
                            return MediaTile(media: m);
                          },
                          childCount: pv.items.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Widget riêng cho Banner để hiển thị ảnh từ assets
class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ HIỂN THỊ ẢNH NỀN BANNER TỪ THƯ MỤC ASSETS
        Image.asset(
          'assets/images/banner.png', // <-- Đường dẫn đến ảnh của bạn
          fit: BoxFit.cover,
          // Xử lý lỗi nếu không tìm thấy file ảnh
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF141414),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, color: Colors.white24, size: 64),
                  SizedBox(height: 8),
                  Text('Không tìm thấy banner.png', style: TextStyle(color: Colors.white24)),
                ],
              ),
            );
          },
        ),

        // Lớp phủ màu tối để làm nổi bật text (nếu có)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent, Colors.black87],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}