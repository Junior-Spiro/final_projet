import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_projet/models/lieu.dart';
import 'package:flutter/material.dart';

class SupprimerLieuPage extends StatefulWidget {
  final String lieuId;
  final String lieuNom;

  const SupprimerLieuPage(
    Lieu lieu, {
    super.key,
    required this.lieuId,
    required this.lieuNom,
  });

  @override
  State<SupprimerLieuPage> createState() => _SupprimerLieuPageState();
}

class _SupprimerLieuPageState extends State<SupprimerLieuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _supprimer(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _firestore.collection('lieux').doc(widget.lieuId).delete();
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Succès'),
          content: Text('Lieu "${widget.lieuNom}" supprimé avec succès.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // fermer dialog
                Navigator.of(context).pop(); // revenir page liste
              },
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // masque l'indicateur en cas d'erreur
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleBoutonSupprimer = ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer lieu'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Voulez-vous vraiment supprimer le lieu "${widget.lieuNom}" ?',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: styleBoutonSupprimer,
                    onPressed: () => _supprimer(context),
                    child: const Text(
                      'Supprimer le lieu',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
