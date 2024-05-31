import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'player_details.dart';
import './models/player_model.dart'; // Importing PlayerModel from another file

class PlayersPage extends StatefulWidget {
  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  TextEditingController _searchController = TextEditingController();
  List<PlayerModel> _players = [];
  List<PlayerModel> _filteredPlayers = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = 'https://basketball-head.p.rapidapi.com/players';
    final headers = {
      'content-type': 'application/json',
      'X-RapidAPI-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
      'X-RapidAPI-Host': 'basketball-head.p.rapidapi.com',
    };
    final body = json.encode({'pageSize': 30});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('body')) {
          final List<dynamic> playersData = data['body'];
          setState(() {
            _players = playersData.map((json) => PlayerModel.fromJson(json)).toList();
            _filteredPlayers = _players; // Set _filteredPlayers initially
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Players data not found in response';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error fetching players';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching players';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchPlayers(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _filteredPlayers = _players;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = 'https://basketball-head.p.rapidapi.com/players/search';
    final headers = {
      'content-type': 'application/json',
      'X-RapidAPI-Key': 'e49e0e0918msh9e647c44910248cp134cc0jsn5b7ed327e194',
      'X-RapidAPI-Host': 'basketball-head.p.rapidapi.com',
    };
    final body = json.encode({
      'pageSize': 100,
      'firstname': keyword.split(' ').first,
      'lastname': keyword.split(' ').length > 1 ? keyword.split(' ').last : '',
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('body')) {
          final List<dynamic> playersData = data['body'];
          setState(() {
            _filteredPlayers = playersData.map((json) => PlayerModel.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _filteredPlayers = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error searching for players: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error searching for players: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Red color without transparency
      appBar: AppBar(
        title: Text('NBA Players',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0), // Red color without transparency

      ),
      body: RefreshIndicator(
    onRefresh: fetchPlayers,
    child: Center(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),

                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search player...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      filled: true, // Add this to enable filling the field
                      fillColor: Colors.white, // Set the background color to white
                      hintStyle: TextStyle(color: Colors.black), // Set hint text color to black
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red), // Set focused border color to red
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Set border color to black
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onSubmitted: _searchPlayers,
                  )




                ),
              ),
            ),
            if (_isLoading)
              CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (!_isLoading && _errorMessage.isEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPlayers.length,
                  itemBuilder: (context, index) {
                    PlayerModel player = _filteredPlayers[index];
                    return _buildPlayerCard(player);
                  },
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerModel player) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: CircleAvatar(
      backgroundImage: player.headshotUrl.isNotEmpty
      ? NetworkImage(player.headshotUrl)
            : AssetImage('assets/images/logo.png') as ImageProvider,

    ),
        title: Text(
          '${player.firstName} ${player.lastName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.0),
            Text(player.positions.join(', ')),
            SizedBox(height: 4.0),
            Text('${player.teams.isNotEmpty ? player.teams.last : "N/A"}'),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerDetailsPage(player: player),
            ),
          );
        },
      ),
    );
  }
}


