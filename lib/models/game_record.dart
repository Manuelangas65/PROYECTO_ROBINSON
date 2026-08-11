class GameRecord {
  final int? id;
  final int score;
  final int enemiesDestroyed;
  final int durationSeconds;
  final DateTime playedAt;
  final String contextMode;

  const GameRecord({
    this.id,
    required this.score,
    required this.enemiesDestroyed,
    required this.durationSeconds,
    required this.playedAt,
    required this.contextMode,
  });

  Map<String, Object?> toMap() {
    return {
      'score': score,
      'enemies_destroyed': enemiesDestroyed,
      'duration_seconds': durationSeconds,
      'played_at': playedAt.toIso8601String(),
      'context_mode': contextMode,
    };
  }

  factory GameRecord.fromMap(Map<String, Object?> map) {
    return GameRecord(
      id: map['id'] as int?,
      score: map['score'] as int,
      enemiesDestroyed: map['enemies_destroyed'] as int,
      durationSeconds: map['duration_seconds'] as int,
      playedAt: DateTime.parse(map['played_at'] as String),
      contextMode: map['context_mode'] as String,
    );
  }
}

class GameResult {
  final int score;
  final int enemiesDestroyed;
  final int durationSeconds;
  final String contextMode;

  const GameResult({
    required this.score,
    required this.enemiesDestroyed,
    required this.durationSeconds,
    required this.contextMode,
  });
}
