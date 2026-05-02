import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/candidate_photo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickProfileImage(dynamic user) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      
      setState(() {
        final newId = 'user_profile_${user.nim}';
        DataService().storeImageBytes(newId, bytes);
        user.profileImagePath = 'memory://$newId';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = DataService();
    final user = ds.currentUser;

    // Guard null - redirect to login if session lost
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    void onNav(SidebarItem item) {
      switch (item) {
        case SidebarItem.beranda:
          Navigator.pushReplacementNamed(context, '/user/dashboard');
          break;
        case SidebarItem.kandidat:
        case SidebarItem.voting:
          Navigator.pushReplacementNamed(context, '/user/candidates');
          break;
        case SidebarItem.riwayat:
          Navigator.pushReplacementNamed(context, '/user/history');
          break;
        case SidebarItem.profil:
          break;
        default:
          break;
      }
    }

    return ResponsiveScaffold(
      activeItem: SidebarItem.profil,
      onItemTap: onNav,
      title: 'Profil Saya',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final profileCard = _buildProfileCard(user);
          final infoCards = _buildInfoCards(context, user, ds);
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: profileCard),
                const SizedBox(width: 20),
                Expanded(child: infoCards),
              ],
            );
          }
          return Column(children: [profileCard, const SizedBox(height: 16), infoCards]);
        }),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.08),
            Colors.white,
          ],
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _pickProfileImage(user),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primaryBlue,
                  backgroundImage: user.profileImagePath != null 
                      ? getImageProvider(user.profileImagePath!) 
                      : null,
                  child: user.profileImagePath == null
                      ? Text(
                          (user.name != null && user.name.isNotEmpty) ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _pickProfileImage(user),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(user.name ?? 'Pengguna',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Mahasiswa',
              style: TextStyle(color: AppColors.textGray, fontSize: 13)),
          Text(user.prodi ?? 'Informatika',
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (user.hasVoted ? AppColors.success : AppColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.hasVoted ? '✓ Sudah Memilih' : '⏳ Belum Memilih',
              style: TextStyle(
                  color: user.hasVoted ? AppColors.success : AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, dynamic user, DataService ds) {
    return Column(
      children: [
        _infoCard('Data Diri', Icons.person_rounded, AppColors.primaryBlue, [
          _infoRow(Icons.badge_outlined, 'NIM', user.nim ?? '-'),
          _infoRow(Icons.person_outline, 'Nama', user.name ?? '-'),
          _infoRow(Icons.email_outlined, 'Email', user.email ?? '-'),
          _infoRow(Icons.school_outlined, 'Prodi', user.prodi ?? '-'),
        ]),
        if (user.hasVoted == true) ...[
          const SizedBox(height: 14),
          _infoCard('Riwayat Voting', Icons.how_to_vote_rounded, AppColors.success, [
            _infoRow(Icons.check_circle_outline, 'Status', 'Sudah Memilih',
                valueColor: AppColors.success),
            _infoRow(Icons.calendar_today_outlined, 'Tanggal',
                user.votedAt != null ? DateFormat('dd MMM yyyy HH:mm').format(user.votedAt!) : '-'),
          ]),
        ],
        const SizedBox(height: 14),
        _infoCard('Pengaturan Akun', Icons.settings_rounded, AppColors.warning, [
          _actionTile(Icons.edit_rounded, 'Edit Profil', AppColors.primaryBlue, () {
            _showEditProfileDialog(context, user);
          }),
          _actionTile(Icons.lock_outline_rounded, 'Ubah Password', AppColors.warning, () {
            _showChangePasswordDialog(context);
          }),
          _actionTile(Icons.logout_rounded, 'Logout', AppColors.danger, () {
            ds.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }),
        ]),
      ],
    );
  }

  Widget _infoCard(String title, IconData icon, Color color, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark)),
          ]),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textGray),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  color: valueColor ?? AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textGray),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameCtrl = TextEditingController(text: user.name ?? '');
    final emailCtrl = TextEditingController(text: user.email ?? '');
    final prodiCtrl = TextEditingController(text: user.prodi ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 20),
          SizedBox(width: 8),
          Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ]),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prodiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  user.name = nameCtrl.text.trim();
                  user.email = emailCtrl.text.trim();
                  user.prodi = prodiCtrl.text.trim();
                });
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Profil berhasil diperbarui'),
                  ]),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.lock_rounded, color: AppColors.warning, size: 20),
          SizedBox(width: 8),
          Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ]),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Lama',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              if (newPassCtrl.text != confirmPassCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password baru tidak cocok!'), backgroundColor: AppColors.danger),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password berhasil diubah'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
