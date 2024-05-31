import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './match_details.dart';
import './models/match_model.dart'; // Import your Match model here

class MatchesPage extends StatefulWidget  {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> with SingleTickerProviderStateMixin {
  late List<Match> todayMatches = [];
  late List<Match> yesterdayMatches = [];
  late List<Match> tomorrowMatches = [];
  List<Match> searchedMatches = [];

  bool isLoading = true;
  String error = '';
  String searchDate = '';

  int selectedTabIndex = 0;
  late TabController _tabController;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchMatches();

  }

  Future<void> fetchMatches() async {
    final DateTime now = DateTime.now();
    final String formattedToday = formatDate(now);
    final String formattedYesterday = formatDate(now.subtract(Duration(days: 1)));
    final String formattedTomorrow = formatDate(now.add(Duration(days: 3)));

    try {
      final todayResponse = await fetchMatchesByDate(formattedToday);
      final yesterdayResponse = await fetchMatchesByDate(formattedYesterday);
      final tomorrowResponse = await fetchMatchesByDate(formattedTomorrow);

      setState(() {
        todayMatches = todayResponse;
        yesterdayMatches = yesterdayResponse;
        tomorrowMatches = tomorrowResponse;
        isLoading = false;
      });
    } on SocketException {
      setState(() {
        error = 'No internet connection';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load matches';
        isLoading = false;
      });
    }
  }

  Future<List<Match>> fetchMatchesByDate(String date) async {
    final url = Uri.parse('https://api-nba-v1.p.rapidapi.com/games?date=$date');
    final response = await http.get(
      url,
      headers: {
        'X-Rapidapi-Key': '4cdf9301f0msh5e334ef2f09d688p1a9b0ajsn2647fdb727b7',
        'X-Rapidapi-Host': 'api-nba-v1.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['response'];
      return data.map((e) => Match.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<void> searchMatches(String date) async {

    try {
      final searchResponse = await fetchMatchesByDate(date);
      setState(() {
        searchedMatches = searchResponse;

      });
    } on SocketException {
      setState(() {
        error = 'No internet connection';
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load matches';
      });
    }
  }


  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
     _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
        title: const Text('Matches', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Live'),
            Tab(text: 'Scheduled'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
        },
        child: TabBarView(

          controller: _tabController,
          children: [
            _buildLivePage(),
            _buildScheduledPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePage() {
    return Center(
      child: Text('No live match now', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildScheduledPage() {
    return RefreshIndicator(  onRefresh: () => fetchMatches(),

    child: error.isNotEmpty?Center(child: Text( error, style: TextStyle(color: Colors.white),),)
    :isLoading?Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),),)
     :Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            focusNode: _searchFocusNode,
            style: TextStyle(color: Colors.black), // Inside text color
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: '(YYYY-MM-DD) search matches by date',
              hintStyle: TextStyle(color: Colors.black38), // Placeholder text color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),

            onSubmitted: (value) {
              setState(() {
                searchDate = value;
              });
              if (_isCompleteDate(value)) {
                searchMatches(value);
              }
            },
          ),
        ),
        Expanded(
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),

            children: [

              if (searchDate.isNotEmpty)
                searchedMatches.isEmpty?Center(child: Text('No Fixtures on $searchDate',style: TextStyle(color: Colors.white,fontStyle: FontStyle.italic),),)
               : _buildMatchSection('Search Results', _getMatchesForDate(searchedMatches)),
              _buildMatchSection('Yesterday', _getMatchesForDate(yesterdayMatches)),
              _buildMatchSection('Today', _getMatchesForDate(todayMatches)),
              _buildMatchSection('Tomorrow', _getMatchesForDate(tomorrowMatches)),
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildMatchSection(String sectionTitle, List<Widget> matchCards) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                sectionTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
              ),
            ),
            (matchCards.isEmpty)?
            Center(
              child: Text(
                'No fixtures $sectionTitle',
                style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
              ),
            ):
            SizedBox(
              height: 160,  // Adjusted height for the card container
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: matchCards,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getMatchesForDate(List<Match> matches) {
    return matches.map((match) => _buildMatchCard(match)).toList();
  }

  Widget _buildMatchCard(Match match) {
    // Determine the winner
    String winner = match.homeScore.points > match.awayScore.points ? match.homeTeam.code : match.awayTeam.code;

    return GestureDetector(
           onTap: () {
           Navigator.push(
             context,
              MaterialPageRoute(
             builder: (context) => MatchDetailsPage(match: match),
         ),
      );
    },child:
     Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: 280,  // Adjusted width for the card
        height: 140, // Adjusted height for the card
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(match.league, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.black45)),
            SizedBox(height: 16), // Increased space between the league text and logos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    // Use team logo from match.homeTeam.logo
                    Image.network(match.homeTeam.logo, width: 40, height: 40),
                    Text(match.homeTeam.code, style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                     (match.status == "Scheduled")?
                      Text('${match.startTime}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))

                     :Center(child:Row(
                       children: [

                         Text('${match.homeScore.points}',
                           style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: match.homeScore.points > match.awayScore.points ? Colors.red : Colors.black,
                           ),
                         ),
                         SizedBox(width: 7,),
                         Text('-',
                           style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                            ),
                         ),
                         SizedBox(width: 7,),
                         Text('${match.awayScore.points}',
                              style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: match.awayScore.points > match.homeScore.points ? Colors.red : Colors.black,
                           ),
                         ),
                       ],
                     ),
                     ),
                  ],
                ),
                Column(
                  children: [
                    // Use team logo from match.awayTeam.logo
                    Image.network(match.awayTeam.logo, width: 40, height: 40),
                    Text(match.awayTeam.code, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  bool _isCompleteDate(String value) {
    // Example of checking if the entered text is in the format YYYY-MM-DD
    RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return datePattern.hasMatch(value);
  }

}
