import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/collection.dart';
import '../../models/flashcard.dart';
import '../../models/study_progress.dart';
import '../../providers/auth_provider.dart';
import '../../services/collection_service.dart';
import '../../services/study_service.dart';

class MatchingScreen extends StatefulWidget {
  final int collectionId;

  const MatchingScreen({super.key, required this.collectionId});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final CollectionService _collectionService = CollectionService();
  final StudyService _studyService = StudyService();

  Collection? collection;
  List<Flashcard> flashcards = [];
  List<String> shuffledAnswers = [];
  Map<int, String> selectedMatches = {};
  StudyProgress? progress;
  int? sessionId;
  bool isLoading = true;
  String? error;
  bool showCompleteModal = false;
  int responseStart = DateTime.now().millisecondsSinceEpoch;
  List<Map<String, dynamic>>? matchResults;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) throw Exception('Không tìm thấy token');

      collection = await _collectionService.fetchCollectionById(widget.collectionId, token);
      final sessionData = await _studyService.startSession(
          widget.collectionId, 'game_match', token
      );

      sessionId = sessionData['sessionId'];
      flashcards = sessionData['flashcards'] as List<Flashcard>;
      progress = sessionData['progress'];

      final allOptions = flashcards
          .where((f) => f.matchingOptions != null && f.matchingOptions!.correctAnswer.isNotEmpty)
          .map((f) => f.matchingOptions!.correctAnswer)
          .toSet()
          .toList();

      allOptions.shuffle(Random());
      setState(() {
        shuffledAnswers = allOptions;
      });
    } catch (e) {
      setState(() => error = 'Lỗi khi tải dữ liệu: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleMatch(int flashcardId, String answer) {
    setState(() {
      selectedMatches[flashcardId] = answer;
    });
  }

  Future<void> _submitMatch() async {
    if (sessionId == null) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    final responseTime = DateTime.now().millisecondsSinceEpoch - responseStart;

    final matchedPairs = selectedMatches.entries
        .map((e) => {
      'flashcard_id': e.key,
      'selected_answer': e.value,
    })
        .toList();

    try {
      final result = await _studyService.submitMatching(
        sessionId: sessionId!,
        matchedPairs: matchedPairs,
        responseTimeMs: responseTime,
        token: token,
      );

      setState(() {
        matchResults = List<Map<String, dynamic>>.from(result['results'] ?? []);
        progress = result['progress'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text(error!)));
    if (collection == null) return const Scaffold(body: Center(child: Text('Không có dữ liệu bộ sưu tập')));

    if (matchResults != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Kết quả ghép:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: matchResults!.map((r) {
                    final card = flashcards.firstWhere((c) => c.id == r['flashcard_id']);
                    return ListTile(
                      title: Text(card.front),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đáp án đúng: ${r['correct_answer']}'),
                          Text('Bạn chọn: ${r['selected_answer']}'),
                          Text(
                            r['is_correct'] ? '✅ Đúng' : '❌ Sai',
                            style: TextStyle(
                              color: r['is_correct'] ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    matchResults = null;
                    showCompleteModal = true;
                  });
                },
                child: const Text('Tiếp tục'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(collection!.name)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Nối cặp chính xác giữa mặt trước và nghĩa:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView(
                          children: flashcards.map((card) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: ListTile(
                                title: Text(card.front, style: const TextStyle(fontSize: 18)),
                                subtitle: selectedMatches[card.id] != null
                                    ? Text('➡ ${selectedMatches[card.id]}')
                                    : const Text('Chưa chọn'),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const VerticalDivider(width: 20),
                      Expanded(
                        child: ListView(
                          children: shuffledAnswers.map((answer) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: ListTile(
                                title: Text(answer),
                                onTap: () {
                                  final unselectedCard = flashcards.firstWhere(
                                        (card) => !selectedMatches.containsKey(card.id),
                                    orElse: () => flashcards.first,
                                  );
                                  _handleMatch(unselectedCard.id, answer);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: selectedMatches.length < flashcards.length ? null : _submitMatch,
                  child: const Text('Hoàn thành'),
                ),
              ],
            ),
          ),
          if (showCompleteModal)
            Container(
              color: Colors.black54,
              child: Center(
                child: AlertDialog(
                  title: const Text('Hoàn thành'),
                  content: const Text('Bạn đã hoàn thành phần ghép từ!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.go('/home');
                      },
                      child: const Text('Về trang chủ'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedMatches.clear();
                          showCompleteModal = false;
                          _loadData();
                        });
                      },
                      child: const Text('Làm lại'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
