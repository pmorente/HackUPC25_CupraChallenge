import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../bottom_navbar.dart';
import 'game_page.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  bool isLoading = false;
  String message = '';
  String serverUrl = 'http://localhost:5001';
  bool showConnectionStatus = true;
  List<String> possibleIps = [
    'localhost',
    '10.0.2.2', // Android emulator localhost
    '192.168.1.100',
    '192.168.0.100',
    '192.168.102.36',
    '10.192.244.234',
  ];

  // Metadata list that will be populated from JSON files
  List<Map<String, dynamic>> metadata = [];

  Future<List<Map<String, dynamic>>> loadMetadata() async {
    try {
      // Try loading from assets directory first
      String jsonString = await rootBundle.loadString('assets/metadata.json');
      if (jsonString.isNotEmpty) {
        List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error loading metadata from assets: $e');
      try {
        // Fallback to lib/image_text_data directory
        String jsonString =
            await rootBundle.loadString('lib/image_text_data/metadata.json');
        if (jsonString.isNotEmpty) {
          List<dynamic> jsonList = json.decode(jsonString);
          return jsonList.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        print('Error loading metadata from lib directory: $e');
        throw Exception('Failed to load metadata from both locations');
      }
    }
    throw Exception('No metadata found');
  }

  Future<void> findWorkingServer() async {
    setState(() {
      isLoading = true;
      message = 'Searching for server...';
    });

    for (String ip in possibleIps) {
      String testUrl = 'http://$ip:5001/docs';
      try {
        final response = await http
            .get(Uri.parse(testUrl))
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          setState(() {
            serverUrl = 'http://$ip:5001';
            message = 'Connected to server at $ip';
            isLoading = false;
          });
          return;
        }
      } catch (e) {
        // Continue to next IP
        continue;
      }
    }

    setState(() {
      message = 'Could not find the server. Please make sure it is running.';
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    findWorkingServer();
    loadMetadata().then((value) {
      setState(() {
        metadata = value;
      });
    });
  }

  Future<void> startGame(Map<String, dynamic> cardData) async {
    try {
      // Start a new game with the server
      final response = await http.post(
        Uri.parse('$serverUrl/start_game'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'card_data': cardData}),
      );

      if (response.statusCode == 200) {
        final gameData = json.decode(response.body);

        // Navigate to game page with both card data and initial game state
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GamePage(
              cardData: cardData,
              serverUrl: serverUrl,
              gameId: gameData['game_id'].toString(),
              initialClue: gameData['clue'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start game: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting game: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1820),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Know My Cupra Tavascan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Play CupraGuesser',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Metadata Cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: metadata.length,
                      itemBuilder: (context, index) {
                        final item = metadata[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => startGame(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['description'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      item['image'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Connection Status
                  if (showConnectionStatus)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.contains('Connected')
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              message.contains('Connected')
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: message.contains('Connected')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: message.contains('Connected')
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!message.contains('Connected'))
                              IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white),
                                onPressed: isLoading ? null : findWorkingServer,
                              ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  showConnectionStatus = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const BottomNavBar(currentPage: 'quests'),
        ],
      ),
    );
  }
}
