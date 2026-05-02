import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../models/candidate_model.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/candidate_photo.dart';

class CandidateDetailScreen extends StatelessWidget {
  const CandidateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final candidate =
        ModalRoute.of(context)?.settings.arguments as CandidateModel?;

    if (candidate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/user/candidates');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ds = DataService();
    final user = ds.currentUser;
    
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final idx = ds.candidates.indexWhere((c) => c.id == candidate.id);
    final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning];
    final color = colors[idx % colors.length];

    void onNav(SidebarItem item) {
      switch (item) {
        case SidebarItem.beranda:
          Navigator.pushReplacementNamed(context, '/user/dashboard');
          break;
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

    return ResponsiveScaffold(
      activeItem: SidebarItem.kandidat,
      onItemTap: onNav,
      title: 'Detail Kandidat',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final profileCard = _buildProfileCard(
                context, candidate, user, idx, color, ds);
            final visiMisiCard = _buildVisiMisi(candidate, color);

            return Column(
              children: [
                // Back button row
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Kembali'),
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/user/candidates'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 280, child: profileCard),
                      const SizedBox(width: 20),
                      Expanded(child: visiMisiCard),
                    ],
                  )
                else
                  Column(children: [profileCard, const SizedBox(height: 16), visiMisiCard]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    CandidateModel candidate,
    dynamic user,
    int idx,
    Color color,
    DataService ds,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text('${idx + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          if (candidate.imagePath.isNotEmpty)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 3),
                image: DecorationImage(
                  image: getImageProvider(candidate.imagePath),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bigAvatar(candidate.chairmanName, color, 34),
                const SizedBox(width: 8),
                _bigAvatar(candidate.viceName, color.withValues(alpha: 0.7), 34),
              ],
            ),
          const SizedBox(height: 14),
          Text(candidate.chairmanName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark)),
          const Text('Calon Ketua HIMAIF',
              style: TextStyle(color: AppColors.textGray, fontSize: 12)),
          const SizedBox(height: 6),
          Text(candidate.viceName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: color)),
          const Text('Calon Wakil Ketua',
              style: TextStyle(color: AppColors.textGray, fontSize: 12)),
          const SizedBox(height: 20),
          if (!user.hasVoted)
            if (ds.isElectionActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  icon: const Icon(Icons.how_to_vote_rounded, size: 18),
                  label: const Text('Pilih Kandidat Ini'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/user/voting-confirm',
                    arguments: candidate,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.danger, size: 20),
                    SizedBox(width: 8),
                    Text('Sesi pemilihan belum dimulai / sudah berakhir', 
                        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                  SizedBox(width: 8),
                  Text('Anda sudah memilih',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVisiMisi(CandidateModel candidate, Color color) {
    return Column(
      children: [
        _sectionText('Visi', candidate.visi, color),
        const SizedBox(height: 16),
        _sectionList('Misi', candidate.misi, color),
      ],
    );
  }

  Widget _bigAvatar(String name, Color color, double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(name[0].toUpperCase(),
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7)),
    );
  }

  Widget _sectionText(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ]),
          const SizedBox(height: 12),
          Text(content,
              style: const TextStyle(
                  color: AppColors.textDark, fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }

  Widget _sectionList(String title, List<String> items, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ]),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(e.value,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textDark,
                                height: 1.5))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
