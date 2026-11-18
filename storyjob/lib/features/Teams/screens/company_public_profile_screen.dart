import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class CompanyPublicProfileScreen extends StatelessWidget {
  final String companyId;
  final String teamId; // Das konkrete anvisierte Team
  final String talentUid; // Die UID des angemeldeten Talents

  const CompanyPublicProfileScreen({
    Key? key,
    required this.companyId,
    required this.teamId,
    required this.talentUid,
  }) : super(key: key);

  Future<void> _sendAccessRequest(BuildContext context) async {
    try {
      // Zeige Lade-Indikator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );

      // Cloud Function 'requestAccess' aufrufen
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('requestAccess');
      
      await callable.call({
        'talentUid': talentUid,
        'companyId': companyId,
        'teamId': teamId,
      });

      // Lade-Dialog schließen
      Navigator.pop(context);

      // Erfolg melden
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Resonanz-Anfrage erfolgreich an das Alpha-Team gesendet!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Lade-Dialog schließen
      Navigator.pop(context);

      // Fehler abfangen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fehler: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // Edler Dark-Mode Hintergrund
      appBar: AppBar(
        title: const Text("Alpha-Tier Präsentation"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('company_public')
            .doc(companyId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Unternehmensprofil konnte nicht geladen werden.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Alpha Unternehmen';
          final tagline = data['tagline'] ?? '';
          final cultureValues = List<String>.from(data['cultureValues'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Alpha-Tier Branding Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.shield, size: 45, color: Colors.amber),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tagline,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 20),

                // 2. Kultur & Werte
                const Text(
                  "Kultur & Werte",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: cultureValues.map((value) {
                    return Chip(
                      label: Text(
                        value,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.amber.withOpacity(0.15),
                      side: BorderSide(color: Colors.amber.withOpacity(0.3)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // 3. Souveräner Call-to-Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sendAccessRequest(context),
                    icon: const Icon(Icons.bolt, color: Colors.black),
                    label: const Text(
                      "Resonanz anfragen",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}