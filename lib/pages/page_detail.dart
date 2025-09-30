import 'dart:convert';

import 'package:final_projet/models/lieu.dart';
import 'package:final_projet/pages/supprimer_lieu_page.dart';
import 'package:final_projet/widget/donnees_meteo_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'modifier_lieu_page.dart';

class PageDetail extends StatefulWidget {
  final Lieu lieu;

  const PageDetail({super.key, required this.lieu});

  @override
  State<PageDetail> createState() => _PageDetailState();
}

class _PageDetailState extends State<PageDetail> {
  bool _isLoading = false;
  String? _erreur;
  Map<String, dynamic>? _donneesMeteo;

  @override
  void initState() {
    super.initState();
    _recupererDonnees(); // lancement automatique
  }

  Future<void> _recupererDonnees() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final ville = widget.lieu.ville; // récupérer la ville depuis widget.lieu

    final apiKey = '9deb66119073a772bf1514053e92e2f0';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$ville&lang=fr&units=metric&appid=$apiKey',
    );

    try {
      final reponse = await http.get(url); // Envoi de la requête HTTP à l'API
      if (reponse.statusCode == 200) {
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _erreur = "Impossible de récupérer les données.";
        _isLoading =
            false; // En cas d'erreur, l'indicateur de chargement est mis à false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.teal,
        title: Text(
          'Informations sur ${widget.lieu.nom}',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_document, color: Colors.black87),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifierLieuPage(
                      lieu: widget.lieu,
                      lieuId: widget.lieu.id,
                      lieuData: widget.lieu.toMap(),
                    ),
                  ),
                );
              },
              title: Text(
                'Modifier',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupprimerLieuPage(
                      widget.lieu,
                      lieuId: widget.lieu.id,
                      lieuNom: widget.lieu.nom,
                    ),
                  ),
                );
              },
              title: Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image en premier, pleine largeur, hauteur fixe
            if (widget.lieu.photoUrl.isNotEmpty)
              Image.network(
                widget.lieu.photoUrl,
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 400,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              )
            else
              Container(
                height: 400,
                color: Colors.grey[300],
                child: const Icon(Icons.place, size: 100, color: Colors.grey),
              ),
            const SizedBox(height: 15),

            // Informations principales centrées et structurées
            Card(
              margin: EdgeInsets.all(16),
              color: Colors.green.shade50,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.lieu.nom,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.lieu.ville,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.lieu.description,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            //Le bouton API Service (externe)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.green[400])
                  : _donneesMeteo != null
                  ? DonneesMeteoWidget(donneesMeteo: _donneesMeteo!)
                  : _erreur != null
                  ? Text(
                      _erreur!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
