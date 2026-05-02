import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../models/candidate_model.dart';

class VotingConfirmScreen extends StatelessWidget {
  const VotingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final candidate =
        ModalRoute.of(context)?.settings.arguments as CandidateModel?;
    final ds = DataService();
    
    if (candidate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/user/candidates');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (ds.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final idx = ds.candidates.indexWhere((c) => c.id == candidate.id);
    final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning];
    final color = colors[idx % colors.length];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.help_outline_rounded, color: color, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('Yakin memilih kandidat ini?',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Pilihan Anda tidak dapat diubah setelah dikonfirmasi.',
                  style: TextStyle(color: AppColors.textGray, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 22,
                      child: Text(candidate.chairmanName[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${idx + 1}. ${candidate.chairmanName}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: color)),
                          const Text('Calon Ketua HIMAIF',
                              style: TextStyle(
                                  color: AppColors.textGray, fontSize: 12)),
                          Text('Wakil: ${candidate.viceName}',
                              style: const TextStyle(
                                  color: AppColors.textGray, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal',
                          style: TextStyle(color: AppColors.textGray)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        ds.vote(candidate.id);
                        Navigator.pushReplacementNamed(
                          context,
                          '/user/voting-success',
                          arguments: candidate,
                        );
                      },
                      child: const Text('Ya, Pilih Kandidat Ini'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
