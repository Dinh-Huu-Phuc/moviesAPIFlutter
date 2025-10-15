import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../utils/datex.dart';

class MovieDetailPage extends StatefulWidget {
  final int id;
  const MovieDetailPage({super.key, required this.id});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    final repo = context.read<MovieProvider>().repo;
    repo.get(widget.id).then((m) => data = m.toJson())
      .catchError((e){ error = e.toString(); })
      .whenComplete(() => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(appBar: AppBar(), body: Center(child: Text('Lỗi: $error')));

    final title = data?['title'] ?? '(Không có tiêu đề)';
    final desc  = data?['description'] ?? '(Không có mô tả)';
    final rating = data?['rating']?.toString() ?? 'N/A';
    final isWatched = data?['isWatched'] == true;
    final dateWatched = data?['dateWatched'] != null
        ? DateTime.parse(data!['dateWatched'].toString())
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('⭐ Đánh giá: $rating', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text('Đã xem: ${isWatched ? "Có" : "Chưa"}', style: const TextStyle(fontSize: 16)),
            if (dateWatched != null) ...[
              const SizedBox(height: 6),
              Text('Ngày xem: ${DateX.ddMMyyyy(dateWatched)}', style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 12),
            const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc),
          ],
        ),
      ),
    );
  }
}
