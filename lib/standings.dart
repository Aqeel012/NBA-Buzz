import 'dart:convert';
import 'dart:io'; // Import this to use SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/standings_model.dart';
import 'package:flutter_svg/svg.dart';
import 'layout/custom_bottom_app_bar.dart';

enum GroupingOptions { conference, division }
GroupingOptions _selectedGrouping = GroupingOptions.conference;

class NbaStandings extends StatefulWidget {
  const NbaStandings({super.key});

  @override
  _NbaStandingsState createState() => _NbaStandingsState();
}

class _NbaStandingsState extends State<NbaStandings> {
  List<Standings> standing = [];
  List<Standings> eastStanding = [];
  List<Standings> westStanding = [];
  List<Standings> atlanticStanding = [];
  List<Standings> centralStanding = [];
  List<Standings> southeastStanding = [];
  List<Standings> northwestStanding = [];
  List<Standings> pacificStanding = [];
  List<Standings> southwestStanding = [];
  String? error; // Add this field

  Future<void> getStandings() async {
    setState(() {
      error = null; // Clear any previous error
      standing = []; // Clear previous standings to show loading indicator
    });
    try {
      final url = Uri.https(
        'api-nba-v1.p.rapidapi.com',
        '/standings',
        {
          'league': 'standard',
          'season': '2023',
        },
      );

      final headers = {
        'X-RapidAPI-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
        'X-RapidAPI-Host': 'api-nba-v1.p.rapidapi.com',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch standings: ${response.statusCode}');
      }

      var jsonData = jsonDecode(response.body);

      final standingsList = <Standings>[]; // Create a new list for standings

      for (var eachStanding in jsonData['response']) {
        final standing1 = Standings(
          conferenceRank: eachStanding['conference']['rank'],
          divisionRank: eachStanding['division']['rank'],
          name: eachStanding['team']['name'],
          logo: eachStanding['team']['logo'],
          conference: eachStanding['conference']['name'],
          division: eachStanding['division']['name'],
          wins: eachStanding['win']['total'],
          losses: eachStanding['loss']['total'],
          winRatio: eachStanding['win']['percentage'].toString(),
          gamesBehind: eachStanding['gamesBehind'] ?? '0',
          conferenceRecord: '${eachStanding['conference']['win']}-${eachStanding['conference']['loss']}',
          divisionRecord: '${eachStanding['division']['win']}-${eachStanding['division']['loss']}',
          home: '${eachStanding['win']['home']}-${eachStanding['loss']['home']}',
          away: '${eachStanding['win']['away']}-${eachStanding['loss']['away']}',
          last10: '${eachStanding['win']['lastTen']}-${eachStanding['loss']['lastTen']}',
          winStreak: eachStanding['winStreak'],
          streak: eachStanding['streak'],
        );
        standingsList.add(standing1);
      }

      final east = <Standings>[];
      final west = <Standings>[];
      final atlantic = <Standings>[];
      final central = <Standings>[];
      final southeast = <Standings>[];
      final northwest = <Standings>[];
      final pacific = <Standings>[];
      final southwest = <Standings>[];

      for (var standing in standingsList) {
        if (standing.conference == 'east') {
          east.add(standing);

          if (standing.division == 'atlantic') {
            atlantic.add(standing);
          } else if (standing.division == 'central') {
            central.add(standing);
          } else if (standing.division == 'southeast') {
            southeast.add(standing);
          }
        } else if (standing.conference == 'west') {
          west.add(standing);
          if (standing.division == 'northwest') {
            northwest.add(standing);
          } else if (standing.division == 'pacific') {
            pacific.add(standing);
          } else if (standing.division == 'southwest') {
            southwest.add(standing);
          }
        }
      }

      east.sort((a, b) => a.conferenceRank.compareTo(b.conferenceRank));
      west.sort((a, b) => a.conferenceRank.compareTo(b.conferenceRank));
      atlantic.sort((a, b) => a.divisionRank.compareTo(b.divisionRank));
      central.sort((a, b) => a.divisionRank.compareTo(b.divisionRank));
      southeast.sort((a, b) => a.divisionRank.compareTo(b.divisionRank));
      northwest.sort((a, b) => a.divisionRank.compareTo(b.divisionRank));
      pacific.sort((a, b) => a.divisionRank.compareTo(b.divisionRank));
      southwest.sort((a, b) => a.divisionRank.compareTo(b.divisionRank));

      setState(() {
        standing = standingsList;
        eastStanding = east;
        westStanding = west;
        atlanticStanding = atlantic;
        centralStanding = central;
        southeastStanding = southeast;
        northwestStanding = northwest;
        pacificStanding = pacific;
        southwestStanding = southwest;
      });
    } on SocketException {
      setState(() {
        standing = [];
        error = 'No internet connection';
      });
    } catch (e) {
      setState(() {
        standing = [];
        error = 'Failed to fetch standings';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getStandings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STANDINGS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
      ),
      body: RefreshIndicator(
        onRefresh: getStandings, // Call getStandings when user swipes down
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 15),
                  Text(
                    'Group By:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Dropdown Button
                  DropdownButton<GroupingOptions>(
                    value: _selectedGrouping,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGrouping = newValue!;
                      });
                    },
                    items: GroupingOptions.values.map((option) {
                      return DropdownMenuItem<GroupingOptions>(
                        value: option,
                        child: Text(option.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  // Display error message if any
                  if (error != null)
                    Center(
                      child: Text(
                        error!,
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  else if (standing.isEmpty)
                    Center(child: CircularProgressIndicator()) // Show loading indicator
                  else
                    _selectedGrouping == GroupingOptions.conference
                        ? _buildConferenceStandings()
                        : _buildDivisionStandings(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  String truncateTeamName(String name) {
    List<String> words = name.split(' ');
    if (words.length > 2) {
      return words.take(2).join(' ') + '...';
    } else {
      return name;
    }
  }

  Widget _buildConferenceStandings() {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 15),child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'East',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(eastStanding,true),
        SizedBox(height: 25),
        Text(
          'West',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(westStanding,true),
        SizedBox(height: 25),

      ],
    ),);
  }

  Widget _buildDivisionStandings() {
    return Padding(padding:EdgeInsets.symmetric(horizontal: 15),child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atlantic Division',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(atlanticStanding,false),
        SizedBox(height: 25),
        Text(
          'Central Division',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(centralStanding,false),
        SizedBox(height: 25),
        Text(
          'Southeast Division',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(southeastStanding,false),
        SizedBox(height: 25),

        Text(
          'Northwest Division',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(northwestStanding,false),
        SizedBox(height: 25),
        Text(
          'Southwest Division',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(southwestStanding,false),
        SizedBox(height: 25),
        Text(
          'Pacific Division',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),

        _buildStandingsTable(pacificStanding,false),
        SizedBox(height: 25),

      ],
    ),);
  }

  Widget _buildStandingsTable(List<Standings> standings, bool confOrDiv) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DataTable(
            showBottomBorder: true,
            headingRowColor: MaterialStateProperty.resolveWith<Color>((states) {
              return Color.fromRGBO(227, 8, 8, 1.0);// Make the heading row red
            }),
            columns: [
              DataColumn(
                label: Container(
                  color:Color.fromRGBO(227, 8, 8, 1.0),
                  child: Text(
                    'Team',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            rows: standings.map((standing) {
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color>((states) {
                  return Colors.white; // Make the rows white
                }),
                cells: [

                  DataCell(Container(
                    width: 120,
                    height: 400,
                    child: Row(
                      children: [
                        Text(confOrDiv
                            ? standing.conferenceRank.toString()
                            : standing.divisionRank.toString()
                        ),
                        SizedBox(width: 7),

                        Image.network(standing.logo, height: 20, width: 20),
                        SizedBox(width: 5),
                        Expanded(child: Text(truncateTeamName(standing.name))),
                      ],
                    ),
                  )),
                ],
              );
            }).toList(),
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showBottomBorder: true,
                headingRowColor: MaterialStateProperty.resolveWith<Color>((states) {
                  return Color.fromRGBO(227, 8, 8, 1.0); // Make the heading row red
                }),
                columns: [
                  DataColumn(
                    label: Container(
                      width: 25, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'W',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 25, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'L',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'Win%',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color:Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'Conf',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'Div',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'Away',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'L10',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 50, // Constrain the width of the header cell
                      color: Color.fromRGBO(227, 8, 8, 1.0),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: 3), // Add padding to the header cells
                      child: Text(
                        'Streak',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                rows: standings.map((standing) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      return Colors.white; // Make the rows white
                    }),
                    cells: [
                      DataCell(Container(
                        width: 25, // Constrain the width of the data cell
                        child: Text(standing.wins.toString()),
                      )),
                      DataCell(Container(
                        width: 25, // Constrain the width of the data cell
                        child: Text(standing.losses.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(standing.winRatio.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(standing.conferenceRecord.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(standing.divisionRecord.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(standing.home.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(standing.away.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(standing.last10.toString()),
                      )),
                      DataCell(Container(
                        width: 50, // Constrain the width of the data cell
                        child: Text(
                          standing.streak.toString(),
                          style: TextStyle(color: standing.winStreak ? Colors.green : Colors.red),
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

}




