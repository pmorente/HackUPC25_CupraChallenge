import 'package:flutter/material.dart';

class ClueDisplay extends StatelessWidget {
  final String clue;

  const ClueDisplay({
    Key? key,
    required this.clue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Clue:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            clue,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
