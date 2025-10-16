import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../providers/media_provider.dart';
import '../models/media_dto.dart';
import '../repos/media_repo.dart';
import 'media_player_page.dart';

// (Tuỳ chọn) nếu bạn đã có MovieRepo/MovieDTO thì thay cái below thành gọi thật.
// Ở đây demo danh sách phim giả (id, name) – bạn thay bằng API Movies khi có.
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
  late TabController _tab;

  // TODO: Thay bằng fetch từ API Movies (nếu muốn)
  final _fakeMovies = <_MovieOption>[
    _MovieOption(0, 'Tất cả phim'),
    _MovieOption(1, 'Inception'),
    _MovieOption(2, 'Forrest Gump'),
    _MovieOption(3, 'Hoang Thiên Đế'),
  ];
  int _selectedMovieId = 0;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      final pv = context.read<MediaProvider>();
      switch (_tab.index) {
        case 1:
          pv.setType(MediaTypeFilter.video);
          break;
        case 2:
          pv.setType(MediaTypeFilter.image);
          break;
        case 0:
        default:
          pv.setType(MediaTypeFilter.all);
      }
    });

    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<MediaProvider>().fetchMore();
      }
    });

    // Lần đầu load
    Future.microtask(() => context.read<MediaProvider>().refresh());
  }

  @override
  void dispose() {
    _scroll.dispose();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<MediaProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white), // Giữ nút back màu trắng
          title: const Text('Phim Lậu', style: TextStyle(color: Colors.white),),
          bottom: TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Video'),
              Tab(text: 'Ảnh'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  dropdownColor: Colors.grey[900],
                  value: _selectedMovieId,
                  items: _fakeMovies
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(
                            m.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
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
            ? Center(
                child: Text(
                  'Lỗi: ${pv.error}',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => pv.refresh(),
                child: CustomScrollView(
                  controller: _scroll,
                  slivers: [
                    // ✅ CẬP NHẬT LỜI GỌI WIDGET BANNER
                    const SliverToBoxAdapter(child: _BannerSection()),

                    // Lưới media
                    SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate((ctx, i) {
                          final m = pv.items[i];
                          final url = pv.urlOf(m);
                          final isVideo = pv.isVideo(m);

                          return InkWell(
                            onTap: () {
                              if (isVideo) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MediaPlayerPage(videoUrl: url),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      backgroundColor: Colors.black,
                                      appBar: AppBar(
                                        backgroundColor: Colors.black,
                                        iconTheme: const IconThemeData(color: Colors.white),
                                      ),
                                      body: Center(
                                        child: InteractiveViewer(
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            httpHeaders: const {
                                              'User-Agent': 'Mozilla/5.0',
                                            },
                                            fit: BoxFit.contain,
                                            errorWidget: (_, __, ___) =>
                                                const Icon(
                                              Icons.broken_image,
                                              size: 64,
                                              color: Colors.white,
                                            ),
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
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: _ThumbOrIcon(m: m, url: url),
                                        ),
                                      ),
                                      if (isVideo)
                                        const Positioned(
                                          right: 6,
                                          bottom: 6,
                                          child: CircleAvatar(
                                            radius: 12,
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  pv.displayName(m),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: pv.items.length),
                      ),
                    ),

                    // Footer loading / hết dữ liệu
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: pv.loading && pv.items.isNotEmpty
                              ? const CircularProgressIndicator()
                              : (pv.hasMore
                                  ? const SizedBox.shrink()
                                  : const Text(
                                      '— Hết dữ liệu —',
                                      style: TextStyle(color: Colors.white54),
                                    )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ✅ THAY THẾ WIDGET BANNER CŨ BẰNG PHIÊN BẢN MỚI NÀY
class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    // Banner cố định từ assets
    const bannerPath = 'assets/images/banner.png'; // <-- Sửa lại thành .png nếu cần

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              bannerPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.movie, color: Colors.white54, size: 48),
                ),
              ),
            ),
            // Lớp phủ gradient để làm nổi bật tiêu đề
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
            // Tiêu đề trên banner
            const Positioned(
              left: 16,
              bottom: 16,
              child: Text(
                'NỔI BẬT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET _ThumbOrIcon VẪN ĐƯỢC GIỮ NGUYÊN VÌ LƯỚI MEDIA CẦN DÙNG
class _ThumbOrIcon extends StatelessWidget {
  final MediaInfoDTO m;
  final String url;
  const _ThumbOrIcon({required this.m, required this.url});

  @override
  Widget build(BuildContext context) {
    final pv = context.read<MediaProvider>();
    final poster = pv.posterOf(m); // Dùng posterOf để ưu tiên thumbnail

    return CachedNetworkImage(
      imageUrl: poster,
      httpHeaders: const {'User-Agent': 'Mozilla/5.0'},
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() => Container(
    color: Colors.grey[900],
    child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
  );
}