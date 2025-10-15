class MediaFile {
  final int id;
  final String fileName;        // VD: backmythwukong4_8c67bf62-...
  final String fileExtension;   // VD: .mp4 / .jpg
  final int? fileSizeInBytes;
  final String? fileDescription;
  final String? fileUrl;        // backend có thể trả sẵn URL

  MediaFile({
    required this.id,
    required this.fileName,
    required this.fileExtension,
    this.fileSizeInBytes,
    this.fileDescription,
    this.fileUrl,
  });

  factory MediaFile.fromJson(Map<String, dynamic> j) {
    return MediaFile(
      id: j['id'] as int,
      fileName: j['fileName'] as String,
      fileExtension: (j['fileExtension'] as String?) ?? '',
      fileSizeInBytes: j['fileSizeInBytes'] as int?,
      fileDescription: j['fileDescription'] as String?,
      fileUrl: j['fileUrl'] as String?,
    );
  }
}
