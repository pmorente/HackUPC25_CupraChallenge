import 'package:flutter/material.dart';

class GuessInput extends StatelessWidget {
  final Function(String) onGuessSubmitted;
  final bool isLoading;

  const GuessInput({
    Key? key,
    required this.onGuessSubmitted,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your guess...',
                border: OutlineInputBorder(),
              ),
              enabled: !isLoading,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    final guess = controller.text.trim();
                    if (guess.isNotEmpty) {
                      onGuessSubmitted(guess);
                      controller.clear();
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
