import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/aqi_provider.dart';
import 'home_screen.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _startLoadingMessages();
    _loadDataAndMaybeNavigate();
  }

  void _startAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  void _startLoadingMessages() {
    final random = Random();;
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

    await Future.delayed(const Duration(seconds: 10));

    if (!mounted) return;

    if (isMinigameOpen) {
      setState(() {
        isLoadingDone = true;
      });
    } else {
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
      builder: (_) => _ColorPopGame(
        onExit: () {
          Navigator.of(context).pop();
          setState(() {
            isMinigameOpen = false;
          });

          if (isLoadingDone) {
            _goToHome();
          }
        },
        isLoadingDone: isLoadingDone,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
                Image.asset(
                  'assets/loading.gif',
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 20),
                Text(
                  currentMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 10,
                      color: Colors.white24,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _animation.value.clamp(0.01, 1.0),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 1),
                              height: 10,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.cyan],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _openMinigame,
                  icon: const Icon(Icons.videogame_asset),
                  label: const Text("Play Minigame"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
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

// --------------------- MINIGAME WIDGET ------------------------

class _ColorPopGame extends StatefulWidget {
  final VoidCallback onExit;
  final bool isLoadingDone;
  const _ColorPopGame({
    required this.onExit,
    required this.isLoadingDone,
  });

  @override
  State<_ColorPopGame> createState() => _ColorPopGameState();
}

class _ColorPopGameState extends State<_ColorPopGame> {
  final int gridSize = 3;
  int targetIndex = 0;
  int score = 0;
  Timer? gameTimer;
  int? wrongTappedIndex;

  @override
  void initState() {
    super.initState();
    _shuffleTarget();
    gameTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _shuffleTarget();
    });
  }

  void _shuffleTarget() {
    setState(() {
      final indices = List.generate(gridSize * gridSize, (i) => i)..shuffle();
      targetIndex = indices.first;
      wrongTappedIndex = null;
    });
  }

  void _handleTap(int index) {
    if (index == targetIndex) {
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

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🎯 Color Pop",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text("Score: $score", style: const TextStyle(fontSize: 16, color: Colors.white70)),
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
                            ? Colors.red
                            : isTarget
                                ? Colors.blue
                                : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isTarget
                              ? Colors.cyanAccent
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
                "✅ Data loaded! You can exit now.",
                style: TextStyle(color: Colors.greenAccent),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onExit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              child: const Text("Exit Game", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
