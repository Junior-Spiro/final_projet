import 'package:final_projet/models/lieu.dart';
import 'package:final_projet/pages/page_detail.dart';
import 'package:final_projet/services/auth_service.dart';
import 'package:final_projet/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PageHistorique extends StatefulWidget {
  const PageHistorique({super.key});

  @override
  State<PageHistorique> createState() => _PageHistoriqueState();
}

class _PageHistoriqueState extends State<PageHistorique> {
  GlobalKey _streamKey = GlobalKey();

  // Contrôleur pour le champ de texte de filtrage (permet de lire/effacer le texte)
  final TextEditingController _filtreVilleController = TextEditingController();
  // Variable pour stocker la valeur actuelle du filtre (null = pas de filtre)
  String? _filtreVille;

  // Méthode appelée quand le widget est détruit → libère les ressources
  @override
  void dispose() {
    _filtreVilleController.dispose();
    super.dispose();
  }

  String _formatError(Object? error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      if (error is FirebaseAuthException) {
        return "Problème d'authentification:${error.message}";
      } else if (error is FirebaseException) {
        return "Erreur Firebase: ${error.message}";
      } else {
        return error.toString();
      }
    } else {
      return "Une erreur inconnue est survenue";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupère l'utilisateur actuellement connecté via votre service d'authentification
    final user = AuthService().getCurrentUser();

    // Si aucun utilisateur n'est connecté → on affiche un message simple
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Historique des lieux'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
        ),
        body: const Center(child: Text('Utilisateur non connecté')),
      );
    }

    // Sinon, on construit la page normale
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des lieux'),
        backgroundColor: Colors.black12,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔍 Champ de recherche/filtrage en haut
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _filtreVilleController, // Lie le champ au contrôleur
              decoration: InputDecoration(
                hintText: 'Filtrer par ville', // Texte d'indice
                prefixIcon: Icon(Icons.search), // Icône à gauche
                suffixIcon: IconButton(
                  onPressed: () {
                    _filtreVilleController.clear(); // Efface le texte affiché
                    setState(() {
                      _filtreVille = null; //Supprime le filtre interne
                    });
                  },
                  icon: Icon(Icons.clear), // Croix à droite
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),

              // Appelé à chaque frappe de l'utilisateur
              onChanged: (value) {
                setState(() {
                  // Si le texte est vide → pas de filtre (null)
                  // Sinon → on garde la ville (sans espaces inutiles)
                  _filtreVille = value.trim().isEmpty ? null : value.trim();
                });
              },
            ),
          ),

          // 📜 Zone principale qui affichera soit le chargement, soit les données
          // Expanded permet à ce widget de prendre tout l'espace restant dans la colonne
          Expanded(
            child: RefreshIndicator(
              //Tiré vers le bas pour rafraichir la page
              onRefresh: () async {
                setState(() {
                  _streamKey = GlobalKey(); //Force le Rechargement aussi
                });
              },
              child: StreamBuilder<List<Lieu>>(
                key: _streamKey,
                // 🔁 Ce stream vient de Firebase et dépend de l'ID utilisateur + du filtre
                stream: FirebaseService.getHistoriqueLieux(
                  uid: user.id,
                  filtreVille: _filtreVille,
                ),
                builder: (context, snapshot) {
                  // 1- ❌ Erreur du stream
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Erreur: ${_formatError(snapshot.error)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 18),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _streamKey =
                                    GlobalKey(); // Force la recréation du StreamBuilder
                              });
                            },
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    );
                  }

                  //2- 🔄 État de chargement initial
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Chargement de votre historique...'),
                        ],
                      ),
                    );
                  }

                  //3- Données chargées avec succès mais vide
                  final lieux = snapshot.data ?? [];
                  if (lieux.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, color: Colors.grey, size: 48),
                          SizedBox(height: 16),
                          const Text('Aucun lieu dans votre historique.'),
                        ],
                      ),
                    );
                  }

                  //4- Affichage de données
                  return ListView.builder(
                    itemCount: lieux.length,
                    itemBuilder: (_, index) {
                      final lieu = lieux[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: lieu.photoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    lieu.photoUrl,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.place_outlined, size: 48),
                          title: Text(lieu.nom),
                          subtitle: Text(lieu.ville),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PageDetail(lieu: lieu),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
