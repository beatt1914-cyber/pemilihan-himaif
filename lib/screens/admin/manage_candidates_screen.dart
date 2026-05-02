import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../models/candidate_model.dart';
import '../../widgets/app_sidebar.dart';

class ManageCandidatesScreen extends StatefulWidget {
  const ManageCandidatesScreen({super.key});
  @override
  State<ManageCandidatesScreen> createState() => _ManageCandidatesScreenState();
}

class _ManageCandidatesScreenState extends State<ManageCandidatesScreen> {
  final ds = DataService();

  void _onNav(SidebarItem item) {
    switch (item) {
      case SidebarItem.dashboard:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
      case SidebarItem.kandidat:
      case SidebarItem.kelolaKandidat:
        break; // Already here
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
          const SnackBar(
              content: Text('Fitur ini masih dalam tahap pengembangan')),
        );
        break;
    }
  }

  void _deleteCandidate(String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kandidat'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              setState(() => ds.deleteCandidate(id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _editCandidate(CandidateModel c) {
    final chairCtrl = TextEditingController(text: c.chairmanName);
    final viceCtrl = TextEditingController(text: c.viceName);
    final imageCtrl = TextEditingController(text: c.imagePath);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Kandidat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chairCtrl,
              decoration: const InputDecoration(labelText: 'Nama Ketua'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: viceCtrl,
              decoration: const InputDecoration(labelText: 'Nama Wakil'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imageCtrl,
              decoration: const InputDecoration(labelText: 'URL Foto (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                c.chairmanName = chairCtrl.text;
                c.viceName = viceCtrl.text;
                c.imagePath = imageCtrl.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      activeItem: SidebarItem.kelolaKandidat,
      onItemTap: _onNav,
      title: 'Kelola Kandidat',
      isAdmin: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah'),
            onPressed: () async {
              await Navigator.pushNamed(context, '/admin/add-candidate');
              setState(() {});
            },
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kelola Kandidat',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambah Kandidat'),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/admin/add-candidate');
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Responsive: table on wide, cards on narrow
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return _buildTable();
              } else {
                return _buildCardList();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.lightBg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
                SizedBox(width: 200, child: Text('Kandidat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
                Expanded(child: Text('Visi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
                SizedBox(width: 80, child: Text('Suara', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
                SizedBox(width: 100, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textGray))),
              ],
            ),
          ),
          const Divider(height: 1),
          ...ds.candidates.asMap().entries.map((e) {
            final i = e.key;
            final c = e.value;
            final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning];
            final col = colors[i % colors.length];
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                        width: 40,
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: col))),
                    SizedBox(
                      width: 200,
                      child: Row(children: [
                        if (c.imagePath.isNotEmpty)
                          CircleAvatar(
                              radius: 18,
                              backgroundImage: c.imagePath.startsWith('http') ? NetworkImage(c.imagePath) as ImageProvider : AssetImage(c.imagePath))
                        else
                          CircleAvatar(
                              radius: 18,
                              backgroundColor: col,
                              child: Text(c.chairmanName[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.chairmanName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              Text('Wakil: ${c.viceName}',
                                  style: const TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: Text(c.visi,
                          style: const TextStyle(
                              color: AppColors.textGray, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(
                        width: 80,
                        child: Text('${c.votes}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: col))),
                    SizedBox(
                      width: 100,
                      child: Row(children: [
                        IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                color: AppColors.primaryBlue, size: 18),
                            onPressed: () => _editCandidate(c),
                            tooltip: 'Edit'),
                        IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                color: AppColors.danger, size: 18),
                            onPressed: () =>
                                _deleteCandidate(c.id, c.chairmanName),
                            tooltip: 'Hapus'),
                      ]),
                    ),
                  ],
                ),
              ),
              if (i < ds.candidates.length - 1) const Divider(height: 1),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    final colors = [AppColors.primaryBlue, AppColors.success, AppColors.warning];
    return Column(
      children: ds.candidates.asMap().entries.map((e) {
        final i = e.key;
        final c = e.value;
        final col = colors[i % colors.length];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: col.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              if (c.imagePath.isNotEmpty)
                CircleAvatar(
                  radius: 22,
                  backgroundImage: c.imagePath.startsWith('http') ? NetworkImage(c.imagePath) as ImageProvider : AssetImage(c.imagePath),
                )
              else
                CircleAvatar(
                    radius: 22,
                    backgroundColor: col,
                    child: Text(c.chairmanName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.chairmanName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Wakil: ${c.viceName}',
                        style: const TextStyle(
                            color: AppColors.textGray, fontSize: 12)),
                    Text('${c.votes} suara',
                        style: TextStyle(
                            color: col,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ],
                ),
              ),
              Row(children: [
                IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: AppColors.primaryBlue, size: 18),
                    onPressed: () => _editCandidate(c)),
                IconButton(
                    icon: const Icon(Icons.delete_rounded,
                        color: AppColors.danger, size: 18),
                    onPressed: () =>
                        _deleteCandidate(c.id, c.chairmanName)),
              ]),
            ],
          ),
        );
      }).toList(),
    );
  }
}
