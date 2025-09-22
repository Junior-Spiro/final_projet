import 'package:final_projet/models/lieu.dart';
import 'package:final_projet/pages/supprimer_lieu_page.dart';
import 'package:final_projet/widget/bouton_api_service.dart';
import 'package:flutter/material.dart';
import 'modifier_lieu_page.dart';

class PageDetail extends StatelessWidget {
  final Lieu lieu;

  const PageDetail({super.key, required this.lieu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          'Informations sur ${lieu.nom}',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image en premier, pleine largeur, hauteur fixe
            if (lieu.photoUrl.isNotEmpty)
              Image.network(
                lieu.photoUrl,
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
            const SizedBox(height: 24),

            // Informations principales centrées et structurées
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    lieu.nom,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lieu.ville,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lieu.description,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bouton obtenir la météo de la ville saisie, en plein largeur, stylisé
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Action du bouton météo, à implémenter selon votre logique
                  // Par exemple, ouvrir une page météo avec lieu.ville
                },
                icon: const Icon(Icons.cloud, size: 24),
                label: const Text(
                  'Obtenir la météo de la ville',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Boutons Modifier & Supprimer alignés et centrés avec espaces
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                  tooltip: 'Modifier',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModifierLieuPage(
                          lieu: lieu,
                          lieuId: lieu.id,
                          lieuData: lieu.toMap(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 48),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                  tooltip: 'Supprimer',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupprimerLieuPage(
                          lieu,
                          lieuId: lieu.id,
                          lieuNom: lieu.nom,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Si vous souhaitez garder le bouton API Service (externe)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: BoutonApiService(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
