import 'dart:io';
import 'package:final_projet/services/auth_service.dart';
import 'package:final_projet/widget/image_prise.dart';
import 'package:flutter/material.dart';
import 'package:final_projet/services/firebase_service.dart';

class AjoutLieuPage extends StatefulWidget {
  const AjoutLieuPage({super.key});

  @override
  State<AjoutLieuPage> createState() => _AjoutLieuPageState();
}

class _AjoutLieuPageState extends State<AjoutLieuPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _villeController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false; // <--- Etat chargement ajouté

  final styleBouton = ElevatedButton.styleFrom(
    backgroundColor: Colors.black87,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  void _onPhotoSelectionne(File image) {
    setState(() => _pickedImage = image);
  }

  void _afficherErreurDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _afficherSuccesDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Le lieu a été ajouté avec succès.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _ajouterLieu() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedImage == null) {
        _afficherErreurDialog('Veuillez sélectionner une photo.');
        return;
      }
      try {
        setState(() {
          _isLoading = true; // démarre chargement
        });

        final user = AuthService().getCurrentUser();
        if (user == null) {
          _afficherErreurDialog('Utilisateur non connecté');
          setState(() {
            _isLoading = false; // reset chargement
          });
          return;
        }

        await FirebaseService.ajouterLieu(
          uid: user.id,
          nom: _nomController.text.trim(),
          description: _descriptionController.text.trim(),
          ville: _villeController.text.trim(),
          image: _pickedImage!,
        );

        setState(() {
          _isLoading = false; // fin chargement
        });

        _afficherSuccesDialog();
      } catch (e) {
        setState(() {
          _isLoading = false; // fin chargement sur erreur
        });
        _afficherErreurDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un lieu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.tealAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ImagePrise(onPhotoSelectionne: _onPhotoSelectionne),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du lieu'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Veuillez entrer un nom'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Veuillez entrer une description'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _villeController,
                decoration: const InputDecoration(labelText: 'Ville'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Veuillez entrer une ville'
                    : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: styleBouton,
                onPressed: _isLoading ? null : _ajouterLieu,
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          backgroundColor: Colors.black54,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
