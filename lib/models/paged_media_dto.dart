import 'media_dto.dart';

class PagedMediaResponseDTO {
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final List<MediaInfoDTO> items;

  PagedMediaResponseDTO({
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.items,
  });

  factory PagedMediaResponseDTO.fromJson(Map<String, dynamic> j) {
    final list = (j['items'] as List? ?? [])
        .map((e) => MediaInfoDTO.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return PagedMediaResponseDTO(
      pageNumber: j['pageNumber'] ?? 1,
      pageSize: j['pageSize'] ?? list.length,
      totalCount: j['totalCount'] ?? list.length,
      totalPages: j['totalPages'] ?? 1,
      items: list,
    );
  }
}
