import 'package:flutter/foundation.dart';
import '../repos/movie_repo.dart';
import '../models/movie_dto.dart';

class MovieProvider extends ChangeNotifier {
  final MovieRepo repo;
  MovieProvider(this.repo);

  bool loading = false;
  String? error;
  final List<MovieWithCastAndStudioDTO> items = [];
  int page = 1;
  bool hasMore = true;
  String q = '';

  /// Refresh danh sách (khi search mới hoặc pull-to-refresh)
  Future<void> refresh({String? query}) async {
    q = query ?? q;
    page = 1;
    hasMore = true;
    items.clear();
    await fetchMore();
  }

  Future<void> add(AddMovieRequestDTO body) async {
    await repo.create(body);
    await refresh(); // reload list
  }

  Future<void> update(int id, AddMovieRequestDTO body) async {
    await repo.update(id, body);
    await refresh();
  }

  Future<void> remove(int id) async {
    await repo.delete(id);
    items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Load thêm dữ liệu (paging)
  Future<void> fetchMore() async {
    if (loading || !hasMore) return;

    loading = true;
    error = null;
    notifyListeners(); // báo UI đang loading

    try {
      final data = await repo.list(q: q, page: page, size: 10);
      if (data.isEmpty) {
        hasMore = false;
      } else {
        items.addAll(data);
        page++;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners(); // cập nhật UI sau khi có kết quả
    }
  }
}
