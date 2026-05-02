import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../widgets/app_sidebar.dart';

class VotingResultsScreen extends StatelessWidget {
  const VotingResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = DataService();
    final total = ds.suaraMasuk;
    final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning];

    void onNav(SidebarItem item) {
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
          break; // Already here
        case SidebarItem.pengaturan:
          Navigator.pushReplacementNamed(context, '/admin/settings');
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Fitur ini masih dalam tahap pengembangan')),
          );
          break;
      }
    }

    return ResponsiveScaffold(
      activeItem: SidebarItem.hasilVoting,
      onItemTap: onNav,
      title: 'Hasil Voting',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final pieCard = _buildPieCard(ds, total, colors);
          final detailCard = _buildDetailCard(ds, total, colors);
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 320, child: pieCard),
                const SizedBox(width: 20),
                Expanded(child: detailCard),
              ],
            );
          }
          return Column(children: [
            pieCard,
            const SizedBox(height: 16),
            detailCard
          ]);
        }),
      ),
    );
  }

  Widget _buildPieCard(DataService ds, int total, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Text('Hasil Voting',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark)),
          Text('Ringkasan pemilihan suara kandidat',
              style: TextStyle(color: AppColors.textGray, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: ds.candidates.asMap().entries.map((e) {
                  final pct = total > 0 ? e.value.votes / total * 100 : 0.0;
                  return PieChartSectionData(
                    value: e.value.votes.toDouble(),
                    color: colors[e.key % colors.length],
                    radius: 72,
                    title: '${pct.toStringAsFixed(1)}%',
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  );
                }).toList(),
                centerSpaceRadius: 36,
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...ds.candidates.asMap().entries.map((e) {
            final pct = total > 0
                ? (e.value.votes / total * 100).toStringAsFixed(1)
                : '0';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: colors[e.key % colors.length],
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        '${e.key + 1}. ${e.value.chairmanName}',
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Text('${e.value.votes} ($pct%)',
                      style: TextStyle(
                          color: colors[e.key % colors.length],
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Suara',
                  style:
                      TextStyle(color: AppColors.textGray, fontSize: 13)),
              Text('$total',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.textDark)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Persentase',
                  style:
                      TextStyle(color: AppColors.textGray, fontSize: 12)),
              Text(
                  '${ds.persentaseMasuk.toStringAsFixed(2)}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.success)),
            ],
          ),
          Text('dari total ${ds.totalPemilih} pemilih',
              style: TextStyle(color: AppColors.textGray, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetailCard(DataService ds, int total, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Hasil Voting',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),
          ...ds.candidates.asMap().entries.map((e) {
            final i = e.key;
            final c = e.value;
            final pct = total > 0 ? c.votes / total : 0.0;
            final color = colors[i % colors.length];
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: color.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(c.chairmanName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text('Wakil: ${c.viceName}',
                                style: TextStyle(
                                    color: AppColors.textGray,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${c.votes}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: color)),
                          Text(
                              '${(pct * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct.toDouble(),
                      minHeight: 10,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          _infoRow('Total Pemilih', '${ds.totalPemilih}'),
          _infoRow('Suara Masuk', '${ds.suaraMasuk}'),
          _infoRow('Persentase',
              '${ds.persentaseMasuk.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text('• $label: ',
              style:
                  TextStyle(color: AppColors.textGray, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      );
}
