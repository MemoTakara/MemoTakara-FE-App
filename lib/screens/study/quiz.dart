import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/collection.dart';
import '../../models/flashcard.dart';
import '../../providers/auth_provider.dart';
import '../../services/collection_service.dart';
import '../../services/study_service.dart';

class QuizScreen extends StatefulWidget {
  final int collectionId;

  const QuizScreen({super.key, required this.collectionId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CollectionService _collectionService = CollectionService();
  final StudyService _studyService = StudyService();

  Collection? collection;
  List<Flashcard> flashcards = [];
  int? sessionId;
  int currentIndex = 0;
  int? selectedOption;
  bool isLoading = true;
  String? error;
  bool showCompleteModal = false;
  bool submitting = false;

  Map<String, dynamic>? currentResult;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) throw Exception("Missing token");

      collection = await _collectionService.fetchCollectionById(widget.collectionId, token);

      final sessionData = await _studyService.startSession(
          widget.collectionId, 'test', token
      );
      sessionId = sessionData['sessionId'];

      final List<Flashcard> rawCards = sessionData['flashcards'];
      flashcards = rawCards
          .map((card) => Flashcard.fromJson(card.toJson())) // ép kiểu ngược lại
          .where((card) => card.testOptions != null && card.testOptions!.options.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('$e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitAnswer() async {
    if (selectedOption == null || sessionId == null) return;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    setState(() => submitting = true);
    try {
      final result = await _studyService.submitQuiz(
        sessionId: sessionId!,
        answers: [
          {
            'flashcard_id': flashcards[currentIndex].id,
            'selected_option': selectedOption!,
          }
        ],
        token: token,
      );
      setState(() {
        currentResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi gửi đáp án: $e')));
    } finally {
      setState(() => submitting = false);
    }
  }

  void _nextQuestion() {
    if (currentIndex + 1 >= flashcards.length) {
      setState(() => showCompleteModal = true);
    } else {
      setState(() {
        currentIndex++;
        selectedOption = null;
        currentResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }

    if (flashcards.isEmpty) {
      return const Scaffold(body: Center(child: Text('Không có thẻ nào để kiểm tra.')));
    }

    final currentCard = flashcards[currentIndex];
    final options = currentCard.testOptions?.options ?? [];
    final correctIndex = currentCard.testOptions?.correctIndex ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(collection?.name ?? '')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu hỏi ${currentIndex + 1} / ${flashcards.length}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text(currentCard.front, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...options.asMap().entries.map((entry) {
              final i = entry.key;
              final option = entry.value.toString();
              final isSelected = selectedOption == i;
              final isCorrect = currentResult != null && correctIndex == i;
              final isWrong = currentResult != null && selectedOption == i && !isCorrect;

              Color color = Colors.grey.shade200;
              if (isCorrect) color = Colors.green.shade200;
              if (isWrong) color = Colors.red.shade200;

              return GestureDetector(
                onTap: currentResult == null ? () => setState(() => selectedOption = i) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green
                          : isWrong
                          ? Colors.red
                          : isSelected
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (currentIndex + 1 < flashcards.length) {
                  _nextQuestion();
                } else {
                  context.go('/collection-detail/${widget.collectionId}');
                }
              },
              child: Text(currentIndex + 1 < flashcards.length ? 'Câu tiếp theo' : 'Kết thúc'),
            ),
          ],
        ),
      ),
    );
  }
}
