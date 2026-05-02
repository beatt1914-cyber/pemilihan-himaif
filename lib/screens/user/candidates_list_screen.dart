import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../models/candidate_model.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/candidate_photo.dart';

class CandidatesListScreen extends StatelessWidget {
  const CandidatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = DataService();

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
      title: 'Daftar Kandidat',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Kandidat',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 6),
            const Text('Pilih kandidat terbaik untuk HIMAIF',
                style: TextStyle(color: AppColors.textGray, fontSize: 13)),
            const SizedBox(height: 24),
            // Use Column with cards instead of GridView to avoid fixed aspect ratio issues
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 800
                    ? 3
                    : (constraints.maxWidth > 520 ? 2 : 1);
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: ds.candidates.map((c) {
                    final cardWidth = cols == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - (cols - 1) * 16) / cols;
                    return SizedBox(
                      width: cardWidth,
                      child: _CandidateCard(
                        candidate: c,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/user/candidate-detail',
                          arguments: c,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateCard extends StatefulWidget {
  final CandidateModel candidate;
  final VoidCallback onTap;
  const _CandidateCard({required this.candidate, required this.onTap});

  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final ds = DataService();
    final idx = ds.candidates.indexWhere((c) => c.id == widget.candidate.id);
    final colors = [
      AppColors.primaryBlue,
      AppColors.success,
      AppColors.warning
    ];
    final color = colors[idx % colors.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _hovered ? color : AppColors.cardBorder,
                  width: _hovered ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: _hovered ? 0.15 : 0.05),
                  blurRadius: _hovered ? 20 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with number
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.8), color]),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                  ),
                  child: Center(
                    child: Text('Paslon ${idx + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                // Photo - large, showing full upper body & face
                if (widget.candidate.imagePath.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: getImageProvider(widget.candidate.imagePath),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _avatar(widget.candidate.chairmanName, color, 30),
                          const SizedBox(width: 8),
                          _avatar(widget.candidate.viceName,
                              color.withValues(alpha: 0.7), 30),
                        ],
                      ),
                    ),
                  ),
                // Info section
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Text(widget.candidate.chairmanName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textDark)),
                      const Text('Calon Ketua HIMAIF',
                          style: TextStyle(
                              color: AppColors.textGray, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(widget.candidate.viceName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: color)),
                      const Text('Calon Wakil Ketua',
                          style: TextStyle(
                              color: AppColors.textGray, fontSize: 11)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10)),
                          onPressed: widget.onTap,
                          child: const Text('Lihat Detail',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String name, Color color, double radius) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: Text(name[0].toUpperCase(),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8)),
      ),
    );
  }
}
