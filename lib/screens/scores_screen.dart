import 'package:flutter/material.dart';

import '../models/game_record.dart';
import '../services/database_service.dart';
import '../widgets/context_background.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  late Future<List<GameRecord>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _gamesFuture = DatabaseService.instance.getGames();
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntuaciones'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: ContextBackground(
        child: SafeArea(
          child: FutureBuilder<List<GameRecord>>(
            future: _gamesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se pudieron leer las puntuaciones:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final games = snapshot.data ?? const <GameRecord>[];

              if (games.isEmpty) {
                return const Center(
                  child: Text(
                    'Todavía no hay partidas guardadas.',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                itemCount: games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final game = games[index];
                  return Card(
                    color: Colors.black.withValues(alpha: 0.45),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('#${index + 1}'),
                      ),
                      title: Text(
                        '${game.score} puntos',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${game.enemiesDestroyed} enemigos • '
                        '${game.durationSeconds}s • '
                        '${game.contextMode == 'day' ? 'día' : 'noche'}\n'
                        '${_formatDate(game.playedAt)}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
