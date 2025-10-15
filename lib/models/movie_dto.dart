import 'package:json_annotation/json_annotation.dart';
part 'movie_dto.g.dart';

/// DTO dùng để hiển thị (list/detail)
@JsonSerializable()
class MovieWithCastAndStudioDTO {
  final int id;
  final String? title;
  final String? description;

  @JsonKey(name: 'isWatched')
  final bool isWatched;

  @JsonKey(name: 'dateWatched')
  final DateTime? dateWatched;

  @JsonKey(name: 'rating')
  final int? rating;

  final String? genre;

  @JsonKey(name: 'posterUrl')
  final String? posterUrl;

  @JsonKey(name: 'dateAdded')
  final DateTime dateAdded;

  @JsonKey(name: 'studioName')
  final String studioName;

  /// API trả 'actorNames' nhưng mình muốn field tên castNames
  @JsonKey(name: 'actorNames')
  final List<String> castNames;

  MovieWithCastAndStudioDTO({
    required this.id,
    this.title,
    this.description,
    required this.isWatched,
    this.dateWatched,
    this.rating,
    this.genre,
    this.posterUrl,
    required this.dateAdded,
    required this.studioName,
    required this.castNames,
  });

  factory MovieWithCastAndStudioDTO.fromJson(Map<String, dynamic> json)
    => _$MovieWithCastAndStudioDTOFromJson(json);
  Map<String, dynamic> toJson() => _$MovieWithCastAndStudioDTOToJson(this);
}

/// DTO để tạo/cập nhật
@JsonSerializable()
class AddMovieRequestDTO {
  String? title;
  String? description;

  @JsonKey(name: 'isWatched')
  bool isWatched;

  @JsonKey(name: 'dateWatched')
  DateTime? dateWatched;

  @JsonKey(name: 'rating')
  int? rating;

  String? genre;

  @JsonKey(name: 'posterUrl')
  String? posterUrl;

  @JsonKey(name: 'dateAdded')
  DateTime dateAdded;

  /// giữ đúng với backend (studioId)
  @JsonKey(name: 'studioId')
  int studioId;

  /// Backend nhiều khả năng nhận 'actorIds' → map từ castIds sang actorIds
  @JsonKey(name: 'actorIds')
  List<int> castIds;

  AddMovieRequestDTO({
    this.title,
    this.description,
    this.isWatched = false,
    this.dateWatched,
    this.rating,
    this.genre,
    this.posterUrl,
    required this.dateAdded,
    required this.studioId,
    required this.castIds,
  });

  factory AddMovieRequestDTO.fromJson(Map<String, dynamic> json)
    => _$AddMovieRequestDTOFromJson(json);
  Map<String, dynamic> toJson() => _$AddMovieRequestDTOToJson(this);
}
