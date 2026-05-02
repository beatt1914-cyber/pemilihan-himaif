import 'dart:typed_data';
import '../models/candidate_model.dart';
import '../models/user_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  UserModel? currentUser;
  final Map<String, Uint8List> _imageCache = {};

  // Election configurations
  DateTime? electionStartTime;
  DateTime? electionEndTime;

  bool get isElectionActive {
    final now = DateTime.now();
    if (electionStartTime != null && now.isBefore(electionStartTime!)) return false;
    if (electionEndTime != null && now.isAfter(electionEndTime!)) return false;
    return true;
  }

  void storeImageBytes(String id, Uint8List bytes) => _imageCache[id] = bytes;
  Uint8List? getImageBytes(String id) => _imageCache[id];

  final List<CandidateModel> candidates = [
    CandidateModel(
      id: '1',
      chairmanName: 'PIKI SAPUTRA',
      viceName: 'RHADO FHAREL NASUTION',
      visi:
          'Menjadikan HIMAIF sebagai organisasi yang inovatif, inklusif, dan berdampak bagi mahasiswa Informatika Universitas Prabumulih.',
      misi: [
        'Meningkatkan kualitas kegiatan akademik dan non-akademik mahasiswa',
        'Membangun komunikasi yang baik antara mahasiswa dan dosen',
        'Mengadakan program pelatihan dan pengembangan skill digital',
        'Mendorong partisipasi aktif seluruh mahasiswa Informatika',
      ],
      imagePath: 'assets/images/paslon 1.jpeg',
      votes: 129,
    ),
    CandidateModel(
      id: '2',
      chairmanName: 'NELSHEN ZARIKO APRIAL',
      viceName: 'DIMAS SAPUTRA',
      visi:
          'Mewujudkan mahasiswa Informatika yang kompeten, berkarakter, dan berprestasi di tingkat nasional.',
      misi: [
        'Meningkatkan fasilitas belajar dan ruang diskusi mahasiswa',
        'Menjalin kerjasama dengan industri teknologi terkemuka',
        'Membentuk komunitas belajar berbasis teknologi',
        'Meningkatkan kesejahteraan mahasiswa melalui beasiswa',
      ],
      imagePath: 'assets/images/paslon 2.jpeg',
      votes: 90,
    ),
    CandidateModel(
      id: '3',
      chairmanName: 'RHAFA KARTA WIJAYA',
      viceName: 'ANTHERA AKBAR VALENTINO',
      visi:
          'Membangun HIMAIF yang solid, produktif, dan mampu menjadi wadah aspirasi seluruh mahasiswa Informatika.',
      misi: [
        'Transparansi dan akuntabilitas dalam pengelolaan organisasi',
        'Peningkatan kegiatan sosial kemasyarakatan',
        'Pengembangan program kewirausahaan mahasiswa',
        'Optimalisasi media sosial HIMAIF sebagai sarana informasi',
      ],
      imagePath: 'assets/images/paslon 3.jpeg',
      votes: 70,
    ),
    CandidateModel(
      id: '4',
      chairmanName: 'MUHAMMAD SAPUTRA',
      viceName: 'ANDEA FARHAN PRATAMA',
      visi: 'Menjadi wadah aspiratif, inovatif, dan kolaboratif bagi mahasiswa Informatika untuk berkembang secara akademik, profesional, dan sosial demi terciptanya generasi teknologi yang unggul dan berdampak..',
      misi: [
        'Akademik: Memfasilitasi program pengembangan skill seperti bootcamp, workshop coding, dan lomba IT.',
        'Profesional: Membangun relasi dengan industri, alumni, dan komunitas IT melalui kunjungan dan magang.',
        'Internal: Mempererat solidaritas antar anggota HIMAIF lewat kegiatan bonding dan forum diskusi rutin.',
        'Pengabdian: Mengadakan kegiatan sosial berbasis teknologi yang bermanfaat untuk masyarakat.',
        'Inovasi: Mendorong budaya riset dan karya dengan mengadakan hackathon dan showcase proyek.',
      ],
      imagePath: 'assets/images/paslon 4.jpeg',
      votes: 150,
    ),
  ];

  final List<UserModel> users = [
    UserModel(
      nim: 'admin',
      name: 'Administrator',
      email: 'admin@himaif.ac.id',
      prodi: 'Informatika',
      role: 'admin',
    ),
    UserModel(
      nim: '2310631023',
      name: 'Ahmad Fauzi',
      email: 'ahmadfauzi@gmail.com',
      prodi: 'Informatika',
      hasVoted: true,
      votedCandidateId: '1',
      votedAt: DateTime(2024, 5, 1),
    ),
  ];

  int get totalPemilih => 325;
  int get suaraMasuk => candidates.fold(0, (s, c) => s + c.votes);
  int get belumMemilih => totalPemilih - suaraMasuk;
  double get persentaseMasuk => (suaraMasuk / totalPemilih) * 100;

  UserModel? login(String emailOrNim, String password) {
    final input = emailOrNim.trim().toLowerCase();
    // Admin bypass by email
    if ((input == 'admin@himaif.ac.id' || input == 'admin') && password == 'admin123') {
      currentUser = users.firstWhere((u) => u.nim == 'admin');
      return currentUser;
    }
    // Match by email or NIM
    final found = users.where((u) => 
      u.email.toLowerCase() == input || 
      u.nim.toLowerCase() == input
    ).toList();
    
    if (found.isNotEmpty && password.isNotEmpty) {
      currentUser = found.first;
      return currentUser;
    }
    return null;
  }

  UserModel register({
    required String nim,
    required String name,
    required String email,
    required String password,
  }) {
    final user = UserModel(
      nim: nim.trim(),
      name: name.trim(),
      email: email.trim(),
      prodi: 'Informatika',
    );
    users.add(user);
    // Tidak mengatur currentUser di sini agar pengguna harus login secara manual
    return user;
  }

  bool vote(String candidateId) {
    if (currentUser == null || currentUser!.hasVoted || !isElectionActive) return false;
    final idx = candidates.indexWhere((c) => c.id == candidateId);
    if (idx == -1) return false;
    candidates[idx].votes++;
    currentUser!.hasVoted = true;
    currentUser!.votedCandidateId = candidateId;
    currentUser!.votedAt = DateTime.now();
    final uIdx = users.indexWhere((u) => u.nim == currentUser!.nim);
    if (uIdx != -1) users[uIdx] = currentUser!;
    return true;
  }

  void addCandidate(CandidateModel c) => candidates.add(c);
  void deleteCandidate(String id) => candidates.removeWhere((c) => c.id == id);
  void logout() => currentUser = null;
}
