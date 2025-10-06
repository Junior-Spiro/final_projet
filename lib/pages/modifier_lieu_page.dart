import 'dart:io';
import 'package:final_projet/services/auth_service.dart';
import 'package:final_projet/services/firebase_service.dart';
import 'package:final_projet/widget/image_prise.dart';
import 'package:flutter/material.dart';
import 'package:final_projet/models/lieu.dart';

class ModifierLieuPage extends StatefulWidget {
  final Lieu lieu;
  const ModifierLieuPage({
    super.key,
    required this.lieu,
    required Map<String, dynamic> lieuData,
    required String lieuId,
  });

  @override
  State<ModifierLieuPage> createState() => _ModifierLieuPageState();
}

class _ModifierLieuPageState extends State<ModifierLieuPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _villeController;
  File? _nouvelleImage;
  String _photoActuelle = '';
  final styleBouton = ElevatedButton.styleFrom(
    backgroundColor: Colors.black87,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.bold),
  );

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.lieu.nom);
    _descriptionController = TextEditingController(
      text: widget.lieu.description,
    );
    _villeController = TextEditingController(text: widget.lieu.ville);
    _photoActuelle = widget.lieu.photoUrl;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  void _onPhotoSelectionne(File image) {
    setState(() {
      _nouvelleImage = image;
    });
  }

  Future<void> _modifierLieu() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        final user = AuthService().getCurrentUser();
        if (user == null) {
          _afficherErreurDialog('Utilisateur non connecté');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        await FirebaseService.modifierLieu(
          lieuId: widget.lieu.id,
          nom: _nomController.text.trim(),
          description: _descriptionController.text.trim(),
          ville: _villeController.text.trim(),
          anciennePhotoUrl: _photoActuelle,
          nouvelleImage: _nouvelleImage,
        );
        setState(() {
          _isLoading = false;
        });
        _afficherSuccesDialog();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _afficherErreurDialog(e.toString());
      }
    }
  }

  void _afficherSuccesDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Le lieu a été modifié avec succès.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le lieu'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ImagePrise(
                onPhotoSelectionne: _onPhotoSelectionne,
                imageUrl: _photoActuelle,
              ),
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
                onPressed: _isLoading ? null : _modifierLieu,
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
                    : const Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
