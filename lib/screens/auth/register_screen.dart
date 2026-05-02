import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/himaif_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    DataService().register(
      nim: _nimCtrl.text,
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    
    // Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil! Silakan login.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    
    // Kembali ke layar login (karena RegisterScreen dipanggil via push/pop dari LoginScreen)
    Navigator.pop(context);
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
                    if (!isWide) ...[
                      const Center(
                        child: HimaifLogo(size: 80, showText: false),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text('Daftar Akun',
                        style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Bergabung dengan HIMAIF Informatika',
                        style: TextStyle(
                            color: AppColors.textGray, fontSize: 13)),
                    const SizedBox(height: 28),
                    _field('NIM', 'Masukkan NIM Anda', _nimCtrl,
                        Icons.badge_outlined,
                        validator: (v) =>
                            v!.isEmpty ? 'NIM wajib diisi' : null),
                    const SizedBox(height: 14),
                    _field('Nama Lengkap', 'Masukkan nama lengkap',
                        _nameCtrl, Icons.person_outline,
                        validator: (v) =>
                            v!.isEmpty ? 'Nama wajib diisi' : null),
                    const SizedBox(height: 14),
                    _field('Email', 'contoh@gmail.com', _emailCtrl,
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                          final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
                          if (!emailRegex.hasMatch(v.trim())) return 'Format email tidak valid (contoh: nama@gmail.com)';
                          return null;
                        }),
                    const SizedBox(height: 14),
                    _passField(
                        'Password',
                        'Masukkan password',
                        _passCtrl,
                        _obscure1,
                        () => setState(() => _obscure1 = !_obscure1),
                        validator: (v) => v!.length < 6
                            ? 'Password minimal 6 karakter'
                            : null),
                    const SizedBox(height: 14),
                    _passField(
                        'Konfirmasi Password',
                        'Ulangi password',
                        _confirmCtrl,
                        _obscure2,
                        () => setState(() => _obscure2 = !_obscure2),
                        validator: (v) => v != _passCtrl.text
                            ? 'Password tidak cocok'
                            : null),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Daftar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? ',
                            style: TextStyle(
                                color: AppColors.textGray, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Login di sini',
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
                          const SizedBox(height: 24),
                          Text('Bergabunglah bersama\nkami di HIMAIF!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 15,
                                  height: 1.6)),
                        ],
                      ),
                    ),
                  ),
                ),
              if (isWide)
                SizedBox(width: 480, child: formPanel)
              else
                Expanded(child: formPanel),
            ],
          );
        },
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl,
      IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
          validator: validator,
        ),
      ],
    );
  }

  Widget _passField(String label, String hint, TextEditingController ctrl,
      bool obscure, VoidCallback toggle,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

}
