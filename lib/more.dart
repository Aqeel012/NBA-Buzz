import 'package:flutter/material.dart';
import './more/contact.dart';

class MorePage extends StatelessWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Menu',style: TextStyle(color:Colors.white)),
        backgroundColor: Color.fromRGBO(227, 8, 8, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 20.0,
              runSpacing: 20.0,
              children: [
                roundedBox(
                  icon: Icons.contact_support,
                  text: 'Contact Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactPage(),
                      ),
                    );
                  },
                ),
                roundedBox(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () {
                    // Navigate to the Settings page
                  },
                ),
                // Add more boxes here
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget roundedBox({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 100.0, // Adjust width as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Color.fromRGBO(227, 8, 8, 1.0),),
          SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
