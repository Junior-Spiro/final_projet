import 'dart:convert';

import 'package:final_projet/widget/donnees_meteo_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_projet/models/lieu.dart';

//C'est une classe  qui représente l’interface utilisateur principale de l’application

class BoutonApiService extends StatefulWidget {
  final Lieu lieu;
  const BoutonApiService({super.key, required this.lieu});

  @override
  State<BoutonApiService> createState() => _BoutonApiServiceState();
}

class _BoutonApiServiceState extends State<BoutonApiService> {
  bool _isLoading = false;
  String? _erreur;
  Map<String, dynamic>? _donneesMeteo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _recupererDonnees,
            icon: Icon(Icons.cloud_done, color: Colors.black87),
            label: Text(
              'Obtenir la météo',
              style: TextStyle(color: Colors.black),
            ),
            style: ButtonStyle(
              elevation: WidgetStatePropertyAll(6),
              backgroundColor: WidgetStatePropertyAll(Colors.green[300]),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading) CircularProgressIndicator(color: Colors.green[200]),
          if (_donneesMeteo != null && !_isLoading)
            DonneesMeteoWidget(donneesMeteo: _donneesMeteo!),
        ],
      ),
    );
  }

  Future<void> _recupererDonnees() async {
    final ville = widget.lieu.ville; // récupérer la ville depuis widget.lieu
    setState(() {
      _isLoading = true;
    });

    final apiKey = '9deb66119073a772bf1514053e92e2f0';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$ville&lang=fr&units=metric&appid=$apiKey',
    );

    try {
      final reponse = await http.get(url); // Envoi de la requête HTTP à l'API
      if (reponse.statusCode == 200) {
        setState(() {
          _donneesMeteo = json.decode(reponse.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _erreur = "Ville introuvable ou erreur du serveur.";
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _erreur = "Impossible de récupérer les données.";
        _isLoading =
            false; // En cas d'erreur, l'indicateur de chargement est mis à false
      });
    }
  }
}
