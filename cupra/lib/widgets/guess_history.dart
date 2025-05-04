import 'package:flutter/material.dart';

class GuessHistory extends StatelessWidget {
  final List<String> guesses;

  const GuessHistory({
    Key? key,
    required this.guesses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previous Guesses:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...guesses.reversed.map((guess) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  guess,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }
}
