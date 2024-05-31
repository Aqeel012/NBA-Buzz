class PlayerModel {
  final int id;
  final String name;
  final DateTime birthdate;
  final String heightFeet;
  final String weightPounds;
  final String position;
  final int jersey;
  final String affiliation;
  final int draft;
  final int professional;
  final int teamId;
  final String teamName;
  final String teamLogo;

  PlayerModel({
    required this.id,
    required this.name,
    required this.birthdate,
    required this.heightFeet,
    required this.weightPounds,
    required this.position,
    required this.jersey,
    required this.affiliation,
    required this.draft,
    required this.professional,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
  });

}
