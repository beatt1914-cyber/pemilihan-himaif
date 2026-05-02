import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/app_sidebar.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final ds = DataService();
  bool _showResultsToPublic = false;
  String _electionName = 'Pemilihan Kandidat HIMAIF 2024';

  void _onNav(SidebarItem item) {
    switch (item) {
      case SidebarItem.dashboard:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case SidebarItem.kandidat:
      case SidebarItem.kelolaKandidat:
        Navigator.pushReplacementNamed(context, '/admin/candidates');
        break;
      case SidebarItem.kelolaPemilih:
        Navigator.pushReplacementNamed(context, '/admin/voters');
        break;
      case SidebarItem.hasilVoting:
        Navigator.pushReplacementNamed(context, '/admin/results');
        break;
      case SidebarItem.pengaturan:
        // Already here
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur ini masih dalam tahap pengembangan')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      activeItem: SidebarItem.pengaturan,
      onItemTap: _onNav,
      title: 'Pengaturan Admin',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengaturan Sistem',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('Kelola konfigurasi pemilihan dan akses sistem.',
                style: TextStyle(color: AppColors.textGray, fontSize: 13)),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final settingsCard = _buildSettingsCard();
              final adminProfileCard = _buildAdminProfileCard();
              
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: settingsCard),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: adminProfileCard),
                  ],
                );
              }
              return Column(
                children: [
                  settingsCard,
                  const SizedBox(height: 20),
                  adminProfileCard,
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings_applications_rounded, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              const Text('Konfigurasi Pemilihan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Nama Pemilihan', _electionName, (val) => setState(() => _electionName = val)),
          const SizedBox(height: 24),
          _buildDateTimePicker(
            title: 'Waktu Mulai Pemilihan',
            subtitle: 'Kapan mahasiswa bisa mulai memilih',
            currentValue: ds.electionStartTime,
            onChanged: (val) => setState(() => ds.electionStartTime = val),
          ),
          const SizedBox(height: 16),
          _buildDateTimePicker(
            title: 'Waktu Selesai Pemilihan',
            subtitle: 'Batas akhir waktu pemilihan',
            currentValue: ds.electionEndTime,
            onChanged: (val) => setState(() => ds.electionEndTime = val),
          ),
          const Divider(height: 32),
          _buildSwitch(
            title: 'Tampilkan Hasil ke Publik',
            subtitle: 'Mahasiswa dapat melihat perolehan suara secara langsung',
            value: _showResultsToPublic,
            onChanged: (val) => setState(() => _showResultsToPublic = val),
            activeColor: AppColors.primaryBlue,
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reset Data Pemilihan',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                    const SizedBox(height: 4),
                    Text('Menghapus semua suara yang masuk. Tindakan ini tidak dapat dibatalkan.',
                        style: TextStyle(fontSize: 12, color: AppColors.textGray)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _showResetConfirmation(),
                child: const Text('Reset Data'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileCard() {
    final user = ds.currentUser;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: const Icon(Icons.admin_panel_settings_rounded, size: 40, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? 'Administrator',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(user?.email ?? 'admin@himaif.ac.id',
              style: TextStyle(color: AppColors.textGray, fontSize: 13)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Ubah Profil Admin'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ubah profil admin tersedia di versi selanjutnya.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textGray)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String title,
    required String subtitle,
    required DateTime? currentValue,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textGray)),
            ],
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(currentValue != null 
              ? '${currentValue.day}/${currentValue.month}/${currentValue.year} ${currentValue.hour.toString().padLeft(2, '0')}:${currentValue.minute.toString().padLeft(2, '0')}' 
              : 'Atur Waktu'),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: currentValue ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null && mounted) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              if (time != null) {
                onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
              }
            }
          },
        ),
        if (currentValue != null)
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.danger, size: 20),
            onPressed: () => onChanged(null),
            tooltip: 'Hapus Waktu',
          ),
      ],
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Reset', style: TextStyle(color: AppColors.danger)),
        content: const Text('Apakah Anda yakin ingin menghapus semua suara yang masuk? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              // Simulate reset logic
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data pemilihan berhasil direset.'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );
  }
}
