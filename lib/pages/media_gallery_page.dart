import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_api_flutter/widgets/movie_tile.dart';
// import 'package:movie_api_flutter/widgets/movie_tile.dart'; // Lỗi sai chính tả, sửa lại

import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../providers/media_provider.dart';
import '../models/media_dto.dart';

import '../pages/media_player_page.dart';

// ✅ BƯỚC 1: Thêm import cho trang bạn muốn chuyển đến khi bấm nút
// import 'package:movie_api_flutter/pages/another_movie_page.dart'; // <-- Thay bằng trang của bạn

// Dữ liệu phim giả để demo dropdown
class _MovieOption {
  final int id;
  final String name;
  _MovieOption(this.id, this.name);
}

class MediaGalleryPage extends StatefulWidget {
  const MediaGalleryPage({super.key});

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  
  // Biến cho việc tìm kiếm
  final _searchCtrl = TextEditingController();
  Timer? _deb; // Timer cho debounce

  // Dữ liệu phim giả
  final _fakeMovies = <_MovieOption>[
    _MovieOption(0, 'Tất cả phim'),
    _MovieOption(1, 'Inception'),
    _MovieOption(2, 'Forrest Gump'),
    _MovieOption(3, 'Hoang Thiên Đế'),
  ];
  int _selectedMovieId = 0;
  int _bottomIndex = 0; // Index cho bottom nav

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<MediaProvider>().fetchMore();
      }
    });
    
    // Listener để hiện/ẩn nút clear trong ô tìm kiếm
    _searchCtrl.addListener(() => setState(() {}));

    // Tải dữ liệu lần đầu
    Future.microtask(() {
      final pv = context.read<MediaProvider>();
      pv.setType(MediaTypeFilter.all);
      pv.refresh();
    });
  }

  @override
  void dispose() {
    _deb?.cancel();
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ✅ BƯỚC 2: Cập nhật hàm xử lý khi bấm nút
  void _applyTypeFromBottomNav(int idx) {
    // Nếu người dùng bấm vào nút "Vào trang phim" (index = 3)
    if (idx == 3) {
      // Thì điều hướng đến trang mới
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const AnotherMoviePage()), // <-- Thay bằng trang của bạn
      // );
      print("Đã bấm nút chuyển trang!");
      return; // Dừng hàm ở đây, không làm gì thêm
    }
    
    // Nếu không phải nút mới thì giữ nguyên logic cũ
    setState(() => _bottomIndex = idx);
    final pv = context.read<MediaProvider>();
    switch (idx) {
      case 1: pv.setType(MediaTypeFilter.video); break;
      case 2: pv.setType(MediaTypeFilter.image); break;
      default: pv.setType(MediaTypeFilter.all);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<MediaProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // ... (Giữ nguyên không đổi)
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                dropdownColor: Colors.grey[900],
                value: _selectedMovieId,
                items: _fakeMovies
                    .map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedMovieId = v);
                  context.read<MediaProvider>().setMovie(v == 0 ? null : v);
                },
                iconEnabledColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: pv.error != null
          ? Center(child: Text('Lỗi: ${pv.error}', style: const TextStyle(color: Colors.white70)))
          : RefreshIndicator(
              onRefresh: () => pv.refresh(),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  // ... (Toàn bộ phần Sliver giữ nguyên không đổi)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (text) {
                          final q = text.trim();
                          if (q.isEmpty && _deb != null) {
                            _deb?.cancel();
                            context.read<MediaProvider>().setQuery('');
                            return;
                          }
                          _deb?.cancel();
                          _deb = Timer(const Duration(milliseconds: 400), () {
                            context.read<MediaProvider>().setQuery(q);
                          });
                        },
                        onSubmitted: (s) {
                          _deb?.cancel();
                          context.read<MediaProvider>().setQuery(s.trim());
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm phim...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: (_searchCtrl.text.isEmpty)
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _deb?.cancel();
                                    context.read<MediaProvider>().setQuery('');
                                  },
                                ),
                          filled: true,
                          fillColor: const Color(0xFF1C1C1C),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24, width: 0.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white54, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _BannerSection()),
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => MediaTile(media: pv.items[i]),
                        childCount: pv.items.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: pv.loading && pv.items.isNotEmpty
                            ? const CircularProgressIndicator()
                            : (pv.hasMore
                                ? const SizedBox.shrink()
                                : const Text('— Hết dữ liệu —', style: TextStyle(color: Colors.white54))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      // ✅ BƯỚC 3: Thêm mục mới vào danh sách destinations
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        indicatorColor: Colors.white10,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _bottomIndex,
        onDestinationSelected: _applyTypeFromBottomNav,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view, color: Colors.white70),
            selectedIcon: Icon(Icons.grid_view, color: Colors.white),
            label: 'Tất cả',
          ),
          NavigationDestination(
            icon: Icon(Icons.videocam_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.videocam, color: Colors.white),
            label: 'Video',
          ),
          NavigationDestination(
            icon: Icon(Icons.image_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.image, color: Colors.white),
            label: 'Ảnh',
          ),
          // MỤC MỚI ĐƯỢC THÊM VÀO ĐÂY
          NavigationDestination(
            icon: Icon(Icons.movie_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.movie, color: Colors.white),
            label: 'Vào trang phim',
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// CÁC WIDGET PHỤ (GIỮ NGUYÊN)
// ====================================================================

// ... (Toàn bộ phần widget phụ giữ nguyên không đổi)
class _BannerData {
  final String imagePath;
  final String title;
  _BannerData(this.imagePath, this.title);
}

class _BannerSection extends StatefulWidget {
  const _BannerSection();
  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  final _banners = [
    _BannerData('assets/images/banner.png', 'NỔI BẬT'),
    _BannerData('assets/images/lieuthan1.jpg', 'LIỄU THẦN'),
    _BannerData('assets/images/thachhao.jpg', 'Thạch Hạo'),
    _BannerData('assets/images/thachao1.jpg', 'Hoang Thiên Đế'),
  ];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _SingleBannerItem(
                imagePath: banner.imagePath,
                title: banner.title,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _banners.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.white,
                dotColor: Colors.white38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleBannerItem extends StatelessWidget {
  final String imagePath;
  final String title;
  const _SingleBannerItem({required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[900],
              child: const Center(child: Icon(Icons.movie, color: Colors.white54, size: 48)),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.7],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
                shadows: [Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}