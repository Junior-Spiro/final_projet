import 'package:final_projet/models/lieu.dart';
import 'package:final_projet/pages/ajout_lieu_page.dart';
import 'package:final_projet/pages/page_detail.dart';
import 'package:flutter/material.dart';

class PageMenuNav extends StatelessWidget {
  const PageMenuNav({super.key, required this.lieu});
  final Lieu lieu;

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.person_add, color: Colors.orangeAccent),
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
            leading: const Icon(Icons.list, color: Colors.orangeAccent),
            title: const Text('Informations des lieux'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PageDetail(lieu: lieu)),
              );
            },
          ),
        ],
      ),
    );
  }
}
