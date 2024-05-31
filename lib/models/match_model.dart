import 'package:intl/intl.dart';

class Match {
  final int id;
  final String league;
  final int season;
  final DateTime matchDate;
  final TimeOfDay startTime;
  final String status;
  final String? arenaName;
  final String? arenaCity;
  final String? arenaState;
  final Team homeTeam;
  final Team awayTeam;
  final Score homeScore;
  final Score awayScore;

  Match({
    required this.id,
    required this.league,
    required this.season,
    required this.matchDate,
    required this.startTime,
    required this.status,
    this.arenaName,
    this.arenaCity,
    this.arenaState,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final String dateTimeString = json['date']['start'] as String;
    final DateTime dateTimeUTC = DateTime.parse(dateTimeString);
    final DateTime dateTimeLocal = dateTimeUTC.toLocal();

    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = dateFormatter.format(dateTimeLocal);

    // Use a DateFormat that includes 'a' for AM/PM
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    final String formattedTime = timeFormatter.format(dateTimeLocal);

    final List<String> timeParts = formattedTime.split(':');
    final int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1].split(' ')[0]);
    final String period = timeParts[1].split(' ')[1];

    final TimeOfDay startTime = TimeOfDay(hour, minute, period);

    return Match(
      id: json['id'] as int,
      league: json['league'] as String,
      season: json['season'] as int,
      matchDate: DateTime.parse(formattedDate),
      startTime: startTime,
      status: json['status']['long'] as String,
      arenaName: json['arena']?['name'] as String?,
      arenaCity: json['arena']?['city'] as String?,
      arenaState: json['arena']?['state'] as String?,
      homeTeam: Team.fromJson(json['teams']['home'] as Map<String, dynamic>),
      awayTeam: Team.fromJson(json['teams']['visitors'] as Map<String, dynamic>),
      homeScore: Score.fromJson(json['scores']['home'] as Map<String, dynamic>),
      awayScore: Score.fromJson(json['scores']['visitors'] as Map<String, dynamic>),
    );
  }
}

class Team {
  final int id;
  final String name;
  final String nickname;
  final String code;
  final String logo;

  Team({
    required this.id,
    required this.name,
    required this.nickname,
    required this.code,
    required this.logo,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      nickname: json['nickname'],
      code: json['code'],
      logo: json['logo'],
    );
  }
}

class Score {
  final int points;
  final List<String> linescore;

  Score({
    required this.points,
    required this.linescore,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      points: json['points'] ?? 0,
      linescore: json['linescore'] != ''
          ? List<String>.from(json['linescore'].map<String>((x) => x.toString()))
          : ['0', '0', '0', '0'],
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  final String period; // Add period for AM/PM

  TimeOfDay(this.hour, this.minute, this.period);

  @override
  String toString() {
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  static TimeOfDay fromDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a');
    final String formatted = formatter.format(dateTime);
    final List<String> parts = formatted.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1].split(' ')[0]);
    final String period = parts[1].split(' ')[1];

    return TimeOfDay(hour, minute, period);
  }
}
