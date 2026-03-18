import 'package:flutter/material.dart';

class DeveloperInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desarrollador'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/johnj.jpg'),
              // o usar un icono: child: Icon(Icons.person, size: 60),
            ),
            SizedBox(height: 20),
            Text(
              'John Jáner Martelo Guzmán',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Ing. Informático - Desarrollador',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            InfoCard(
              icon: Icons.email,
              text: 'info@jmartech.top',
            ), // Fin InfoCard
            /* InfoCard(
              icon: Icons.phone,
              text: '+1234567890',
            ), */
            /* InfoCard(
              icon: Icons.link,
              text: 'github.com/tuusuario',
            ), */
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(text),
      ),
    );
  }
}