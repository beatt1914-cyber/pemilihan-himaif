import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = DataService();

    void onNav(SidebarItem item) {
      switch (item) {
        case SidebarItem.dashboard:
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
          Navigator.pushReplacementNamed(context, '/admin/settings');
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur ini masih dalam tahap pengembangan')),
          );
          break;
      }
    }

    final pct = ds.persentaseMasuk;

    return ResponsiveScaffold(
      activeItem: SidebarItem.dashboard,
      onItemTap: onNav,
      title: 'Admin Dashboard',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero Header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat Datang, ${ds.currentUser?.name ?? "Admin"}! 👋',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        const Text('Panel Administrasi Pemilihan HIMAIF',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _heroBadge(Icons.how_to_vote_rounded, '${ds.suaraMasuk} Suara Masuk'),
                            _heroBadge(Icons.people_rounded, '${ds.totalPemilih} Total Pemilih'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Stat Cards ──────────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth > 700
                  ? 4
                  : (constraints.maxWidth > 480 ? 2 : 2);
              final double cardWidth =
                  (constraints.maxWidth - (cols - 1) * 14) / cols;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(width: cardWidth, child: StatCard(title: 'Total Pemilih', value: '${ds.totalPemilih}', icon: Icons.people_rounded, color: AppColors.primaryBlue)),
                  SizedBox(width: cardWidth, child: StatCard(title: 'Suara Masuk', value: '${ds.suaraMasuk}', icon: Icons.how_to_vote_rounded, color: AppColors.success)),
                  SizedBox(width: cardWidth, child: StatCard(title: 'Belum Memilih', value: '${ds.belumMemilih}', icon: Icons.pending_rounded, color: AppColors.warning)),
                  SizedBox(width: cardWidth, child: StatCard(title: 'Kandidat', value: '${ds.candidates.length}', icon: Icons.people_alt_rounded, color: AppColors.accentBlue)),
                ],
              );
            }),
            const SizedBox(height: 24),

            // ─── Menu + Partisipasi ──────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final menuCard = _buildMenuCard(context);
              final partCard = _buildPartisipasiCard(ds, pct);
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: menuCard),
                    const SizedBox(width: 20),
                    SizedBox(width: 300, child: partCard),
                  ],
                );
              }
              return Column(children: [menuCard, const SizedBox(height: 16), partCard]);
            }),
            const SizedBox(height: 24),

            // ─── Candidate Quick View ─────────────────────────────────
            _buildCandidateSummary(context, ds),
          ],
        ),
      ),
    );
  }

  Widget _heroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.grid_view_rounded, color: AppColors.primaryBlue, size: 18),
            SizedBox(width: 8),
            Text('Menu Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 16),
          _menuItem(context, Icons.manage_accounts_rounded, 'Kelola Kandidat',
              'Tambah, edit & hapus data kandidat', '/admin/candidates', AppColors.primaryBlue),
          _menuItem(context, Icons.people_rounded, 'Kelola Pemilih',
              'Kelola daftar mahasiswa pemilih', '/admin/voters', AppColors.accentBlue),
          _menuItem(context, Icons.bar_chart_rounded, 'Hasil Voting',
              'Pantau hasil dan statistik pemilihan', '/admin/results', AppColors.success),
          _menuItem(context, Icons.settings_applications_rounded, 'Pengaturan Sistem',
              'Konfigurasi sistem pemilihan', '/admin/settings', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildPartisipasiCard(DataService ds, double pct) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.donut_large_rounded, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text('Partisipasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
          ]),
          const SizedBox(height: 20),
          // Big percentage circle-like display
          Center(
            child: Column(
              children: [
                Text('${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const Text('Tingkat Partisipasi', style: TextStyle(color: AppColors.textGray, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _progressStat('Suara Masuk', ds.suaraMasuk, ds.totalPemilih, AppColors.success),
          const SizedBox(height: 14),
          _progressStat('Belum Memilih', ds.belumMemilih, ds.totalPemilih, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildCandidateSummary(BuildContext context, DataService ds) {
    final maxVotes = ds.candidates.isEmpty ? 1 : ds.candidates.map((c) => c.votes).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.leaderboard_rounded, color: AppColors.warning, size: 18),
                SizedBox(width: 8),
                Text('Perolehan Suara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              ]),
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                label: const Text('Detail', style: TextStyle(fontSize: 12)),
                onPressed: () => Navigator.pushReplacementNamed(context, '/admin/results'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...ds.candidates.asMap().entries.map((entry) {
            final idx = entry.key;
            final c = entry.value;
            final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning, AppColors.accentBlue];
            final color = colors[idx % colors.length];
            final barPct = maxVotes == 0 ? 0.0 : c.votes / maxVotes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Center(child: Text('${idx + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.chairmanName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: barPct.toDouble(),
                            minHeight: 8,
                            backgroundColor: color.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${c.votes}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String sub, String route, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                  Text(sub, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _progressStat(String label, int value, int total, Color color) {
    final pct = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
            Text('$value / $total', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.toDouble(),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
