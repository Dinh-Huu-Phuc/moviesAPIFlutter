// lib/models/media_dto.dart

import 'package:json_annotation/json_annotation.dart';
part 'media_dto.g.dart';

@JsonSerializable()
class MediaInfoDTO {
  final int id;
  final String fileName;
  final String? fileDescription;
  final String fileExtension;
  final int fileSizeInBytes;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String? thumbnailFileName;

  // Các trường meta mới
  final String? title;
  final String? intro;
  final String? genre;
  final int? year;
  final int? movieId;

  MediaInfoDTO({
    required this.id,
    required this.fileName,
    required this.fileExtension,
    required this.fileSizeInBytes,
    this.fileDescription,
    this.fileUrl,
    this.thumbnailUrl,
    this.thumbnailFileName,
    this.title,
    this.intro,
    this.genre,
    this.year,
    this.movieId,
  });

  // Hai dòng này sẽ trỏ đến code được tự động tạo ra trong file 'media_dto.g.dart'
  factory MediaInfoDTO.fromJson(Map<String, dynamic> json) =>
      _$MediaInfoDTOFromJson(json);
  Map<String, dynamic> toJson() => _$MediaInfoDTOToJson(this);
}