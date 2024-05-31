import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Contact Us',style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContactInfo(
              icon: Icons.email,
              text: 'aqeelahmadradhani@gmail.com',
              onTap: () {
                _launchEmail('aqeelahmadradhani@gmail.com');
              },
            ),
            SizedBox(height: 20),
            ContactInfo(
              icon: Icons.phone,
              text: '+923436659342',
              onTap: () {
                _launchWhatsApp('+923436659342');
              },
            ),
            SizedBox(height: 20),
            ContactInfo(
              icon: Icons.facebook,
              text: 'Aqeel Ahmad',
              onTap: () {
                _launchURL('https://www.facebook.com/aqeel.ahmad.104418?mibextid=ZbWKwL');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String emailAddress) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );
    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'Could not launch $emailAddress';
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri _whatsappLaunchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '/$phoneNumber',
    );
    if (await canLaunch(_whatsappLaunchUri.toString())) {
      await launch(_whatsappLaunchUri.toString());
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ContactInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ContactInfo({
    required this.icon,
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Wrap(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
