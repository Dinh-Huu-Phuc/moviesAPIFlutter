// lib/models/media_dto.dart

import 'package:json_annotation/json_annotation.dart';
part 'media_dto.g.dart';

// ✅ CẬP NHẬT TOÀN BỘ CLASS NÀY
@JsonSerializable()
class MediaInfoDTO {
  final int id;
  final String fileName;
  final String? fileDescription;
  final String fileExtension;
  final int fileSizeInBytes;
  final String? fileUrl;   // <= Chỉ dùng trường này

  MediaInfoDTO({
    required this.id,
    required this.fileName,
    this.fileDescription,
    required this.fileExtension,
    required this.fileSizeInBytes,
    this.fileUrl,
  });

  factory MediaInfoDTO.fromJson(Map<String, dynamic> json) =>
      _$MediaInfoDTOFromJson(json);
  Map<String, dynamic> toJson() => _$MediaInfoDTOToJson(this);
}