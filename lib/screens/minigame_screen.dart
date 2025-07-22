import 'package:flutter/material.dart';
import 'splash_screen.dart';

class MinigameScreen extends StatefulWidget {
  const MinigameScreen({Key? key}) : super(key: key);

  @override
  State<MinigameScreen> createState() => _MinigameScreenState();
}

class _MinigameScreenState extends State<MinigameScreen> {
  bool showGameDialog = false;
  int selectedGame = 0;

  final List<String> gameNames = ['🧱 Block Blast', '🌫️ Mist Pop'];

  void _launchGame(int index) {
    setState(() {
      selectedGame = index;
      showGameDialog = true;
    });
  }

  void _exitGame() {
    setState(() {
      showGameDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('มินิเกม'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: gameNames.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(gameNames[index]),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => _launchGame(index),
              );
            },
          ),
          if (showGameDialog)
            Center(
              child: selectedGame == 0
                  ? BlockBlastGame(
                      onExit: _exitGame,
                      isLoadingDone: true,
                    )
                  : ColorPopGame(
                      onExit: _exitGame,
                      isLoadingDone: true,
                    ),
            ),
        ],
      ),
    );
  }
}
