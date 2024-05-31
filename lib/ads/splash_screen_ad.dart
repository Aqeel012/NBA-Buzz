import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../main.dart'; // Import main.dart to access MyApp

class SplashScreenAd extends StatefulWidget {
  @override
  _SplashScreenAdState createState() => _SplashScreenAdState();
}

class _SplashScreenAdState extends State<SplashScreenAd> {
  late InterstitialAd _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _navigateToHome();
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Replace with your ad unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 4), () {
      if (_isAdLoaded) {
        _interstitialAd.show();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(227, 8, 8, 1.0),),
        ),
      ),
    );
  }
}
