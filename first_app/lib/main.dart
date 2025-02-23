import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
        return Center(child: SizedBox(width: 400, height: 600, child: child!));
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
  final AudioPlayer _backgroundMusic = AudioPlayer();
  int score = 0;
  List<bool> moleVisible = List.generate(9, (index) => false);
  Timer? gameTimer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _backgroundMusic.setAsset('assets/audio/background_music.mp3');
      await _backgroundMusic.setLoopMode(LoopMode.one);
      await _backgroundMusic.setVolume(0.5); // Set volume to 50%

      print('Audio initialized successfully');
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  Future<void> _playHitSound() async {
    try {
      // 創建新的音效播放器實例
      final hitPlayer = AudioPlayer();
      await hitPlayer.setAsset('assets/audio/hit_sound.mp3');
      await hitPlayer.setVolume(1.0);
      await hitPlayer.play();
      // 播放完成後釋放資源
      hitPlayer.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          hitPlayer.dispose();
        }
      });
    } catch (e) {
      print('Error playing hit sound: $e');
    }
  }

  void startGame() {
    score = 0;
    isPlaying = true;
    _backgroundMusic.seek(Duration.zero); // Reset to beginning
    _backgroundMusic
        .play()
        .then((_) {
          print('Background music started');
        })
        .catchError((error) {
          print('Error playing background music: $error');
        });
    gameTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      setState(() {
        moleVisible = List.generate(9, (index) => false);
        moleVisible[Random().nextInt(9)] = true;
      });
    });
  }

  void stopGame() {
    _backgroundMusic.stop();
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
      moleVisible = List.generate(9, (index) => false);
    });
  }

  void hitMole(int index) {
    if (moleVisible[index] && isPlaying) {
      _playHitSound(); // 使用新的音效播放方法
      setState(() {
        score++;
        moleVisible[index] = false;
      });
    }
  }

  @override
  void dispose() {
    _backgroundMusic.dispose();
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'GameFont',
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // 確保每個地鼠洞是正方形
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => hitMole(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          'assets/images/mole_hole.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (moleVisible[index])
                        Positioned(
                          bottom: 10, // 讓地鼠稍微浮現
                          child: Image.asset(
                            'assets/images/mole.png',
                            width: 80, // 控制地鼠大小
                            height: 80,
                          ),
                        ),
                    ],
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
                style: const TextStyle(fontSize: 18, fontFamily: 'GameFont'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
