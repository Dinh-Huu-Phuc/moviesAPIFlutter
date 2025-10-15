import '../services/movies_api.dart';
import '../models/movie_dto.dart';

class MovieRepo {
  final MoviesApi api;
  MovieRepo(this.api);

  Future<List<MovieWithCastAndStudioDTO>> list({
    String? q,
    String sortBy = 'title',
    bool isAscending = true,
    int page = 1,
    int size = 10,
  }) {
    return api.getAllMovies(
      (q != null && q.isNotEmpty) ? 'title' : null,
      q,
      sortBy,
      isAscending,
      page,
      size,
    );
  }

  Future<MovieWithCastAndStudioDTO> get(int id) => api.getMovieById(id);

  // 🔁 ĐỔI: void
  Future<void> create(AddMovieRequestDTO body) => api.addMovie(body);

  // 🔁 ĐỔI: void
  Future<void> update(int id, AddMovieRequestDTO body) => api.updateMovie(id, body);

  Future<void> delete(int id) => api.deleteMovie(id);
}
