import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cupra/models/card.dart';
import 'package:cupra/widgets/guess_input.dart';
import 'package:cupra/widgets/guess_history.dart';
import 'package:cupra/widgets/clue_display.dart';

class GuessView extends StatefulWidget {
  final CardModel card;

  const GuessView({Key? key, required this.card}) : super(key: key);

  @override
  _GuessViewState createState() => _GuessViewState();
}

class _GuessViewState extends State<GuessView> {
  String? gameId;
  String currentClue = '';
  List<String> guesses = [];
  int attemptsRemaining = 5;
  bool isGameOver = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _startGame() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract the text from the card data
      final cardData = {
        'text': widget.card.text,
        'title': widget.card.title,
        'description': widget.card.description,
        'image': widget.card.image
      };

      final response = await http.post(
        Uri.parse('http://localhost:5001/start_game'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cardData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          gameId = data['game_id'];
          currentClue = data['clue'];
          attemptsRemaining = data['attempts_remaining'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to start game');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting game: $e')),
      );
    }
  }

  Future<void> _submitGuess(String guess) async {
    if (gameId == null || isGameOver) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5001/submit_guess/$gameId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'guess': guess}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          guesses.add(guess);
          if (data['is_correct']) {
            isGameOver = true;
            currentClue = data['message'];
          } else {
            attemptsRemaining = data['attempts_remaining'];
            currentClue = data['next_clue'] ?? data['message'];
            if (attemptsRemaining <= 0) {
              isGameOver = true;
            }
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to submit guess');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting guess: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isGameOver ? _startGame : null,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset(
                          widget.card.image,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.card.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              ClueDisplay(clue: currentClue),
                              const SizedBox(height: 16),
                              Text(
                                'Attempts remaining: $attemptsRemaining',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        if (guesses.isNotEmpty) GuessHistory(guesses: guesses),
                      ],
                    ),
                  ),
                ),
                if (!isGameOver)
                  GuessInput(
                    onGuessSubmitted: _submitGuess,
                    isLoading: isLoading,
                  ),
              ],
            ),
    );
  }
}
