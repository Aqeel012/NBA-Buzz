class Standings {
  final int conferenceRank;
  final int divisionRank;
  final String name;
  final String logo;
  final String conference;  // conference name like east or west
  final String division;  // division name
  final int wins;
  final int losses;
  final String winRatio;
  final String gamesBehind;
  final String conferenceRecord; //"conference wins-conference loss" in string form(6-2)
  final String divisionRecord;  //"division wins-conference losses"
  final String home;    // home wins - home losses (13-6) etc
  final String away;    //away wins- away losses same like others
  final String last10;
  final bool winStreak;
  final int streak;

  Standings({
    required this.conferenceRank,
    required  this.divisionRank,
    required this.name,
    required this.logo,
    required this.conference,
    required this.division,
    required this.wins,
    required this.losses,
    required this.winRatio,
    required this.gamesBehind,
    required this.conferenceRecord,
    required this.divisionRecord,
    required this.home,
    required this.away,
    required this.last10,
    required this.streak,
    required this.winStreak,

  });
}



