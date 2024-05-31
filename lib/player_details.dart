import 'package:flutter/material.dart';
import './models/player_model.dart';

class PlayerDetailsPage extends StatelessWidget {
  final PlayerModel player;

  const PlayerDetailsPage({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Details',style: TextStyle(color: Colors.white),),
        backgroundColor:Color.fromRGBO(227, 8, 8, 1.0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child:Image(
                    image:player.headshotUrl.isNotEmpty
                        ? NetworkImage(player.headshotUrl) as ImageProvider<Object>
                        : AssetImage('assets/images/logo.png') as ImageProvider<Object>,
              ),
            ),
            SizedBox(height: 25),
            Center(child:Text(
              '${player.firstName} ${player.lastName}',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),),
            SizedBox(height: 25),
            Divider(height: 5,color: Colors.grey,),
            SizedBox(height: 25),

            _buildDetailRow('HEIGHT', player.height, 'WEIGHT', player.weight),
            SizedBox(height: 20),
            _buildDetailRow('BIRTHDATE', player.dateBorn, 'BIRTHPLACE', player.birthPlace),
            SizedBox(height: 20),
            _buildDetailRow('DATE DIED', player.dateDied, 'POSITION', player.positions.join(', ')),
            SizedBox(height: 20),
            _buildDetailRow('NBA DEBUT', player.nbaDebut, 'DRAFT INFO', player.draftInfo),
            SizedBox(height: 20),
            _buildDetailRow('ACCOLADES', player.accolades.join(', '), 'TEAMS', player.teams.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('| $label1', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 15)),
              SizedBox(height: 5,),
              Text(' $value1',style: TextStyle(fontSize: 15),),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('| $label2', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 15)),
              SizedBox(height: 5,),
              Text(' $value2',style: TextStyle(fontSize: 15),),
            ],
          ),
        ),
      ],
    );
  }
}

