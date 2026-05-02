import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/himaif_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    final user = DataService().login(_nimCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (user != null) {
      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/user/dashboard');
      }
    } else {
      setState(() => _error = 'Email atau password salah. Pastikan akun Anda sudah terdaftar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          final formPanel = Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 24,
                vertical: 40,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo on narrow screens
                    if (!isWide) ...[
                      const Center(
                        child: HimaifLogo(size: 80, showText: false),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text('Login',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Masuk ke akun HIMAIF Anda',
                        style: TextStyle(
                            color: AppColors.textGray, fontSize: 13)),
                    const SizedBox(height: 32),
                    // Email
                    _label('Email'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nimCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'contoh@gmail.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                        final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
                        if (!emailRegex.hasMatch(v.trim())) return 'Format email tidak valid (contoh: nama@gmail.com)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password
                    _label('Password'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Password wajib diisi'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 12)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun? ',
                            style: TextStyle(
                                color: AppColors.textGray, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Daftar di sini',
                              style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );

          return Row(
            children: [
              // Left blue panel – only on wide screens
              if (isWide)
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, AppColors.primaryBlue],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HimaifLogo(size: 100, showText: true),
                          const SizedBox(height: 32),
                          Text('Bersama HIMAIF',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16)),
                          Text('Membangun Informatika',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              // Right form panel
              if (isWide)
                SizedBox(width: 440, child: formPanel)
              else
                Expanded(child: formPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          fontSize: 13));
}
