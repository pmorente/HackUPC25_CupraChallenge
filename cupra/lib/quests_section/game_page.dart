import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class GamePage extends StatefulWidget {
  final Map<String, dynamic> cardData;
  final String serverUrl;
  final String gameId;
  final String initialClue;

  const GamePage({
    super.key,
    required this.cardData,
    required this.serverUrl,
    required this.gameId,
    required this.initialClue,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final TextEditingController _guessController = TextEditingController();
  String currentClue = '';
  bool isLoading = false;
  bool gameOver = false;
  bool won = false;
  String message = '';
  int attempt = 1;
  int attemptsRemaining = 5;
  List<String> previousClues = [];

  @override
  void initState() {
    super.initState();
    currentClue = widget.initialClue;
    previousClues.add(widget.initialClue);
  }

  Future<void> submitGuess(String guess) async {
    if (guess.isEmpty || isLoading || gameOver) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.serverUrl}/guess'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'game_id': widget.gameId,
          'guess': guess,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data['next_clue'] != null) {
            currentClue = data['next_clue'];
            previousClues.add(data['next_clue']);
          }
          gameOver = data['game_over'] ?? false;
          won = data['won'] ?? false;
          message = data['message'] ?? '';
          attempt = data['attempts_used'] ?? attempt + 1;
          attemptsRemaining =
              data['attempts_remaining'] ?? attemptsRemaining - 1;
          isLoading = false;
        });

        if (gameOver) {
          _showGameOverDialog(won, data['correct_concept'] ?? '');
        }

        _guessController.clear();
      } else {
        setState(() {
          message = 'Error submitting guess';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  void _showGameOverDialog(bool won, String correctAnswer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(won ? 'Congratulations!' : 'Game Over'),
          content: Text(
            won
                ? 'You correctly guessed the feature!'
                : 'The correct answer was: $correctAnswer',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to Categories'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to categories
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.cardData['image'],
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Attempts Counter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attempts:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAB6C40),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.circle,
                            size: 12,
                            color: index < attemptsRemaining
                                ? const Color(0xFFAB6C40)
                                : Colors.red,
                          ),
                        );
                      }),
                    ),
                    Text(
                      '$attemptsRemaining/5',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAB6C40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Current Clue
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clue #${previousClues.length}:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAB6C40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentClue,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Previous Clues
              if (previousClues.length > 1)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Previous Clues:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAB6C40),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...previousClues.asMap().entries.map((entry) {
                        if (entry.key == previousClues.length - 1)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key + 1}.',
                                style: const TextStyle(
                                  color: Color(0xFFAB6C40),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Message (if any)
              if (message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.toLowerCase().contains('incorrect')
                        ? Colors.red.withOpacity(0.2)
                        : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: message.toLowerCase().contains('incorrect')
                          ? Colors.red
                          : const Color(0xFFAB6C40),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        message.toLowerCase().contains('incorrect')
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: message.toLowerCase().contains('incorrect')
                            ? Colors.red
                            : const Color(0xFFAB6C40),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: message.toLowerCase().contains('incorrect')
                                ? Colors.red
                                : const Color(0xFFAB6C40),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Guess Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Guess:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFAB6C40),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _guessController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your guess...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFAB6C40),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFAB6C40),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          submitGuess(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading || gameOver
                            ? null
                            : () {
                                if (_guessController.text.isNotEmpty) {
                                  submitGuess(_guessController.text);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAB6C40),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Guess',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }
}
