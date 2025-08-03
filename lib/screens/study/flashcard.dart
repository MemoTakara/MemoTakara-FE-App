import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:MemoTakara/models/study_progress.dart';
import 'package:MemoTakara/services/collection_service.dart';
import 'package:MemoTakara/services/study_service.dart';

import '../../models/collection.dart';
import '../../models/flashcard.dart';
import '../../providers/auth_provider.dart';

class FlashcardScreen extends StatefulWidget {
  final int collectionId;

  const FlashcardScreen({super.key, required this.collectionId});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
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
  bool showBack = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      debugPrint('Token: $token');

      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      // Step 1: Load collection
      debugPrint('Loading collection with ID: ${widget.collectionId}');
      collection = await _collectionService.fetchCollectionById(widget.collectionId, token);
      debugPrint('Collection loaded: ${collection?.name}, Flashcards count: ${collection?.flashcards.length}');

      // Step 2: Start study session
      debugPrint('Starting study session for collection ID: ${widget.collectionId}');
      final sessionData = await _studyService.startSession(
          widget.collectionId, 'flashcard', token
      );
      debugPrint('Study session started successfully');

      setState(() {
        sessionId = sessionData['sessionId'];
        flashcards = sessionData['flashcards'];
        progress = sessionData['progress'];
      });

      debugPrint('Session ID: $sessionId');
      debugPrint('Flashcards from session: ${flashcards.length}');
      debugPrint('Progress: ${progress?.toJson()}');

    } catch (e, stackTrace) {
      debugPrint('Error in _loadData: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorMessage = 'Lỗi khi tải dữ liệu: $e';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc thử lại sau.';
      } else if (e.toString().contains('is not a subtype of type \'String\'')) {
        errorMessage = 'Dữ liệu từ máy chủ không đúng định dạng. Vui lòng thử lại.';
      }
      setState(() {
        error = errorMessage;
      });
      // Hiển thị SnackBar sau khi build context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitFlashcard(int quality) async {
    if (sessionId == null) return;

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      debugPrint('Token: $token');

      if (token == null) {
        debugPrint('Token not found');
        throw Exception('Không tìm thấy token xác thực');
      }

      // Sửa lỗi: gửi ID thật của flashcard thay vì index
      final flashcard = flashcards[currentCardIndex];
      final result = await _studyService.submitFlashcard(
        sessionId: sessionId!,
        flashcardId: flashcard.id, // Sử dụng flashcard.id thay vì currentCardIndex
        quality: quality,
        token: token,
      );

      setState(() {
        progress = result['progress'];
        if (currentCardIndex < flashcards.length - 1) {
          currentCardIndex++;
          showBack = false;
        } else {
          showCompleteModal = true;
        }
      });
    } catch (e) {
      String errorMessage = 'Lỗi khi gửi câu trả lời: $e';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc thử lại sau.';
      } else if (e.toString().contains('is not a subtype of type \'String\'')) {
        errorMessage = 'Dữ liệu từ máy chủ không đúng định dạng. Vui lòng thử lại.';
      }
      setState(() {
        error = errorMessage;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      });
    }
  }

  Future<void> _endSession() async {
    setState(() {
      showCompleteModal = false;
      isLoading = true;
    });
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }
      if (sessionId != null) {
        await _studyService.endSession(sessionId!, token);
      }

      final sessionData = await _studyService.startSession(
          widget.collectionId, 'flashcard', token
      );
      setState(() {
        sessionId = sessionData['sessionId'];
        flashcards = sessionData['flashcards'];
        progress = sessionData['progress'];
        currentCardIndex = 0;
        isLoading = false;
      });
    } catch (e) {
      String errorMessage = 'Lỗi khi thử lại phiên học: $e';
      if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc thử lại sau.';
      } else if (e.toString().contains('is not a subtype of type \'String\'')) {
        errorMessage = 'Dữ liệu từ máy chủ không đúng định dạng. Vui lòng thử lại.';
      }
      setState(() {
        error = errorMessage;
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
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
    if (collection == null) {
      return const Scaffold(
          body: Center(child: Text('Không có dữ liệu bộ sưu tập'))
      );
    }

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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => setState(() => showBack = !showBack),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.lightBlue[50],
                            ),
                            child: Center(
                              child: Text(
                                showBack
                                    ? flashcards[currentCardIndex].back
                                    : flashcards[currentCardIndex].front,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.volume_up,
                              color: const Color(0xff166dba),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => _submitFlashcard(0),
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
                        onPressed: () => _submitFlashcard(2),
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
                        onPressed: () => _submitFlashcard(4),
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
                        onPressed: () => _submitFlashcard(5),
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

                const SizedBox(height: 16),
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
                // Wrap(
                //   alignment: WrapAlignment.center,
                //   spacing: 5.0,
                //   children: [
                //     Flexible(
                //       child: ElevatedButton(
                //         onPressed: () {},
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: const Color(0xFFB4F6B3),
                //           foregroundColor: Colors.black,
                //           side: const BorderSide(color: Color(0xFF519C4F), width: 3),
                //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           minimumSize: Size.zero,
                //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //         ),
                //         child: Text('${progress?.newCards ?? 0}'),
                //       ),
                //     ),
                //     Flexible(
                //       child: ElevatedButton(
                //         onPressed: () {},
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: const Color(0xFFACA6F1),
                //           foregroundColor: Colors.black,
                //           side: const BorderSide(color: Color(0xFF7B6FFE), width: 3),
                //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           minimumSize: Size.zero,
                //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //         ),
                //         child: Text('${progress?.learning ?? 0}'),
                //       ),
                //     ),
                //     Flexible(
                //       child: ElevatedButton(
                //         onPressed: () {},
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: const Color(0xFFE8B2B2),
                //           foregroundColor: Colors.black,
                //           side: const BorderSide(color: Color(0xFFDB5151), width: 3),
                //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           minimumSize: Size.zero,
                //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //         ),
                //         child: Text('${progress?.due ?? 0}'),
                //       ),
                //     ),
                //   ],
                // ),
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
                      onPressed: _endSession,
                      child: const Text('Thử lại'),
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