import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../providers/aqi_provider.dart';
import 'home_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> loadingMessages = [
    "Fetching Air Quality...",
    "Checking Weather...",
    "Exploring the Sky...",
    "Patience is key...",
    "Checking Server...",
    "Preparing Coffee...",
    "Reading Sensors...",
    "We're almost there...",
    "Open up the Skies...",
    "Assembling Data...",
    "Just a bit more...",
    "Almost there...",
    "Resonating Frequencies...",
    "Preparing the Journey...",
    "Aligning Stars...",
    "Breathing Fresh Air...",
    "Don't forget to touch grass!"
  ];

  String currentMessage = "Loading...";
  bool isMinigameOpen = false;
  bool isLoadingDone = false;
  double _progress = 0.0;
  Timer? _progressTimer;
  Timer? _postLoadProgressTimer;
  int selectedGame = 0;

  @override
  void initState() {
    super.initState();
    _startProgressTimer();
    _startLoadingMessages();
    _loadDataAndMaybeNavigate();
  }

  void _startProgressTimer() {
    const tick = Duration(milliseconds: 80);
    const maxBeforeAPI = 0.85;

    _progressTimer = Timer.periodic(tick, (timer) {
      if (_progress < maxBeforeAPI) {
        setState(() {
          _progress += 0.01;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startPostLoadProgress() {
    const tick = Duration(milliseconds: 50);
    _postLoadProgressTimer = Timer.periodic(tick, (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.005 + Random().nextDouble() * 0.002;
          if (_progress > 1.0) _progress = 1.0;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startLoadingMessages() {
    final random = Random();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isLoadingDone) {
        timer.cancel();
        return;
      }
      setState(() {
        currentMessage = loadingMessages[random.nextInt(loadingMessages.length)];
      });
    });
  }

  Future<void> _loadDataAndMaybeNavigate() async {
    final provider = Provider.of<AQIProvider>(context, listen: false);

    try {
      await provider.fetchAllProvincesAQI();
    } catch (e) {
      debugPrint('❌ Error loading AQI data: $e');
    }

    if (!mounted) return;

    setState(() {
      isLoadingDone = true;
    });

    _startPostLoadProgress();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    if (!isMinigameOpen) {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _openMinigame() {
    setState(() {
      isMinigameOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => selectedGame == 0
          ? ColorPopGame(onExit: _closeMinigame, isLoadingDone: isLoadingDone)
          : BlockBlastGame(onExit: _closeMinigame, isLoadingDone: isLoadingDone),
    );
  }

  void _closeMinigame() {
    Navigator.of(context).pop();
    setState(() {
      isMinigameOpen = false;
    });
    if (isLoadingDone) _goToHome();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _postLoadProgressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/loading.gif', width: 160, height: 160),
                const SizedBox(height: 20),
                Text(currentMessage, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 10,
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: MediaQuery.of(context).size.width * _progress.clamp(0.0, 1.0) * 0.6,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF7F7FD5),
                                  Color(0xFF86A8E7),
                                  Color(0xFF91EAE4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ToggleButtons(
                  isSelected: [selectedGame == 0, selectedGame == 1],
                  onPressed: (index) => setState(() => selectedGame = index),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  selectedColor: Colors.black,
                  fillColor: Colors.lightBlueAccent,
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Mist Pop")),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Mist Blast")),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _openMinigame,
                  icon: const Icon(Icons.videogame_asset),
                  label: const Text("Play Minigame"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF005AA7),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (isLoadingDone && isMinigameOpen)
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "✅ Data loaded! Close the minigame to continue.",
                  style: TextStyle(color: Colors.greenAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
//                   MIST BLAST GAME
// --------------------------------------------------

class BlockBlastGame extends StatefulWidget {
  final VoidCallback onExit;
  final bool isLoadingDone;

  const BlockBlastGame({required this.onExit, required this.isLoadingDone});

  @override
  State<BlockBlastGame> createState() => _BlockBlastGameState();
}

class _BlockBlastGameState extends State<BlockBlastGame> {
  final int gridSize = 9;
  late List<List<int>> board;

  final List<List<List<int>>> predefinedShapes = [
    [[1, 1, 1]], // I horizontal
    [[1], [1], [1]], // I vertical
    [[1, 1], [1, 0]], // L
    [[1, 1], [0, 1]], // J
    [[1, 1], [1, 1]], // O
    [[1, 1, 1], [0, 1, 0]], // T
    [[1]], // Dot
  ];

  List<List<List<int>>> currentBlocks = [];
  int score = 0;

  Offset? hoveredPosition;
  List<List<int>>? hoveredShape;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    _generateNewBlocks();
  }

  void _generateNewBlocks() {
    final rand = Random();
    List<List<List<int>>> newBlocks = [];
    int attempt = 0;

    while (newBlocks.length < 3 && attempt < 100) {
      final shape = predefinedShapes[rand.nextInt(predefinedShapes.length)];
      if (_canPlaceAnywhere(shape)) {
        newBlocks.add(shape);
      }
      attempt++;
    }

    setState(() {
      currentBlocks = newBlocks;
    });
  }

  bool _canPlaceAnywhere(List<List<int>> shape) {
    for (int y = 0; y <= gridSize - shape.length; y++) {
      for (int x = 0; x <= gridSize - shape[0].length; x++) {
        if (_canPlace(shape, x, y)) return true;
      }
    }
    return false;
  }

  bool _canPlace(List<List<int>> shape, int startX, int startY) {
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[0].length; x++) {
        if (shape[y][x] == 1) {
          int boardX = startX + x;
          int boardY = startY + y;
          if (boardX >= gridSize || boardY >= gridSize || board[boardY][boardX] == 1) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _placeShape(List<List<int>> shape, int startX, int startY) async {
    setState(() {
      for (int y = 0; y < shape.length; y++) {
        for (int x = 0; x < shape[0].length; x++) {
          if (shape[y][x] == 1) {
            board[startY + y][startX + x] = 1;
          }
        }
      }
      hoveredShape = null;
      hoveredPosition = null;
    });

    await _audioPlayer.play(AssetSource('minigamesfx.mp3'));
    _clearFullLines();
    _generateNewBlocks();
  }

  void _clearFullLines() {
    int linesCleared = 0;

    for (int y = 0; y < gridSize; y++) {
      if (board[y].every((cell) => cell == 1)) {
        board[y] = List.filled(gridSize, 0);
        linesCleared++;
      }
    }

    for (int x = 0; x < gridSize; x++) {
      if (List.generate(gridSize, (y) => board[y][x]).every((cell) => cell == 1)) {
        for (int y = 0; y < gridSize; y++) {
          board[y][x] = 0;
        }
        linesCleared++;
      }
    }

    if (linesCleared > 0) {
      setState(() {
        score += linesCleared * 10;
      });
    }
  }

  Widget _buildBlockCell(bool filled, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: filled
            ? Colors.white.withAlpha((0.9 * 255).round())
            : highlight
                ? Colors.lightBlueAccent.withAlpha(120)
                : Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShape(List<List<int>> shape, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: shape.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((cell) {
            return Container(
              width: size,
              height: size,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: cell == 1 ? Colors.lightBlueAccent.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildDraggableShape(List<List<int>> shape) {
    return Draggable<List<List<int>>>(
      data: shape,
      feedback: _buildShape(shape, 24),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildShape(shape, 24)),
      child: _buildShape(shape, 24),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.indigo.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🧱 Block Blast", style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 10),
            Text("Score: $score", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            SizedBox(
              width: 270,
              height: 270,
              child: GridView.builder(
                itemCount: gridSize * gridSize,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
                itemBuilder: (context, index) {
                  final x = index % gridSize;
                  final y = index ~/ gridSize;

                  bool highlight = false;
                  if (hoveredShape != null && hoveredPosition != null) {
                    final hx = hoveredPosition!.dx.toInt();
                    final hy = hoveredPosition!.dy.toInt();
                    final shape = hoveredShape!;
                    for (int sy = 0; sy < shape.length; sy++) {
                      for (int sx = 0; sx < shape[0].length; sx++) {
                        if (shape[sy][sx] == 1 && hx + sx == x && hy + sy == y) {
                          highlight = _canPlace(shape, hx, hy);
                        }
                      }
                    }
                  }

                  return DragTarget<List<List<int>>>(
                    onWillAcceptWithDetails: (details) {
                      setState(() {
                        hoveredShape = details.data;
                        hoveredPosition = Offset(x.toDouble(), y.toDouble());
                      });
                      return _canPlace(details.data, x, y);
                    },
                    onLeave: (data) {
                      setState(() {
                        hoveredShape = null;
                        hoveredPosition = null;
                      });
                    },
                    onAcceptWithDetails: (details) {
                      _placeShape(details.data, x, y);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return _buildBlockCell(board[y][x] == 1, highlight: highlight);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: currentBlocks.map(_buildDraggableShape).toList(),
            ),
            const SizedBox(height: 20),
            if (widget.isLoadingDone)
              const Text("✅ Don't rage quit please", style: TextStyle(color: Colors.greenAccent)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onExit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: const Text("Exit Game", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
//                   MIST POP MINIGAME
// --------------------------------------------------

class ColorPopGame extends StatefulWidget {
  final VoidCallback onExit;
  final bool isLoadingDone;

  const ColorPopGame({
    required this.onExit,
    required this.isLoadingDone,
  });

  @override
  State<ColorPopGame> createState() => ColorPopGameState();
}

class ColorPopGameState extends State<ColorPopGame> {
  final int gridSize = 3;
  int targetIndex = 0;
  int score = 0;
  Timer? gameTimer;
  int? wrongTappedIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _shuffleTarget();
    gameTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _shuffleTarget();
    });
  }

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('minigamesfx.mp3'));
  }

  Future<void> _handleTap(int index) async {
    if (index == targetIndex) {
      await _playSuccessSound();
      setState(() {
        score++;
        wrongTappedIndex = null;
      });
    } else {
      setState(() {
        score = (score > 0) ? score - 1 : 0;
        wrongTappedIndex = index;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => wrongTappedIndex = null);
        }
      });
    }
    _shuffleTarget();
  }

  void _shuffleTarget() {
    setState(() {
      final indices = List.generate(gridSize * gridSize, (i) => i)..shuffle();
      targetIndex = indices.first;
      wrongTappedIndex = null;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🌫️ Clear the Mist",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text("Purified: $score", style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              width: 240,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gridSize * gridSize,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final isTarget = index == targetIndex;
                  final isWrong = index == wrongTappedIndex;

                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isWrong
                            ? Colors.red.withOpacity(0.7)
                            : isTarget
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isTarget
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                        border: Border.all(
                          color: isTarget
                              ? Colors.lightBlueAccent
                              : isWrong
                                  ? Colors.redAccent
                                  : Colors.white24,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (widget.isLoadingDone)
              const Text(
                "✅ Please don't escape us just like the mist block",
                style: TextStyle(color: Colors.greenAccent),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onExit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: const Text("Exit Game", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
