class JobPitch {
  final String id;
  final String title;
  final String author;
  final String category;
  final String transcript;
  final String duration;
  final String timeAgo;
  final String? audioPath;

  JobPitch({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.transcript,
    required this.duration,
    required this.timeAgo,
    this.audioPath,
  });
}