import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/match_model.dart';
import 'models/game_stats_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class MatchDetailsPage extends StatefulWidget {
  final Match match;

  const MatchDetailsPage({Key? key, required this.match}) : super(key: key);

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
   TeamStatistics? homeTeamStats;
   TeamStatistics? awayTeamStats;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if(widget.match.status=='Finished'){
    fetchAndStoreTeamStatistics(widget.match.id);
    }
  }

  Future<void> fetchAndStoreTeamStatistics(int gameId) async {
    try {
       final url = Uri.parse('https://api-nba-v1.p.rapidapi.com/games/statistics?id=$gameId');
      final response = await http.get(
        url,
        headers: {
          'X-Rapidapi-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
          'X-Rapidapi-Host': 'api-nba-v1.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)['response'] as List;
        final homeTeamStatsData = jsonData[0]['statistics'][0];
        final awayTeamStatsData = jsonData[1]['statistics'][0];

        homeTeamStats = TeamStatistics(
          id: jsonData[0]['team']['id'],
          code: jsonData[0]['team']['code'],
          fgm: homeTeamStatsData['fgm'],
          fga: homeTeamStatsData['fga'],
          fgp: double.parse(homeTeamStatsData['fgp']),
          tpm: homeTeamStatsData['tpm'],
          tpa: homeTeamStatsData['tpa'],
          tpp: double.parse(homeTeamStatsData['tpp']),
          assists: homeTeamStatsData['assists'],
          totalRebounds: homeTeamStatsData['totReb'],
        );

        awayTeamStats = TeamStatistics(
          id: jsonData[1]['team']['id'],
          code: jsonData[1]['team']['code'],
          fgm: awayTeamStatsData['fgm'],
          fga: awayTeamStatsData['fga'],
          fgp: double.parse(awayTeamStatsData['fgp']),
          tpm: awayTeamStatsData['tpm'],
          tpa: awayTeamStatsData['tpa'],
          tpp: double.parse(awayTeamStatsData['tpp']),
          assists: awayTeamStatsData['assists'],
          totalRebounds: awayTeamStatsData['totReb'],
        );

        setState(() {});
      } else {
        throw Exception('Failed to fetch team statistics');
      }
    } on SocketException {
      setState(() {
        errorMessage = 'No internet connection';
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to fetch team statistics';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
        title: const Text('Match Details', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
      iconTheme: IconThemeData(color: Colors.white),
      ),
      body:  SingleChildScrollView(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildMatchCard(),
            _buildArenaName(),
            SizedBox(height: 28,),
            _buildHeading('Summary'),
            _buildSummaryTable(),
            SizedBox(height: 28,),
          if (widget.match.status == "Finished") ...[
            _buildHeading('Team Comparison'),
            _buildTeamStatisticsCard('3 Pointers', homeTeamStats?.tpm ?? 0, homeTeamStats?.tpa ?? 0, awayTeamStats?.tpm ?? 0, awayTeamStats?.tpa ?? 0),
            _buildTeamStatisticsCard('Field Goals', homeTeamStats?.fgm ?? 0, homeTeamStats?.fga ?? 0, awayTeamStats?.fgm ?? 0, awayTeamStats?.fga ?? 0),
            _buildTeamStatisticsCard('Assists', homeTeamStats?.assists ?? 0, ((homeTeamStats?.assists ?? 0) + (awayTeamStats?.assists ?? 0)), awayTeamStats?.assists ?? 0, ((homeTeamStats?.assists ?? 0) + (awayTeamStats?.assists ?? 0))),
            _buildTeamStatisticsCard('Rebounds', homeTeamStats?.totalRebounds ?? 0,((homeTeamStats?.totalRebounds ?? 0) + (awayTeamStats?.totalRebounds ?? 0)), awayTeamStats?.totalRebounds ?? 0, ((homeTeamStats?.totalRebounds ?? 0) + (awayTeamStats?.totalRebounds ?? 0))),
         ],
         ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        DateFormat('MMM dd, yyyy').format(widget.match.matchDate),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildMatchCard() {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: 8.0,),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Image.network(
                        widget.match.homeTeam.logo, width: 80, height: 80),
                    Text(widget.match.homeTeam.code, style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    if (widget.match.status == "Scheduled")
                      Text('${widget.match.startTime}', style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                    if (widget.match.status == "Finished")
                      Center(
                        child: Row(
                          children: [
                            Text(
                              '${widget.match.homeScore.points}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: widget.match.homeScore.points >
                                    widget.match.awayScore.points
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                            SizedBox(width: 7),
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 7),
                            Text(
                              '${widget.match.awayScore.points}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: widget.match.awayScore.points >
                                    widget.match.homeScore.points
                                    ? Colors.red
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Column(
                  children: [
                    Image.network(
                        widget.match.awayTeam.logo, width: 80, height: 80),
                    Text(widget.match.awayTeam.code, style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  Widget _buildArenaName() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '${widget.match.arenaName} Arena',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTeamStatisticsCard(String title, int homeattemped, int homeTeammade, int awayattempted, int awaymade) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.match.homeTeam.code,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$homeattemped / $homeTeammade',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    value:100,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.match.awayTeam.code,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$awayattempted / $awaymade',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable() {
    String getLinescoreValue(List<String> linescore, int index) {
      return index < linescore.length ? linescore[index] : '0';
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DataTable(
              columnSpacing: 20,
              columns: [
                DataColumn(label: Text('Teams', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Q1', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Q2', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Q3', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Q4', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text(widget.match.homeTeam.code)),
                  DataCell(Text(getLinescoreValue(widget.match.homeScore.linescore, 0))),
                  DataCell(Text(getLinescoreValue(widget.match.homeScore.linescore, 1))),
                  DataCell(Text(getLinescoreValue(widget.match.homeScore.linescore, 2))),
                  DataCell(Text(getLinescoreValue(widget.match.homeScore.linescore, 3))),
                  DataCell(Text(widget.match.homeScore.points.toString())),
                ]),
                DataRow(cells: [
                  DataCell(Text(widget.match.awayTeam.code)),
                  DataCell(Text(getLinescoreValue(widget.match.awayScore.linescore, 0))),
                  DataCell(Text(getLinescoreValue(widget.match.awayScore.linescore, 1))),
                  DataCell(Text(getLinescoreValue(widget.match.awayScore.linescore, 2))),
                  DataCell(Text(getLinescoreValue(widget.match.awayScore.linescore, 3))),
                  DataCell(Text(widget.match.awayScore.points.toString())),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
