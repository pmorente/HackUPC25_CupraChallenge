import 'package:flutter/material.dart';
import '../bottom_navbar.dart';

class OpeningPage extends StatelessWidget {
  const OpeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1820),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/images/chest_award.png', width: 200, height: 200),
            const SizedBox(height: 32),
            const Text(
              'Opening Chest...',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAB6C40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AwardsPage extends StatelessWidget {
  const AwardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1820),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chest Card - keeping original structure, updating styling
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.only(
                      left: 0,
                      right: 16,
                      top: 16,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2530), // Dark card background
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFAB6C40),
                        width: 2,
                      ), // Copper border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: -20,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2530), // Dark container
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                color: const Color(
                                  0xFF1A2530,
                                ), // Dark container
                                child: Image.asset(
                                  'lib/images/chest_award.png',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 140),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Iterbee Chest',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAB6C40), // Copper text
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'You have new awards waiting!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const OpeningPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Open Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    backgroundColor: const Color(
                                      0xFFAB6C40,
                                    ), // Copper button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Iterbee Collection Section
                        const Text(
                          'Iterbee Collection',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.white, // Light text on dark background
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // First Card - using CUPRA styling
                        _buildAwardCard(
                          'Bee the journey, bee the story.',
                          'Your journey begins here',
                          'lib/images/iterbee_awards.png',
                          const Color(0xFF1A2530), // Dark card background
                        ),
                        const SizedBox(height: 16),

                        // Places Collection Section
                        const Text(
                          'Places Collections',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.white, // Light text on dark background
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Barcelona Card - keeping structure, updating colors
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1A2530,
                            ), // Dark card background
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  'lib/images/barcelona_awards.png',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Barcelona',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // Light text
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Explore the vibrant streets of Barcelona',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Colors
                                                .white70, // Light secondary text
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        _buildStat(
                                          '12',
                                          'Collected',
                                          Colors.white,
                                        ),
                                        const SizedBox(width: 24),
                                        _buildStat(
                                          '3',
                                          'Hidden',
                                          Colors.white70,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNavBar(currentPage: 'awards'),
        ],
      ),
    );
  }

  Widget _buildAwardCard(
    String title,
    String subtitle,
    String imagePath,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFAB6C40).withOpacity(0.3),
          width: 1,
        ), // Subtle copper border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAB6C40), // Copper text
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStat('5', 'Collected', Colors.white),
                    const SizedBox(width: 24),
                    _buildStat('2', 'Hidden', Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}
