import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NeonTicTacToeApp());
}

class NeonTicTacToeApp extends StatelessWidget {
  const NeonTicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neon Tic-Tac-Toe AI',
      theme: ThemeData.dark(useMaterial3: true),
      home: const TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> _board = List.filled(9, '');
  bool _isPlayerTurn = true;
  String _statusMessage = 'Your Turn (X)';
  int _playerWins = 0;
  int _aiWins = 0;
  int _draws = 0;
  bool _gameOver = false;

  static const List<List<int>> _winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  void _handleTap(int index) {
    if (_board[index].isNotEmpty || !_isPlayerTurn || _gameOver) return;

    setState(() {
      _board[index] = 'X';
      if (_checkWinner('X')) {
        _playerWins++;
        _statusMessage = 'You Win! 🎉';
        _gameOver = true;
        return;
      }
      if (!_board.contains('')) {
        _draws++;
        _statusMessage = 'Draw Game!';
        _gameOver = true;
        return;
      }
      _isPlayerTurn = false;
      _statusMessage = 'AI Thinking...';
    });

    Future.delayed(const Duration(milliseconds: 350), _makeAiMove);
  }

  void _makeAiMove() {
    if (_gameOver || !mounted) return;

    int move = _findBestMove('O'); // AI жеңуге тырысады
    move = move == -1 ? _findBestMove('X') : move; // Ойыншыны бұғаттайды
    if (move == -1 && _board[4].isEmpty) move = 4; // Орталықты алады
    if (move == -1) {
      final emptyIndices = <int>[];
      for (int i = 0; i < 9; i++) {
        if (_board[i].isEmpty) emptyIndices.add(i);
      }
      if (emptyIndices.isNotEmpty) {
        move = emptyIndices[Random().nextInt(emptyIndices.length)];
      }
    }

    if (move != -1) {
      setState(() {
        _board[move] = 'O';
        if (_checkWinner('O')) {
          _aiWins++;
          _statusMessage = 'AI Wins! 🤖';
          _gameOver = true;
          return;
        }
        if (!_board.contains('')) {
          _draws++;
          _statusMessage = 'Draw Game!';
          _gameOver = true;
          return;
        }
        _isPlayerTurn = true;
        _statusMessage = 'Your Turn (X)';
      });
    }
  }

  int _findBestMove(String symbol) {
    for (final pattern in _winPatterns) {
      final a = _board[pattern[0]];
      final b = _board[pattern[1]];
      final c = _board[pattern[2]];
      if (a == symbol && b == symbol && c.isEmpty) return pattern[2];
      if (a == symbol && c == symbol && b.isEmpty) return pattern[1];
      if (b == symbol && c == symbol && a.isEmpty) return pattern[0];
    }
    return -1;
  }

  bool _checkWinner(String symbol) {
    for (final pattern in _winPatterns) {
      if (_board[pattern[0]] == symbol &&
          _board[pattern[1]] == symbol &&
          _board[pattern[2]] == symbol) {
        return true;
      }
    }
    return false;
  }

  void _resetBoard() {
    setState(() {
      _board = List.filled(9, '');
      _isPlayerTurn = true;
      _statusMessage = 'Your Turn (X)';
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'NEON TIC-TAC-TOE',
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _scoreBadge('YOU (X)', _playerWins, Colors.cyanAccent),
                _scoreBadge('DRAWS', _draws, Colors.grey),
                _scoreBadge('AI (O)', _aiWins, Colors.pinkAccent),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (ctx, index) {
                  final val = _board[index];
                  final isX = val == 'X';
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181D2D),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: val.isEmpty
                              ? Colors.white12
                              : (isX ? Colors.cyanAccent : Colors.pinkAccent),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          val,
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: isX ? Colors.cyanAccent : Colors.pinkAccent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _resetBoard,
              icon: const Icon(Icons.refresh),
              label: const Text('New Round'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.cyanAccent.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreBadge(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181D2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
