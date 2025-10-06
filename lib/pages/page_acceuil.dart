import 'package:final_projet/pages/ajout_lieu_page.dart';
import 'package:final_projet/pages/page_detail.dart';
import 'package:final_projet/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:final_projet/models/lieu.dart';
import 'ecran_profil.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key, required this.lieu});
  final Lieu? lieu;

  @override
  State<PageAccueil> createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0;

  setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    bool showAppBar;

    if (_currentIndex == 0) {
      // Page Acceuil : appBar visible
      showAppBar = true;
      currentBody = StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('lieux').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: 300,
              margin: const EdgeInsets.all(8),
              color: Colors.grey[300],
              child: Icon(Icons.broken_image_outlined),
            );
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
              return SizedBox(
                height: 250,
                child: Card(
                  margin: const EdgeInsets.only(
                    top: 15,
                    left: 5,
                    right: 5,
                    bottom: 8,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      // naviguer vers la page de détails en passant l'objet Lieu
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PageDetail(lieu: lieu),
                        ),
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
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.place,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 4),
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
                ),
              );
            }).toList(),
          );
        },
      );
    } else {
      // Page Profil
      showAppBar = false;
      currentBody = ProfilPage();
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              elevation: 20,
              title: const Text('Compagny Hubs'),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
            )
          : null,
      endDrawer: pageMenuNav(),
      body: currentBody, // Affiche la page selon l'index sélectionné

      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.teal,
        height: 60,
        animationCurve: Curves.bounceOut,
        animationDuration: Duration(milliseconds: 700),
        items: <Widget>[
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) => setCurrentIndex(index),
      ),

      /*
      BottomNavigationBar(
        currentIndex: _currentIndex,
        //permet de naviger vers la page appuyée
        onTap: (index) => setCurrentIndex(index),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.teal,
        selectedFontSize: 16,
        elevation: 15,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Acceuil'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),*/
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
