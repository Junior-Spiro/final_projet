import 'package:final_projet/pages/ajout_lieu_page.dart';
import 'package:final_projet/pages/page_detail.dart';
import 'package:final_projet/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:final_projet/models/lieu.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key, required this.lieu});
  final Lieu? lieu;

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compagny Hubs'),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      endDrawer: pageMenuNav(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('lieux').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lieuxDocs = snapshot.data!.docs;
          final lieux = lieuxDocs
              .map(
                (doc) =>
                    Lieu.fromMap(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList();
          if (lieux.isEmpty) {
            return const Center(child: Text('Aucun lieu trouvé.'));
          }

          return ResponsiveGridList(
            desiredItemWidth: 200,
            minSpacing: 10,
            children: lieux.map((lieu) {
              return Card(
                margin: const EdgeInsets.only(
                  top: 15,
                  left: 5,
                  right: 5,
                  bottom: 15,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    // naviguer vers la page de détails en passant l'objet Lieu
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PageDetail(lieu: lieu)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lieu.photoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              lieu.photoUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.place,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          lieu.nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          lieu.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  pageMenuNav() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Pas de padding
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black87),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.place_outlined, color: Colors.brown),
            title: const Text('Ajouter un lieu'),
            onTap: () {
              Navigator.pop(context); // Ferme le drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AjoutLieuPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: Colors.red),
            title: const Text('Déconnexion'),
            onTap: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
    );
  }
}
