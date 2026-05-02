import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/app_sidebar.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = DataService();
    final user = ds.currentUser;
    
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
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
        case SidebarItem.profil:
          Navigator.pushReplacementNamed(context, '/user/profile');
          break;
        case SidebarItem.riwayat:
          // Already here
          break;
        default:
          break;
      }
    }

    return ResponsiveScaffold(
      activeItem: SidebarItem.riwayat,
      onItemTap: onNav,
      title: 'Riwayat Voting',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Pemilihan',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('Catatan partisipasi Anda dalam pemilihan HIMAIF',
                style: TextStyle(color: AppColors.textGray, fontSize: 13)),
            const SizedBox(height: 24),
            
            if (!user.hasVoted)
              _buildEmptyState(context)
            else
              _buildHistoryCard(user, ds),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.textGray.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Belum Ada Riwayat',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text(
            'Anda belum melakukan voting. Silakan kunjungi halaman kandidat untuk memberikan suara Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.how_to_vote_rounded, size: 18),
            label: const Text('Mulai Voting Sekarang'),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/user/candidates');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic user, DataService ds) {
    final candidate = ds.candidates.firstWhere((c) => c.id == user.votedCandidateId, 
      orElse: () => ds.candidates.first);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: AppColors.success.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Voting Berhasil',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textDark)),
                    Text(
                        'Direkam pada: ${DateFormat('EEEE, dd MMMM yyyy - HH:mm').format(user.votedAt!)}',
                        style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          const Text('Kandidat Pilihan Anda:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textGray)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (candidate.imagePath.isNotEmpty)
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: candidate.imagePath.startsWith('http') 
                        ? NetworkImage(candidate.imagePath) as ImageProvider 
                        : AssetImage(candidate.imagePath),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people_rounded, color: AppColors.primaryBlue),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate.chairmanName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark)),
                    Text('Wakil: ${candidate.viceName}',
                        style: const TextStyle(color: AppColors.textGray, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
