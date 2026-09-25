import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String uid;
  final String displayName;
  final String role;
  final String location;
  final List<String> interests;
  final double matchScore;

  MatchModel({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.location,
    required this.interests,
    required this.matchScore,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;

    return MatchModel(
      uid: data['uid'] ?? doc.id,
      displayName: data['displayName'] ?? 'Unbekannt',
      role: data['role'] ?? 'Talent',
      location: data['location'] ?? 'Pocking',
      interests: List<String>.from(
        data['interests'] ?? [],
      ),
      matchScore:
          (data['matchScore'] ?? 85.0).toDouble(),
    );
  }
}