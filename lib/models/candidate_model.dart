class CandidateModel {
  final String id;
  String chairmanName;
  String viceName;
  String visi;
  List<String> misi;
  String imagePath;
  int votes;

  CandidateModel({
    required this.id,
    required this.chairmanName,
    required this.viceName,
    required this.visi,
    required this.misi,
    this.imagePath = '',
    this.votes = 0,
  });
}
