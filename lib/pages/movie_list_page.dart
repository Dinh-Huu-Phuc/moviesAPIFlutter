import 'package:flutter/material.dart';
import 'package:movie_api_flutter/theme/movie_form_page.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_tile.dart';
import '../widgets/error_state.dart';
import 'movie_detail_page.dart';
import 'media_gallery_page.dart'; // ✅ THÊM IMPORT NÀY

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final _scroll = ScrollController();
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MovieProvider>().refresh();
    });

    _scroll.addListener(() {
      final pv = context.read<MovieProvider>();
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
        pv.fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pv = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        // ✅ CẬP NHẬT DANH SÁCH ACTIONS
        actions: [
          // Nút mới để mở thư viện media
          IconButton(
            tooltip: 'Movie Files',
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MediaGalleryPage()),
              );
            },
          ),
          // Giữ lại PopupMenuButton cũ
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'add') {
                final ok = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MovieFormPage(mode: MovieFormMode.create),
                  ),
                );
                if (ok == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm phim')),
                  );
                  context.read<MovieProvider>().refresh();
                }
              } else if (value == 'refresh') {
                context.read<MovieProvider>().refresh();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'add', child: Text('Thêm phim')),
              const PopupMenuItem(value: 'refresh', child: Text('Làm mới')),
            ],
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Tìm theo tiêu đề…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => context.read<MovieProvider>().refresh(query: _ctrl.text),
                ),
              ),
              onSubmitted: (v) => context.read<MovieProvider>().refresh(query: v),
            ),
          ),
          if (pv.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ErrorState(
                message: 'Lỗi: ${pv.error}',
                onRetry: () => context.read<MovieProvider>().refresh(query: pv.q),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemCount: pv.items.length + (pv.loading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i >= pv.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final m = pv.items[i];
                return MovieTile(
                  movie: m,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovieDetailPage(id: m.id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}