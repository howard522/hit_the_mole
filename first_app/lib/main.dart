import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '打地鼠遊戲',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: 400, // 設置視窗寬度
            height: 600, // 設置視窗高度
            child: child!,
          ),
        );
      },
      home: const WhackAMolePage(),
    );
  }
}

class WhackAMolePage extends StatefulWidget {
  const WhackAMolePage({super.key});

  @override
  State<WhackAMolePage> createState() => _WhackAMolePageState();
}

class _WhackAMolePageState extends State<WhackAMolePage> {
  int score = 0;
  List<bool> moleVisible = List.generate(9, (index) => false);
  Timer? gameTimer;
  bool isPlaying = false;

  void startGame() {
    score = 0;
    isPlaying = true;
    gameTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      setState(() {
        moleVisible = List.generate(9, (index) => false);
        moleVisible[Random().nextInt(9)] = true;
      });
    });
  }

  void stopGame() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
      moleVisible = List.generate(9, (index) => false);
    });
  }

  void hitMole(int index) {
    if (moleVisible[index] && isPlaying) {
      setState(() {
        score++;
        moleVisible[index] = false;
      });
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('打地鼠遊戲'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '分數: $score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => hitMole(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child:
                          moleVisible[index]
                              ? Icon(
                                Icons.pets,
                                size: 40,
                                color: Colors.brown[900],
                              )
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isPlaying ? stopGame : startGame,
              child: Text(
                isPlaying ? '停止遊戲' : '開始遊戲',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
