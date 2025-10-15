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
  // ✅ THÊM/CẬP NHẬT TRƯỜNG NÀY
  final String? thumbnailUrl;

  MediaInfoDTO({
    required this.id,
    required this.fileName,
    this.fileDescription,
    required this.fileExtension,
    required this.fileSizeInBytes,
    this.fileUrl,
    this.thumbnailUrl, // Cập nhật constructor
  });

  // Giữ nguyên các hàm này, build_runner sẽ tự động cập nhật chúng
  factory MediaInfoDTO.fromJson(Map<String, dynamic> json) =>
      _$MediaInfoDTOFromJson(json);
  Map<String, dynamic> toJson() => _$MediaInfoDTOToJson(this);
}