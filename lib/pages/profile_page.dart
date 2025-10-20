// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Đang tải thông tin từ SharedPreferences
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Chưa đăng nhập
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản')),
        body: const Center(
          child: Text('Bạn chưa đăng nhập'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthService>().logout();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header user
          Row(
            children: [
              const CircleAvatar(radius: 28, child: Icon(Icons.person)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.userName ?? '(không tên)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.userEmail ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Cập nhật hồ sơ
          FilledButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Cập nhật hồ sơ'),
            onPressed: () async {
              final nameCtrl =
                  TextEditingController(text: auth.userName ?? '');
              final emailCtrl =
                  TextEditingController(text: auth.userEmail ?? '');

              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cập nhật hồ sơ'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Họ tên'),
                      ),
                      TextField(
                        controller: emailCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Email'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                await context.read<AuthService>().updateProfile(
                      nameCtrl.text.trim(),
                      emailCtrl.text.trim(),
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật hồ sơ')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 12),

          // Đổi mật khẩu (demo)
          OutlinedButton.icon(
            icon: const Icon(Icons.password),
            label: const Text('Đổi mật khẩu (demo)'),
            onPressed: () async {
              final oldCtrl = TextEditingController();
              final newCtrl = TextEditingController();

              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Đổi mật khẩu'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: oldCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Mật khẩu cũ'),
                      ),
                      TextField(
                        controller: newCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Mật khẩu mới'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đổi'),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                final okChange = await context
                    .read<AuthService>()
                    .resetPassword(oldCtrl.text, newCtrl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(okChange
                          ? 'Đổi mật khẩu thành công (demo)'
                          : 'Đổi mật khẩu thất bại'),
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 12),

          // Đăng xuất
          TextButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            onPressed: () async {
              await context.read<AuthService>().logout();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
