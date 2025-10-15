// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieWithCastAndStudioDTO _$MovieWithCastAndStudioDTOFromJson(
        Map<String, dynamic> json) =>
    MovieWithCastAndStudioDTO(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      isWatched: json['isWatched'] as bool,
      dateWatched: json['dateWatched'] == null
          ? null
          : DateTime.parse(json['dateWatched'] as String),
      rating: (json['rating'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      posterUrl: json['posterUrl'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      studioName: json['studioName'] as String,
      castNames: (json['actorNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MovieWithCastAndStudioDTOToJson(
        MovieWithCastAndStudioDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isWatched': instance.isWatched,
      'dateWatched': instance.dateWatched?.toIso8601String(),
      'rating': instance.rating,
      'genre': instance.genre,
      'posterUrl': instance.posterUrl,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'studioName': instance.studioName,
      'actorNames': instance.castNames,
    };

AddMovieRequestDTO _$AddMovieRequestDTOFromJson(Map<String, dynamic> json) =>
    AddMovieRequestDTO(
      title: json['title'] as String?,
      description: json['description'] as String?,
      isWatched: json['isWatched'] as bool? ?? false,
      dateWatched: json['dateWatched'] == null
          ? null
          : DateTime.parse(json['dateWatched'] as String),
      rating: (json['rating'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      posterUrl: json['posterUrl'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      studioId: (json['studioId'] as num).toInt(),
      castIds: (json['actorIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$AddMovieRequestDTOToJson(AddMovieRequestDTO instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'isWatched': instance.isWatched,
      'dateWatched': instance.dateWatched?.toIso8601String(),
      'rating': instance.rating,
      'genre': instance.genre,
      'posterUrl': instance.posterUrl,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'studioId': instance.studioId,
      'actorIds': instance.castIds,
    };
