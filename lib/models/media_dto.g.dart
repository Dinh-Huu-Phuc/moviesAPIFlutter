// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaInfoDTO _$MediaInfoDTOFromJson(Map<String, dynamic> json) => MediaInfoDTO(
      id: (json['id'] as num).toInt(),
      fileName: json['fileName'] as String,
      fileExtension: json['fileExtension'] as String,
      fileSizeInBytes: (json['fileSizeInBytes'] as num).toInt(),
      fileDescription: json['fileDescription'] as String?,
      fileUrl: json['fileUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      genre: json['genre'] as String?,
      year: (json['year'] as num?)?.toInt(),
      movieId: (json['movieId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MediaInfoDTOToJson(MediaInfoDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileDescription': instance.fileDescription,
      'fileExtension': instance.fileExtension,
      'fileSizeInBytes': instance.fileSizeInBytes,
      'fileUrl': instance.fileUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'title': instance.title,
      'intro': instance.intro,
      'genre': instance.genre,
      'year': instance.year,
      'movieId': instance.movieId,
    };
