import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../standings.dart';
import '../matches.dart';
import '../more.dart';
import '../players.dart';
import '../teams.dart';

class CustomLayout {
  static Widget buildBottomAppBar(String selectedItem, Function(int) onItemTapped) {
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      child: BottomAppBar(
        color: Colors.white,
        height: 100,
        child:
           Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildIconColumn(selectedItem, Icons.sports_basketball, Color.fromRGBO(227, 8, 8, 1.0), 'Matches', MatchesPage(), onItemTapped, 0),
            buildIconColumn(selectedItem, Icons.leaderboard, Color.fromRGBO(227, 8, 8, 1.0) , 'Standings', NbaStandings(), onItemTapped, 1),
            buildIconColumn(selectedItem, SvgPicture.asset('assets/images/teamsIconRed.svg'), Color.fromRGBO(227, 8, 8, 1.0),'Teams', TeamsPage(), onItemTapped, 2),
            buildIconColumn(selectedItem, Icons.group,Color.fromRGBO(227, 8, 8, 1.0), 'Players', PlayersPage(), onItemTapped, 3),
            buildIconColumn(selectedItem, Icons.menu_rounded, Color.fromRGBO(227, 8, 8, 1.0), 'More', MorePage(), onItemTapped, 4),
          ],
        ),
      ),
    );
  }

  static Widget buildIconColumn(String selectedItem, dynamic icon, Color iconColor, String text, Widget page, Function(int) onItemTapped, int index) {
    return Column(
      children: [
        icon is IconData
            ? IconButton(
            onPressed: () {
              onItemTapped(index);
          },
            icon: Icon(icon, color: selectedItem == index.toString() ? Colors.red : Colors.black),
        )
            : IconButton(
            onPressed: () {
              onItemTapped(index);
          },
             icon: SvgPicture.asset('assets/images/teamsIcon.svg', color: selectedItem == index.toString() ? Colors.red : Colors.black),
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12.0, color: selectedItem == index.toString() ? Colors.red : Colors.black),
        ),
      ],
    );
  }
}
