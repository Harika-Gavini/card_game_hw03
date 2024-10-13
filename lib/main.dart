import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matching Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardGridScreen(),
    );
  }
}

class CardModel {
  final String frontImage;
  final String backImage;
  bool isFaceUp;

  CardModel({
    required this.frontImage,
    required this.backImage,
    this.isFaceUp = false,
  });
}

class GameProvider with ChangeNotifier {
  List<CardModel> _cards = [];
  List<CardModel> _flippedCards = [];
  int _score = 0;
  int _matchedPairs = 0;
  bool _isGameOver = false;
  Timer? _timer;
  int _timeElapsed = 0;
  int _bestScore = 0;
  int _bestTime = 0;

  GameProvider() {
    _initializeCards();
    _loadBestScore();
    _loadBestTime();
    _startTimer();
  }

  List<CardModel> get cards => _cards;
  int get score => _score;
  int get timeElapsed => _timeElapsed;
  bool get isGameOver => _isGameOver;
  int get bestScore => _bestScore;
  int get bestTime => _bestTime;

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    _bestScore = prefs.getInt('bestScore') ?? 0;
    notifyListeners();
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    _bestTime = prefs.getInt('bestTime') ?? 0;
    notifyListeners();
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (_score > _bestScore) {
      _bestScore = _score;
      await prefs.setInt('bestScore', _bestScore);
    }
  }

  Future<void> _saveBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (_timeElapsed < _bestTime || _bestTime == 0) {
      _bestTime = _timeElapsed;
      await prefs.setInt('bestTime', _bestTime);
    }
  }

  void _initializeCards() {
    _cards = [
      CardModel(
          frontImage: 'assets/card1.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card1.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card2.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card2.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card3.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card3.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card4.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card4.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card5.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card5.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card6.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card6.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card7.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card7.jpeg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card8.jpg', backImage: 'assets/flutterIcon.png'),
      CardModel(
          frontImage: 'assets/card8.jpg', backImage: 'assets/flutterIcon.png'),
    ];

    _cards.shuffle();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeElapsed++;
      notifyListeners();
    });
  }

  void flipCard(int index, BuildContext context) {
    if (_cards[index].isFaceUp || _flippedCards.length >= 2 || _isGameOver)
      return;

    _cards[index].isFaceUp = true;
    _flippedCards.add(_cards[index]);

    notifyListeners();

    if (_flippedCards.length == 2) {
      Future.delayed(Duration(seconds: 1), () {
        if (_flippedCards[0].frontImage == _flippedCards[1].frontImage) {
          _score += 10; // Score for matching
          _matchedPairs++;
          if (_matchedPairs == _cards.length ~/ 2) {
            _isGameOver = true;
            _timer?.cancel(); // Stop the timer
            _saveBestScore(); // Save best score if needed
            _saveBestTime(); // Save best time if needed
            _showVictoryDialog(context); // Pass context to show dialog
          }
        } else {
          _score -= 5; // Penalty for mismatching
          _flippedCards[0].isFaceUp = false;
          _flippedCards[1].isFaceUp = false;
        }
        _flippedCards.clear();
        notifyListeners();
      });
    }
  }

  void _showVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text(
              'You matched all pairs!\nScore: $_score\nBest Score: $_bestScore\nTime: $_timeElapsed seconds\nBest Time: $_bestTime seconds'),
          actions: [
            TextButton(
              child: Text('Restart Game'),
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    _initializeCards();
    _score = 0;
    _matchedPairs = 0;
    _isGameOver = false;
    _timeElapsed = 0;
    _timer?.cancel();
    _startTimer();
    notifyListeners();
  }
}

class CardGridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Card Flip Game'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: ${gameProvider.score}',
                      style: TextStyle(fontSize: 20)),
                  Text('Best Score: ${gameProvider.bestScore}',
                      style: TextStyle(fontSize: 20)),
                  Text('Time: ${gameProvider.timeElapsed}s',
                      style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                ),
                itemCount: gameProvider.cards.length,
                itemBuilder: (context, index) {
                  final card = gameProvider.cards[index];

                  return GestureDetector(
                    onTap: () => gameProvider.flipCard(index, context),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              card.isFaceUp ? card.frontImage : card.backImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      height: 100,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: card.isFaceUp
                            ? Matrix4.identity()
                            : Matrix4.rotationY(3.14),
                        child: Container(),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (gameProvider.isGameOver)
              ElevatedButton(
                onPressed: () {
                  gameProvider.resetGame();
                },
                child: Text('Restart Game'),
              ),
          ],
        ),
      ),
    );
  }
}
