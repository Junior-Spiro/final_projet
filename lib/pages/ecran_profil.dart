import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // récupère l'utilisateur connecté
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mon profil"),
        centerTitle: true,
        backgroundColor: Colors.brown[100],
        foregroundColor: Colors.teal,
      ),
      body: user == null
          ? const CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                Row(
                  //pour metre le width
                  children: [
                    SizedBox(width: 30),
                    Text(
                      "Nom: ${user!.displayName}",
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 30),
                    Text(
                      "Email: ${user!.email}",
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
