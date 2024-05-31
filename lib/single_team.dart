import 'dart:io';
import 'package:flutter/material.dart';
import './models/multiple_teams_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './models/player_model_for_team_page.dart';

class SingleTeamPage extends StatefulWidget {
  final MultipleTeams team;

  SingleTeamPage({required this.team});

  @override
  _SingleTeamPageState createState() => _SingleTeamPageState();
}

class _SingleTeamPageState extends State<SingleTeamPage> {
  String error = '';
  String games = '';
  String ppg = '';
  String rpg = '';
  String apg = '';

  List<PlayerModel> players=[];
  String playersError = '';


  @override
  void initState() {
    super.initState();
    _fetchTeamStats();
    _fetchPlayers();
  }

  Future<void> _fetchTeamStats() async {
    final url = Uri.https(
      'api-nba-v1.p.rapidapi.com',
      'teams/statistics',
      {'id': widget.team.id.toString(), 'season': '2023'},
    );

    final headers = {
      'X-RapidAPI-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
      'X-RapidAPI-Host': 'api-nba-v1.p.rapidapi.com',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final stats = jsonData['response'][0];

        setState(() {
          error = '';
          games = stats['games'].toString();

          // Calculate ppg, rpg, and apg
          final totalPoints = stats['points'];
          final totalRebounds = stats['totReb'];
          final totalAssists = stats['assists'];

          ppg = (totalPoints / stats['games']).toStringAsFixed(2);
          rpg = (totalRebounds / stats['games']).toStringAsFixed(2);
          apg = (totalAssists / stats['games']).toStringAsFixed(2);
        });
      } else {
        throw Exception('Failed to load team statistics');
      }
    } on SocketException catch (_) {
      setState(() {
        error = 'No internet connection';
      });
    } catch (error) {
      print('Error fetching team statistics: $error');
      setState(() {
        this.error = 'Failed to load team statistics';
      });
    }
  }


  Future<void> _fetchPlayers() async {
    final url = Uri.https(
      'api-nba-v1.p.rapidapi.com',
      'players',
      {'team': widget.team.id.toString(), 'season': '2023'},
    );

    final headers = {
      'X-RapidAPI-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
      'X-RapidAPI-Host': 'api-nba-v1.p.rapidapi.com',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final playersData = jsonData['response'];

        final activePlayers =playersData.where((playerData) =>
        playerData['leagues'] != null &&
            playerData['leagues']['standard'] != null &&
            playerData['leagues']['standard']['active'] == true).toList();

        setState(() {
          players = activePlayers.map<PlayerModel>((playerData) {
            return PlayerModel(
              id: playerData['id'],
              name: '${playerData['firstname'] ?? ''} ${playerData['lastname'] ?? ''}',
              birthdate: playerData['birth'] != null && playerData['birth']['date'] != null
                  ? DateTime.parse(playerData['birth']['date'])
                  : DateTime.now(),
              heightFeet: playerData['height'] != null && playerData['height']['feets'] != null
                  ? playerData['height']['feets']
                  : 'N/A',
              weightPounds: playerData['weight'] != null && playerData['weight']['pounds'] != null
                  ? playerData['weight']['pounds']
                  : 'N/A',
              position: playerData['leagues'] != null && playerData['leagues']['standard'] != null
                  ? playerData['leagues']['standard']['pos'] ?? 'N/A'
                  : 'N/A',
              jersey: playerData['leagues'] != null && playerData['leagues']['standard'] != null
                  ? playerData['leagues']['standard']['jersey'] ?? 0
                  : 0,
              affiliation: playerData['affiliation'] ?? 'N/A',
              draft: playerData['nba'] != null && playerData['nba']['start'] != null
                  ? playerData['nba']['start'] ?? 0
                  : 0,
              professional: playerData['nba'] != null && playerData['nba']['pro'] != null
                  ? playerData['nba']['pro']?? 0
                  : 0,
              teamId: widget.team.id,
              teamName: widget.team.name,
              teamLogo: widget.team.logo,
            );
          }).toList();
          playersError = ''; // Reset the error message
        });
      } else {
        throw Exception('Failed to load player data');
      }
    } on SocketException catch (_) {
      setState(() {
        playersError = 'No internet connection';
      });
    } catch (error) {
      print('Error fetching player data: $error');
      setState(() {
        playersError = 'Failed to load player data';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return error.isNotEmpty?
    Scaffold(
       backgroundColor: Colors.black,
        body: Center(
          child: Text(
            error,
            style: TextStyle(color: Color.fromRGBO(227, 8, 8, 1.0)),
           ),
         ),
       )
   :Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.team.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Image.network(
                    widget.team.logo,
                    // Adjust height as needed
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.team.name,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.team.conference} Conference',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBox('PPG', ppg),
                      SizedBox(width: 8),
                      _buildStatBox('APG', apg),
                      SizedBox(width: 8),
                      _buildStatBox('RPG', rpg),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey, height: 8, thickness: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roster',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  playersError.isNotEmpty? Center(
                    child: Text(
                      playersError,
                      style: TextStyle(color: Colors.red),
                    ),
                   )
                  : Wrap(
                    spacing: 10,
                    runSpacing: 20,
                    children: players.map((player) => _buildPlayerCard(
                      // replace with logic to get player image URL
                      // (e.g., from player data),
                      widget.team.logo,
                      player.name,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(String imageUrl, String playerName) {
    return Container(
      width: 70,
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 30,
          ),
          SizedBox(height: 8),
          Text(
            playerName,
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
