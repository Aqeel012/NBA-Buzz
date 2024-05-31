import 'package:flutter/material.dart';
import 'layout/custom_bottom_app_bar.dart';
import './standings.dart';
import './matches.dart';
import './more.dart';
import './players.dart';
import './teams.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import './ads/banner_ad.dart';
import './ads/splash_screen_ad.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(SplashScreenApp());
}

class SplashScreenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenAd(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            MatchesPage(),
            NbaStandings(),
            TeamsPage(),
            PlayersPage(),
            MorePage(),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white38,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdBanner(), // Place the ad banner above the bottom app bar
            CustomLayout.buildBottomAppBar(
              _selectedIndex.toString(),
                  (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ],
        ),
    ),
      ),
    );
  }
}
