// lib/pages/movie_form_page.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/movie_dto.dart';
import '../providers/movie_provider.dart';

enum MovieFormMode { create, edit }

class MovieFormPage extends StatefulWidget {
  final MovieFormMode mode;
  final int? movieId; // dùng khi edit
  final MovieWithCastAndStudioDTO? preset; // dữ liệu gợi ý khi edit

  const MovieFormPage({
    super.key,
    required this.mode,
    this.movieId,
    this.preset,
  });

  @override
  State<MovieFormPage> createState() => _MovieFormPageState();
}

class _MovieFormPageState extends State<MovieFormPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _rating = TextEditingController();
  final _genre = TextEditingController();
  final _poster = TextEditingController();
  final _dateWatchedStr = TextEditingController(); // yyyy-MM-dd
  final _studioId = TextEditingController();
  final _actorIds = TextEditingController(); // ví dụ: 1,2,3

  bool _isWatched = false;

  // ảnh local + url sau upload
  File? _pickedImage;
  String? _uploadedPosterUrl;

  @override
  void initState() {
    super.initState();
    if (widget.mode == MovieFormMode.edit && widget.preset != null) {
      final m = widget.preset!;
      _title.text = m.title ?? '';
      _desc.text = m.description ?? '';
      _rating.text = m.rating?.toString() ?? '';
      _genre.text = m.genre ?? '';
      _poster.text = m.posterUrl ?? '';
      _isWatched = m.isWatched;
      _dateWatchedStr.text = m.dateWatched != null
          ? "${m.dateWatched!.year.toString().padLeft(4, '0')}-${m.dateWatched!.month.toString().padLeft(2, '0')}-${m.dateWatched!.day.toString().padLeft(2, '0')}"
          : '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _rating.dispose();
    _genre.dispose();
    _poster.dispose();
    _dateWatchedStr.dispose();
    _studioId.dispose();
    _actorIds.dispose();
    super.dispose();
  }

  Future<void> _pickDateWatched() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_dateWatchedStr.text) ?? now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (d != null) {
      _dateWatchedStr.text =
          "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  /// Chọn ảnh từ máy
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (x != null) {
      setState(() {
        _pickedImage = File(x.path);
      });
    }
  }

  /// Upload ảnh lên server → nhận URL
  Future<void> _uploadPickedImage() async {
    if (_pickedImage == null) return;

    final dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:5099',
    ));

    final fileName = _pickedImage!.path.split('/').last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        _pickedImage!.path,
        filename: fileName,
      ),
    });

    try {
      final res = await dio.post(
        '/api/images/upload',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );

      String? url;
      final data = res.data;
      if (data is String) {
        url = data;
      } else if (data is Map) {
        url = (data['fileUrl'] ?? data['imageUrl'] ?? data['url'])?.toString();
      }

      if (url == null || url.isEmpty) {
        throw 'Không nhận được URL ảnh từ server';
      }

      setState(() {
        _uploadedPosterUrl = url;
        _poster.text = url ?? ''; // ✅ Tự điền vào field
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tải ảnh lên thành công')));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Upload lỗi';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload ảnh thất bại: $e')));
    }
  }

  AddMovieRequestDTO _buildBody() {
    final rating = _rating.text.trim().isEmpty
        ? null
        : int.tryParse(_rating.text.trim());
    final dateWatched = _dateWatchedStr.text.trim().isEmpty
        ? null
        : DateTime.tryParse("${_dateWatchedStr.text.trim()}T00:00:00");
    final studioId = int.tryParse(_studioId.text.trim());

    final actorIds = _actorIds.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();
    
    // ✅ Ưu tiên URL đã upload
    final posterUrl = (_uploadedPosterUrl?.isNotEmpty == true)
        ? _uploadedPosterUrl
        : (_poster.text.trim().isEmpty ? null : _poster.text.trim());

    return AddMovieRequestDTO(
      title: _title.text.trim().isEmpty ? null : _title.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      isWatched: _isWatched,
      dateWatched: dateWatched,
      rating: rating,
      genre: _genre.text.trim().isEmpty ? null : _genre.text.trim(),
      posterUrl: posterUrl,
      dateAdded: DateTime.now(),
      studioId: studioId ?? 0,
      castIds: actorIds,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final pv = context.read<MovieProvider>();
    final body = _buildBody();

    try {
      if (widget.mode == MovieFormMode.create) {
        await pv.add(body);
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        final id = widget.movieId!;
        await pv.update(id, body);
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      String msg = 'Lỗi: ${e.message}';
      final data = e.response?.data;
      if (data is Map) {
        if (data['errors'] is Map) {
          final errs = (data['errors'] as Map);
          final parts = <String>[];
          errs.forEach((k, v) {
            if (v is List && v.isNotEmpty) parts.add('$k: ${v.first}');
          });
          if (parts.isNotEmpty) msg = parts.join('\n');
        } else {
          final parts = <String>[];
          data.forEach((k, v) {
            if (v is List && v.isNotEmpty) parts.add('$k: ${v.first}');
          });
          if (parts.isNotEmpty) msg = parts.join('\n');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == MovieFormMode.edit;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa phim' : 'Thêm phim')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black12,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedImage != null
                      ? Image.file(_pickedImage!, fit: BoxFit.cover)
                      : (_uploadedPosterUrl != null
                          ? Image.network(_uploadedPosterUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 40)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Chọn ảnh từ máy'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed:
                            _pickedImage != null ? _uploadPickedImage : null,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Tải ảnh lên server'),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sau khi tải lên, Poster URL sẽ tự điền.',
                        style:
                            TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _poster,
              decoration: const InputDecoration(
                  labelText: 'Poster URL (ảnh trực tiếp, có thể để trống)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _rating,
                    decoration:
                        const InputDecoration(labelText: 'Rating (0..5)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _genre,
                    decoration: const InputDecoration(labelText: 'Thể loại'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Đã xem'),
              value: _isWatched,
              onChanged: (v) => setState(() => _isWatched = v),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateWatchedStr,
                    decoration: const InputDecoration(
                        labelText: 'Ngày xem (yyyy-MM-dd)'),
                    readOnly: true,
                    onTap: _pickDateWatched,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.event),
                  onPressed: _pickDateWatched,
                ),
              ],
            ),
            const Divider(height: 32),
            TextFormField(
              controller: _studioId,
              decoration: const InputDecoration(labelText: 'StudioID (số)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (int.tryParse(v ?? '') == null) ? 'Nhập số StudioID' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _actorIds,
              decoration: const InputDecoration(
                  labelText: 'ActorIds (ví dụ: 1,2,3)'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm phim'),
            ),
          ],
        ),
      ),
    );
  }
}