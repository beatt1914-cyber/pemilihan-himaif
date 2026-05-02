import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/data_service.dart';
import '../../models/candidate_model.dart';
import '../../widgets/app_sidebar.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});
  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chairmanCtrl = TextEditingController();
  final _viceCtrl = TextEditingController();
  final _visiCtrl = TextEditingController();
  final _misiCtrl = TextEditingController();
  bool _loading = false;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = file.name;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final ds = DataService();
    final newId = (ds.candidates.length + 1).toString();

    // Store image bytes in DataService for display
    String imagePath = '';
    if (_pickedImageBytes != null) {
      // Store as a unique key for in-memory image
      imagePath = 'memory://$newId';
      ds.storeImageBytes(newId, _pickedImageBytes!);
    }

    ds.addCandidate(CandidateModel(
      id: newId,
      chairmanName: _chairmanCtrl.text.trim(),
      viceName: _viceCtrl.text.trim(),
      visi: _visiCtrl.text.trim(),
      misi: _misiCtrl.text.trim().split('\n').where((s) => s.isNotEmpty).toList(),
      imagePath: imagePath,
      votes: 0,
    ));

    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Kandidat berhasil ditambahkan!'),
        ]),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          Navigator.pushReplacementNamed(context, '/admin/results');
          break;
        case SidebarItem.pengaturan:
          Navigator.pushReplacementNamed(context, '/admin/settings');
          break;
        default:
          break;
      }
    }

    return ResponsiveScaffold(
      activeItem: SidebarItem.kelolaKandidat,
      onItemTap: onNav,
      title: 'Tambah Kandidat',
      isAdmin: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali'),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text('Tambah Kandidat Baru',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final photoBox = _buildPhotoBox();
              final formBox = _buildForm();
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 220, child: photoBox),
                    const SizedBox(width: 28),
                    Expanded(child: formBox),
                  ],
                );
              }
              return Column(children: [photoBox, const SizedBox(height: 20), formBox]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Pasangan Kandidat',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.lightBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _pickedImageBytes != null ? AppColors.primaryBlue : AppColors.cardBorder,
                width: _pickedImageBytes != null ? 2 : 1,
              ),
            ),
            child: _pickedImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.memory(
                      _pickedImageBytes!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded,
                          size: 48, color: AppColors.primaryBlue.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      const Text('Tap untuk pilih foto',
                          style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Dari Galeri / Kamera',
                          style: TextStyle(color: AppColors.textGray, fontSize: 11)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        if (_pickedImageBytes != null)
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(_pickedImageName ?? 'Foto dipilih',
                    style: const TextStyle(color: AppColors.success, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: () => setState(() { _pickedImageBytes = null; _pickedImageName = null; }),
                child: const Icon(Icons.close, color: AppColors.danger, size: 16),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_rounded, size: 16),
              label: const Text('Pilih dari Galeri'),
              onPressed: _pickImage,
            ),
          ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Nama Calon Ketua', 'Masukkan nama lengkap ketua', _chairmanCtrl, Icons.person_rounded),
          const SizedBox(height: 14),
          _field('Nama Calon Wakil Ketua', 'Masukkan nama lengkap wakil ketua', _viceCtrl, Icons.person_outline),
          const SizedBox(height: 14),
          _fieldLong('Visi', 'Tuliskan visi kandidat...', _visiCtrl, 3),
          const SizedBox(height: 14),
          _fieldLong('Misi (1 poin per baris)', 'Baris 1: Misi pertama\nBaris 2: Misi kedua\n...', _misiCtrl, 6),
          const SizedBox(height: 28),
          Row(
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: _loading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(_loading ? 'Menyimpan...' : 'Simpan Kandidat'),
                  onPressed: _loading ? null : _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark));

  Widget _field(String label, String hint, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 18)),
          validator: (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _fieldLong(String label, String hint, TextEditingController ctrl, int lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: lines,
          decoration: InputDecoration(hintText: hint),
          validator: (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null,
        ),
      ],
    );
  }
}
