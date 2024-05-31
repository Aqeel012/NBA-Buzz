
class TeamStatistics {
  final int id;
  final String code;
  final int fgm; // Field Goals Made
  final int fga; // Field Goals Attempted
  final double fgp; // Field Goals Percentage
  final int tpm; // Three Pointers Made
  final int tpa; // Three Pointers Attempted
  final double tpp; // Three Pointers Percentage
  final int assists;
  final int totalRebounds; // Total Rebounds

  TeamStatistics({
    required this.id,
    required this.code,
    required this.fgm,
    required this.fga,
    required this.fgp,
    required this.tpm,
    required this.tpa,
    required this.tpp,
    required this.assists,
    required this.totalRebounds,
  });

}
