import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_service.dart';
import 'media_gallery_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  // --- Slider ảnh nền ---
  // ✅ DANH SÁCH ẢNH ĐÃ ĐƯỢC CẬP NHẬT
  final _backgroundImages = [
    'assets/images/lieuthan.jpg',
    'assets/images/lieuthan1.jpg',
    'assets/images/thachhao.jpg',
    'assets/images/thachao1.jpg',
    'assets/images/thachhao1.jpg',
  ];
  int _currentImageIndex = 0;
  Timer? _timer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- Slider ảnh nền ---
          PageView.builder(
            controller: _pageController,
            itemCount: _backgroundImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _backgroundImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          // Lớp phủ màu tối
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Form đăng nhập/đăng ký
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isLogin
                    ? LoginForm(key: const ValueKey('login'), onToggle: _toggleForm)
                    : RegisterForm(key: const ValueKey('register'), onToggle: _toggleForm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// WIDGET FORM ĐĂNG NHẬP (GIỮ NGUYÊN)
// ====================================================================
class LoginForm extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginForm({super.key, required this.onToggle});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MediaGalleryPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng nhập thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red),
      );
    }
  }
  
    @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Đăng Nhập', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_emailCtrl, 'Email', Icons.email),
              const SizedBox(height: 20),
              _buildTextField(_passwordCtrl, 'Mật khẩu', Icons.lock, obscureText: true),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                ),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: widget.onToggle,
          child: const Text('Chưa có tài khoản? Đăng ký ngay', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

// ====================================================================
// WIDGET FORM ĐĂNG KÝ (GIỮ NGUYÊN)
// ====================================================================
class RegisterForm extends StatefulWidget {
  final VoidCallback onToggle;
  const RegisterForm({super.key, required this.onToggle});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthService>();
    final success = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thành công! Chào mừng, ${auth.userName}!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MediaGalleryPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red),
      );
    }
  }
  
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Tạo Tài Khoản', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameCtrl, 'Tên của bạn', Icons.person),
              const SizedBox(height: 20),
              _buildTextField(_emailCtrl, 'Email', Icons.email),
              const SizedBox(height: 20),
              _buildTextField(_passwordCtrl, 'Mật khẩu', Icons.lock, obscureText: true),
              const SizedBox(height: 20),
              _buildTextField(
                _confirmPasswordCtrl,
                'Nhập lại mật khẩu',
                Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập lại mật khẩu';
                  }
                  if (value != _passwordCtrl.text) {
                    return 'Mật khẩu nhập lại không khớp';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                ),
              ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: widget.onToggle,
          child: const Text('Đã có tài khoản? Đăng nhập', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

// WIDGET HELPER ĐỂ TẠO Ô NHẬP LIỆU (GIỮ NGUYÊN)
TextFormField _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  bool obscureText = false,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
    validator: validator ??
        (value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng nhập $label';
      }
      return null;
    },
  );
}

