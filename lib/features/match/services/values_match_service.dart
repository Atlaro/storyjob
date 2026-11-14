import 'package:flutter/foundation.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';

class ValuesMatchResult {
  final double totalScore;
  final List<String> sharedValues;

  const ValuesMatchResult({
    required this.totalScore,
    required this.sharedValues,
  });
}

class ValuesMatchService {
  static ValuesMatchResult calculateMatch({
    required StoryIdentity sourceIdentity,
    required StoryIdentity targetIdentity,
  }) {
    final shared = sourceIdentity.findSharedValues(targetIdentity);
    final base = targetIdentity.values.isEmpty ? 0.72 : (0.65 + (shared.length * 0.12));
    return ValuesMatchResult(
      totalScore: base.clamp(0.55, 0.98),
      sharedValues: shared.isNotEmpty ? shared : const ['Teamgeist', 'Verlässlichkeit'],
    );
  }

  void logInteraction({
    required String eventType,
    required String targetId,
    Map<String, dynamic>? details,
  }) {
    debugPrint('ValuesMatch [$eventType] -> $targetId');
  }
}
