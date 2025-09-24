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
                      lieu: lieu,
                      lieuId: lieu.id,
                      lieuData: lieu.toMap(),
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
                      lieu,
                      lieuId: lieu.id,
                      lieuNom: lieu.nom,
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

            const SizedBox(height: 40),

            //Le bouton API Service (externe)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BoutonApiService(lieu: lieu),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
