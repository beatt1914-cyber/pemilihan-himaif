import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/candidate_photo.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});
  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final ds = DataService();

  void _onNav(SidebarItem item) {
    switch (item) {
      case SidebarItem.kandidat:
      case SidebarItem.voting:
        Navigator.pushReplacementNamed(context, '/user/candidates');
        break;
      case SidebarItem.profil:
        Navigator.pushReplacementNamed(context, '/user/profile');
        break;
      case SidebarItem.riwayat:
        Navigator.pushReplacementNamed(context, '/user/history');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ds.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id').format(now);

    return ResponsiveScaffold(
      activeItem: SidebarItem.beranda,
      onItemTap: _onNav,
      title: 'Dashboard',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero Banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A3A6B), AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${user.name}! 👋',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(formattedDate,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12)),
                        const SizedBox(height: 16),
                        if (!user.hasVoted) ...[
                          if (ds.isElectionActive) ...[
                            const Text(
                              'Suara Anda sangat berarti!\nYuk, pilih kandidat terbaikmu.',
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.how_to_vote_rounded, size: 18),
                              label: const Text('Pilih Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () => Navigator.pushReplacementNamed(context, '/user/candidates'),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Sesi pemilihan belum dimulai / sudah berakhir',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Sudah memilih pada ${DateFormat('dd MMM yyyy').format(user.votedAt!)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: user.profileImagePath != null
                        ? getImageProvider(user.profileImagePath!)
                        : null,
                    child: user.profileImagePath == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Stat Cards ───────────────────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth > 700 ? 3 : 2;
              final double w = (constraints.maxWidth - (cols - 1) * 14) / cols;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(width: w, child: StatCard(title: 'Jumlah Kandidat', value: '${ds.candidates.length}', icon: Icons.people_rounded, color: AppColors.primaryBlue)),
                  SizedBox(width: w, child: StatCard(title: 'Total Pemilih', value: '${ds.totalPemilih}', icon: Icons.how_to_vote_rounded, color: AppColors.success)),
                  SizedBox(width: w, child: StatCard(title: 'Suara Masuk', value: '${ds.suaraMasuk}', icon: Icons.bar_chart_rounded, color: AppColors.accentBlue)),
                  SizedBox(width: w, child: StatCard(title: 'Sisa Hari', value: _sisaHari(), icon: Icons.calendar_today_rounded, color: AppColors.warning)),
                ],
              );
            }),
            const SizedBox(height: 24),

            // ─── Aksi Cepat ───────────────────────────────────────────
            const Text('Aksi Cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth > 600 ? 3 : 2;
              final double w = (constraints.maxWidth - (cols - 1) * 14) / cols;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(width: w, child: _actionCard(
                    icon: Icons.search_rounded, title: 'Lihat Kandidat',
                    subtitle: 'Daftar semua paslon',
                    color: AppColors.primaryBlue,
                    onTap: () => Navigator.pushReplacementNamed(context, '/user/candidates'),
                  )),
                  SizedBox(width: w, child: _actionCard(
                    icon: Icons.history_rounded, title: 'Riwayat',
                    subtitle: 'Cek status votingmu',
                    color: AppColors.accentBlue,
                    onTap: () => Navigator.pushReplacementNamed(context, '/user/history'),
                  )),
                  SizedBox(width: w, child: _actionCard(
                    icon: Icons.person_rounded, title: 'Profil',
                    subtitle: 'Lihat & edit profil',
                    color: AppColors.warning,
                    onTap: () => Navigator.pushReplacementNamed(context, '/user/profile'),
                  )),
                  if (!user.hasVoted) SizedBox(width: w, child: _actionCard(
                    icon: Icons.how_to_vote_rounded, title: 'Mulai Voting',
                    subtitle: 'Pilih kandidatmu!',
                    color: AppColors.success,
                    onTap: () => Navigator.pushReplacementNamed(context, '/user/candidates'),
                  )),
                ],
              );
            }),
            const SizedBox(height: 24),

            // ─── Mini Leaderboard ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.leaderboard_rounded, color: AppColors.warning, size: 18),
                    SizedBox(width: 8),
                    Text('Perolehan Suara Sementara',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                  ]),
                  const SizedBox(height: 16),
                  ...ds.candidates.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final c = entry.value;
                    final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning, AppColors.accentBlue];
                    final color = colors[idx % colors.length];
                    final maxVotes = ds.candidates.map((c) => c.votes).reduce((a, b) => a > b ? a : b);
                    final pct = maxVotes == 0 ? 0.0 : c.votes / maxVotes;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                          child: Center(child: Text('${idx + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.chairmanName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: pct, minHeight: 7, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color)),
                            ),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        Text('${c.votes}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sisaHari() {
    final akhir = DateTime(2024, 5, 10);
    final now = DateTime.now();
    final diff = akhir.difference(now).inDays;
    return diff > 0 ? '$diff' : '0';
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: TextStyle(color: AppColors.textGray, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
