import 'dart:io';

import 'package:final_projet/services/auth_service.dart';
import 'package:final_projet/widget/image_prise_profil.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  User? user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  void _onPhotoSelectionne(File image) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await AuthService().ChangerPhotoProfil(image);
      if (!mounted) return;
      setState(() {
        user = FirebaseAuth.instance.currentUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo de profil mise à jour')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _ouvrirMenuPhotoProfil(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Voir la photo de profil'),
                onTap: () {
                  Navigator.pop(context);
                  _afficherImageProfil(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Modifier la photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => ImagePriseProfil(
        onPhotoSelectionne: (File image) {
          Navigator.of(context).pop();
          _onPhotoSelectionne(image);
        },
        imageUrl: user?.photoURL,
      ),
    );
  }

  void _afficherImageProfil(BuildContext context) {
    if (user?.photoURL == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pas de photo de profil disponible')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: InteractiveViewer(child: Image.network(user!.photoURL!)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        centerTitle: true,
        backgroundColor: Colors.brown[100],
        foregroundColor: Colors.teal,
      ),
      body: user == null
          ? const Center(
              child: Text('Profil inconnu, veuillez-vous inscrire. Merci'),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Row(
                  children: [
                    const SizedBox(width: 30),
                    GestureDetector(
                      onTap: () => _ouvrirMenuPhotoProfil(context),
                      child: Stack(
                        ///Le Stack dans l’UI permet d’empiler le
                        ///CircleAvatar et le loader, évitant une reconstruction complexe.
                        alignment: Alignment.center,
                        children: [
                          AnimatedSwitcher(
                            // pour une animation de fondu
                            duration: Duration(milliseconds: 700),
                            child: CircleAvatar(
                              //Le ValueKey change à chaque nouvelle photo, donc l’avatar est animé automatiquement.
                              key: ValueKey(user?.photoURL),
                              radius: 50,
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                              child: user?.photoURL == null
                                  ? Container(
                                      // cercle coloré avec la première lettre du nom
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.teal[100],
                                      ),
                                      child: Center(
                                        child: Text(
                                          user?.displayName
                                                  ?.substring(0, 1)
                                                  .toUpperCase() ??
                                              '',
                                          style: TextStyle(
                                            fontSize: 38,
                                            color: Colors.teal[800],
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (_isLoading)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Colors.black26,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Nom: ${user!.displayName ?? ''}",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Email: ${user!.email ?? ''}",
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
    );
  }
}
