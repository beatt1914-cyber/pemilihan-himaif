class UserModel {
  final String nim;
  String name;
  String email;
  String prodi;
  final String role; // 'admin' | 'user'
  bool hasVoted;
  String? votedCandidateId;
  DateTime? votedAt;
  String? profileImagePath;

  UserModel({
    required this.nim,
    required this.name,
    required this.email,
    required this.prodi,
    this.role = 'user',
    this.hasVoted = false,
    this.votedCandidateId,
    this.votedAt,
    this.profileImagePath,
  });
}
