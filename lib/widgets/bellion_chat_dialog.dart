import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../chat_session.dart';

class BellionChatDialog extends StatefulWidget {
  const BellionChatDialog({super.key});

  @override
  State<BellionChatDialog> createState() => _BellionChatDialogState();
}

class _BellionChatDialogState extends State<BellionChatDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  late AnimationController _dotsController;
  late Animation<int> _dotAnimation;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _dotAnimation = StepTween(begin: 1, end: 3).animate(_dotsController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      bellionChatMessages.add({'sender': 'me', 'text': text});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('https://bellion-backend.onrender.com/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': text,
              'user_id': 'flutter_user',
              'session_id': 'session_01',
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final reply = jsonDecode(response.body)['reply'] ?? '…';
        setState(() {
          bellionChatMessages.add({'sender': 'bot', 'text': reply});
        });
      } else {
        setState(() {
          bellionChatMessages.add({'sender': 'bot', 'text': 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์'});
        });
      }
    } catch (e) {
      setState(() {
        bellionChatMessages.add({'sender': 'bot', 'text': 'เกิดข้อผิดพลาด: ${e.toString()}'});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.chat, color: Color.fromARGB(255, 3, 71, 5)),
                  const SizedBox(width: 8),
                  const Text('Bellion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: bellionChatMessages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == bellionChatMessages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage('assets/aipfp.png'),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 2, 27, 138),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedBuilder(
                              animation: _dotAnimation,
                              builder: (_, __) {
                                final dots = '.' * _dotAnimation.value;
                                return Text('กำลังพิมพ์$dots', style: const TextStyle(color: Colors.white));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final msg = bellionChatMessages[index];
                  final isMe = msg['sender'] == 'me';

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage('assets/aipfp.png'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color.fromARGB(255, 70, 74, 78)
                                  : const Color.fromARGB(255, 2, 27, 138),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg['text'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                        title: const Text(
                          'ทำไม Bellion ถึงตอบช้า?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Bellion นั้นรันอยู่บนเซิร์ฟเวอร์ฟรี ซึ่งอาจมีความล่าช้าในการรับและส่งข้อมูลเป็นเรื่องปกติ '
                          'ขออภัยในความไม่สะดวก เราจะพยายามปรับปรุงให้ดีขึ้นครับ',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('ปิด', style: TextStyle(color: Colors.greenAccent)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 24, 24, 24),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color.fromARGB(255, 1, 20, 112), width: 1),
                  ),
                  child: const Text(
                    'ทำไม Bellion ถึงตอบช้า?',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.greenAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
