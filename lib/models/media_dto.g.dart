// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaInfoDTO _$MediaInfoDTOFromJson(Map<String, dynamic> json) => MediaInfoDTO(
      id: (json['id'] as num).toInt(),
      fileName: json['fileName'] as String,
      fileDescription: json['fileDescription'] as String?,
      fileExtension: json['fileExtension'] as String,
      fileSizeInBytes: (json['fileSizeInBytes'] as num).toInt(),
      fileUrl: json['fileUrl'] as String?,
    );

Map<String, dynamic> _$MediaInfoDTOToJson(MediaInfoDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileDescription': instance.fileDescription,
      'fileExtension': instance.fileExtension,
      'fileSizeInBytes': instance.fileSizeInBytes,
      'fileUrl': instance.fileUrl,
    };
