import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:MemoTakara/models/study_progress.dart';
import 'package:MemoTakara/services/collection_service.dart';
import 'package:MemoTakara/services/study_service.dart';

import '../../models/collection.dart';
import '../../models/flashcard.dart';
import '../../providers/auth_provider.dart';

class TypingScreen extends StatefulWidget {
  final int collectionId;

  const TypingScreen({super.key, required this.collectionId});

  @override
  State<TypingScreen> createState() => _TypingScreenState();
}

class _TypingScreenState extends State<TypingScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionService _collectionService = CollectionService();
  final StudyService _studyService = StudyService();

  Collection? collection;
  List<Flashcard> flashcards = [];
  StudyProgress? progress;
  int? sessionId;
  bool isLoading = true;
  String? error;
  bool showCompleteModal = false;
  int currentCardIndex = 0;
  String userAnswer = '';
  bool showAnswer = false;
  bool isCorrect = false;
  String? correctAnswer;
  double? similarity;
  int responseStart = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) throw Exception('Không tìm thấy token xác thực');

      collection = await _collectionService.fetchCollectionById(widget.collectionId, token);
      final sessionData = await _studyService.startSession(
          widget.collectionId, 'typing', token
      );

      setState(() {
        sessionId = sessionData['sessionId'];
        flashcards = sessionData['flashcards'];
        progress = sessionData['progress'];
      });
    } catch (e) {
      setState(() => error = 'Lỗi khi tải dữ liệu: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitTyping(int quality) async {
    if (sessionId == null || flashcards.isEmpty) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    final flashcard = flashcards[currentCardIndex];
    final responseTime = DateTime.now().millisecondsSinceEpoch - responseStart;

    try {
      final result = await _studyService.submitTyping(
        sessionId: sessionId!,
        flashcardId: flashcard.id,
        quality: quality,
        userAnswer: userAnswer.trim(),
        responseTimeMs: responseTime,
        token: token,
      );

      setState(() {
        isCorrect = result['is_correct'] ?? false;
        correctAnswer = result['correct_answer'];
        similarity = (result['similarity'] as num?)?.toDouble();
        progress = result['progress'] ?? progress;
      });

      if (quality == 0) {
        setState(() => showAnswer = true);
      } else {
        if (currentCardIndex < flashcards.length - 1) {
          setState(() {
            currentCardIndex++;
            showAnswer = false;
            userAnswer = '';
            _controller.clear();
            responseStart = DateTime.now().millisecondsSinceEpoch;
          });
        } else {
          setState(() => showCompleteModal = true);
        }
      }
    } catch (e) {
      debugPrint('$e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'))
      );
    }
  }

  Future<void> _retrySession() async {
    setState(() => showCompleteModal = false);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(body: Center(child: Text(error!)));
    }
    if (collection == null) {
      return const Scaffold(
          body: Center(child: Text('Không có dữ liệu bộ sưu tập'))
      );
    }

    final flashcard = flashcards[currentCardIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(collection!.name, style: const TextStyle(fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (sessionId != null) {
              try {
                final token = Provider.of<AuthProvider>(context, listen: false).token;
                if (token != null) {
                  await _studyService.endSession(sessionId!, token);
                }
              } catch (e) {
                debugPrint('Error ending session: $e');
              }
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(flashcard.front, style: const TextStyle(fontSize: 24)),

                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nhập câu trả lời',
                  ),
                  onChanged: (val) => setState(() => userAnswer = val),
                  onSubmitted: (_) => _submitTyping(0),
                ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: userAnswer.trim().isEmpty ? null : () => _submitTyping(0),
                  child: const Text('Gửi câu trả lời'),
                ),

                if (showAnswer) ...[
                  const SizedBox(height: 16),
                  Text(
                    (similarity == 100.0 || isCorrect) ? 'Chính xác!' : 'Sai rồi!',
                    style: TextStyle(
                      color: (similarity == 100.0 || isCorrect) ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Câu trả lời đúng: ${correctAnswer ?? flashcard.back}'),
                  if (similarity != null) Text('Phần trăm chính xác: ${similarity!.toStringAsFixed(1)}%'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _submitTyping(0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Khó nhớ'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _submitTyping(2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Khó'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _submitTyping(4),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Bình thường'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _submitTyping(5),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Dễ'),
                        ),
                      ),
                    ],
                  ),
                ],

                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB4F6B3),
                        border: Border.all(color: const Color(0xFF519C4F), width: 3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('Mới: ${progress?.newCards ?? 0}'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFACA6F1),
                        border: Border.all(color: const Color(0xFF7B6FFE), width: 3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('Đang học: ${progress?.learning ?? 0}'),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8B2B2),
                        border: Border.all(color: const Color(0xFFDB5151), width: 3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text('Đến hạn: ${progress?.due ?? 0}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showCompleteModal)
            Container(
              color: Colors.black54,
              child: Center(
                child: AlertDialog(
                  title: const Text('Hoàn thành phiên học'),
                  content: const Text('Bạn đã hoàn thành tất cả thẻ trong phiên này!'),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => showCompleteModal = false),
                      child: const Text('Đóng'),
                    ),
                    TextButton(
                      onPressed: _retrySession,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
