import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './models/multiple_teams_model.dart';
import './single_team.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<MultipleTeams> atlanticTeams = [];
  List<MultipleTeams> centralTeams = [];
  List<MultipleTeams> southeastTeams = [];
  List<MultipleTeams> northwestTeams = [];
  List<MultipleTeams> southwestTeams = [];
  List<MultipleTeams> pacificTeams = [];
  String? error = '';



  @override

  void initState() {
    super.initState();
    _fetchTeamsByDivision('atlantic');
    _fetchTeamsByDivision('central');
    _fetchTeamsByDivision('southeast');
    _fetchTeamsByDivision('northwest');
    _fetchTeamsByDivision('southwest');
    _fetchTeamsByDivision('pacific');
  }

  Future<void> _refreshData() async {
    await _fetchTeamsByDivision('atlantic');
    await _fetchTeamsByDivision('central');
    await _fetchTeamsByDivision('southeast');
    await _fetchTeamsByDivision('northwest');
    await _fetchTeamsByDivision('southwest');
    await _fetchTeamsByDivision('pacific');
  }

  Future<void> _fetchTeamsByDivision(String division) async {
    setState(() {
      error = null; // Clear any previous error
     });

    final url = Uri.https(
      'api-nba-v1.p.rapidapi.com',
      '/teams',
      {'division': division.toLowerCase()},
    );

    final headers = {
      'X-RapidAPI-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
      'X-RapidAPI-Host': 'api-nba-v1.p.rapidapi.com',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<MultipleTeams> teams = (jsonData['response'] as List).map<MultipleTeams>((teamJson) {
          if (teamJson['logo'] != null && teamJson['logo'].isNotEmpty) {
            return MultipleTeams(
              id: teamJson['id'],
              name: teamJson['name'],
              logo: teamJson['logo'],
              conference: teamJson['leagues']['standard']['conference'],
              division: teamJson['leagues']['standard']['division'],
              city: teamJson['city'],
            );
          } else {
            return  MultipleTeams(
              id: teamJson['id'],
              name: teamJson['name'],
              logo: '', // Empty logo
              conference: teamJson['leagues']['standard']['conference'],
              division: teamJson['leagues']['standard']['division'],
              city: teamJson['city'],
            ); // Return null for teams with null or empty logos
          }
        }).where((team) => team.logo.isNotEmpty).toList();
        setState(() {
          switch (division) {
            case 'atlantic':
              atlanticTeams = teams;
              break;
            case 'central':
              centralTeams = teams;
              break;
            case 'southeast':
              southeastTeams = teams;
              break;
            case 'northwest':
              northwestTeams = teams;
              break;
            case 'southwest':
              southwestTeams = teams;
              break;
            case 'pacific':
              pacificTeams = teams;
              break;
            default:
          }
        });
       }
    } on SocketException {
      setState(() {
        atlanticTeams = [];
         centralTeams = [];
         southeastTeams = [];
          northwestTeams = [];
         southwestTeams = [];
          pacificTeams = [];
        error = 'No internet connection';
      });
    } catch (e) {
      setState(() {
        atlanticTeams = [];
        centralTeams = [];
        southeastTeams = [];
        northwestTeams = [];
        southwestTeams = [];
        pacificTeams = [];
         error = 'Failed to fetch teams';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TEAMS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
      ),
      body:RefreshIndicator(
       onRefresh: _refreshData ,
       child:
      SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error!=null)
                Text(
                  error!,
                  style: TextStyle(color: Color.fromRGBO(227, 8, 8, 1.0)),
                ),
              _buildDivisionCard('Atlantic Division', atlanticTeams),
              SizedBox(height: 14,),
               _buildDivisionCard('Central Division', centralTeams),
              SizedBox(height: 14,),
               _buildDivisionCard('Southeast Division', southeastTeams),
              SizedBox(height: 14,),

              _buildDivisionCard('Northwest Division', northwestTeams),
              SizedBox(height: 14,),

              _buildDivisionCard('Southwest Division', southwestTeams),
              SizedBox(height: 14,),

              _buildDivisionCard('Pacific Division', pacificTeams),
              SizedBox(height: 14,),

            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildDivisionCard(String divisionName, List<MultipleTeams> teams) {
    return Card(
      color: Colors.white,
      elevation: 7,
      shadowColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                divisionName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (var team in teams)
                  _buildTeamCard(team),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTeamCard(MultipleTeams team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleTeamPage(team:team),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(team.logo),
            radius: 30,
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              team.name,
              style: TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis, // Truncate with ellipsis if exceeds available space
              maxLines: 2, // Allow up to 2 lines for wrapping
            ),
          ),
        ],
      ),
    );
  }



}
