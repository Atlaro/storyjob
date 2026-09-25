import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/storyjob_theme.dart';
import '../../../core/services/app_services.dart';

class StoriesFeedScreen extends StatefulWidget {
  const StoriesFeedScreen({super.key});

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen> {
  String _selectedCategory = 'Alle';
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingId;
  bool _isPlaying = false;
  bool _isOffline = false;

  final List<String> _categories = ['Alle', 'PV/Technik', 'Ausbildung', 'BRK/Feuerwehr'];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() => _isOffline = true);
    }
  }

  Future<void> _toggleAudio(String id, String url) async {
    if (url.isEmpty) return;

    if (_currentlyPlayingId == id && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));

      AppServices.incrementPlays(id);

      setState(() {
        _currentlyPlayingId = id;
        _isPlaying = true;
      });
    }

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryJob Stories', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              color: Colors.orange.shade900.withValues(alpha: 0.8),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Offline-Modus aktiv',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                    },
                    selectedColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.3),
                    backgroundColor: StoryJobTheme.cardSurface,
                    labelStyle: TextStyle(
                      color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.cardBorder,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: AppServices.getStoryFeedStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Lade-Hinweis: Verbindung wird aufgebaut...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: StoryJobTheme.textSecondary, height: 1.5),
                      ),
                    ),
                  );
                }

                if (_isOffline) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Offline-Modus aktiv',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: StoryJobTheme.textSecondary, height: 1.5),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent));
                }

                final docs = snapshot.data?.docs ?? [];
                final filteredDocs = docs.where((doc) {
                  if (_selectedCategory == 'Alle') return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final category = data['category'] ?? 'Allgemein';
                  return category == _selectedCategory;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedCategory == 'Alle' 
                          ? 'Aktuell sind keine Stories vorhanden.' 
                          : 'Keine Stories in der Kategorie "$_selectedCategory" gefunden.', 
                      style: const TextStyle(color: StoryJobTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: filteredDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['category'] ?? 'Allgemein';
                    final userName = data['userName'] ?? 'Anonym';
                    
                    return Card(
                      color: StoryJobTheme.cardSurface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('Kategorie: $title', style: const TextStyle(color: StoryJobTheme.textSecondary)),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow_rounded, color: StoryJobTheme.cyanAccent),
                          onPressed: () => _toggleAudio(doc.id, data['audioUrl'] ?? ''),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}