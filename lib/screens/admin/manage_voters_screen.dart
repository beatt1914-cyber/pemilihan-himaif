import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';
import '../../widgets/app_sidebar.dart';

class ManageVotersScreen extends StatefulWidget {
  const ManageVotersScreen({super.key});
  @override
  State<ManageVotersScreen> createState() => _ManageVotersScreenState();
}

class _ManageVotersScreenState extends State<ManageVotersScreen> {
  final ds = DataService();

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
        break;
      case SidebarItem.hasilVoting:
        Navigator.pushReplacementNamed(context, '/admin/results');
        break;
      case SidebarItem.pengaturan:
        Navigator.pushReplacementNamed(context, '/admin/settings');
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
    final voters = ds.users.where((u) => u.role != 'admin').toList();

    return ResponsiveScaffold(
      activeItem: SidebarItem.kelolaPemilih,
      onItemTap: _onNav,
      title: 'Data Pemilih',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data Pemilih Terdaftar',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildTable(voters);
              }
              return _buildCards(voters);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<UserModel> voters) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.lightBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Nama / NIM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
                Expanded(flex: 1, child: Text('Prodi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
                Expanded(flex: 2, child: Text('Status Voting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
              ],
            ),
          ),
          const Divider(height: 1),
          if (voters.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada pemilih terdaftar', style: TextStyle(color: AppColors.textGray)),
            ),
          ...voters.asMap().entries.map((e) {
            final u = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(u.email, style: TextStyle(color: AppColors.textGray, fontSize: 11)),
                            Text('NIM: ${u.nim}', style: TextStyle(color: AppColors.textGray, fontSize: 10)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(u.prodi, style: TextStyle(color: AppColors.textGray, fontSize: 12)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (u.hasVoted ? AppColors.success : AppColors.warning).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                u.hasVoted ? 'Sudah' : 'Belum',
                                style: TextStyle(
                                  color: u.hasVoted ? AppColors.success : AppColors.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (u.hasVoted && u.votedAt != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM HH:mm').format(u.votedAt!),
                                style: TextStyle(color: AppColors.textGray, fontSize: 11),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (e.key < voters.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCards(List<UserModel> voters) {
    if (voters.isEmpty) {
      return const Text('Belum ada pemilih terdaftar', style: TextStyle(color: AppColors.textGray));
    }
    return Column(
      children: voters.map((u) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (u.hasVoted ? AppColors.success : AppColors.warning).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      u.hasVoted ? 'Sudah Memilih' : 'Belum Memilih',
                      style: TextStyle(
                        color: u.hasVoted ? AppColors.success : AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(u.email, style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              Text('NIM: ${u.nim}', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              Text('Prodi: ${u.prodi}', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              if (u.hasVoted && u.votedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Waktu: ${DateFormat('dd MMM yyyy HH:mm').format(u.votedAt!)}',
                    style: const TextStyle(color: AppColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
