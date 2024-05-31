class PlayerModel {
  final String playerId;
  final String firstName;
  final String lastName;
  final String height;
  final String weight;
  final List<String> positions; // Change to List<String> or String
  final String dateBorn;
  final String dateDied;
  final String birthPlace;
  final String draftInfo;
  final String nbaDebut;
  final List<String> accolades;
  final List<String> teams;
  final String headshotUrl;

  PlayerModel({
    required this.playerId,
    required this.firstName,
    required this.lastName,
    required this.height,
    required this.weight,
    required this.positions,
    required this.dateBorn,
    required this.dateDied,
    required this.birthPlace,
    required this.draftInfo,
    required this.nbaDebut,
    required this.accolades,
    required this.teams,
    required this.headshotUrl,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    // Extract positions field from JSON
    dynamic positionsJson = json['positions'];

    // Check if positionsJson is a list
    List<String> positionsList = [];
    if (positionsJson is List) {
      positionsList = positionsJson.map((position) => position.toString()).toList();
    } else if (positionsJson != null) {
      // If not a list, treat it as a single string
      positionsList = [positionsJson.toString()];
    }

    return PlayerModel(
      playerId: json['playerId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      positions: positionsList,
      dateBorn: json['dateBorn'] as String? ?? '',
      dateDied: json['dateDied'] as String? ?? '',
      birthPlace: json['birthPlace'] as String? ?? '',
      draftInfo: json['draftInfo'] as String? ?? '',
      nbaDebut: json['nbaDebut'] as String? ?? '',
      accolades: (json['accolades'] as List<dynamic>?)
          ?.map((accolade) => accolade.toString())
          .toList() ?? [],
      teams: (json['teams'] as List<dynamic>?)
          ?.map((team) => team.toString())
          .toList() ?? [],
      headshotUrl: json['headshotUrl'] as String? ?? '',
    );
  }

}
