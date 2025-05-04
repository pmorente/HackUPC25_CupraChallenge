import 'dart:convert';
import 'dart:io';
import '../../../initialize.dart';

class QueueJsonLogic {
  // Add a new award to the queue
  static Future<void> addAwardToQueue(String stickerId, int section) async {
    try {
      print('➕ Adding award to queue: stickerId=$stickerId, section=$section');

      // Load current queue
      final queueData = await Initialize.loadQueueAwards();
      final awards = List<Map<String, dynamic>>.from(
        queueData['Obtained awards'] ?? [],
      );

      // Add new award
      awards.add({'section': section, 'id': stickerId});

      // Update number and save
      await Initialize.saveQueueAwards({
        'number': awards.length,
        'Obtained awards': awards,
      });

      print('✅ Award added to queue successfully');
    } catch (e) {
      print('❌ Error adding award to queue: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Remove an award from the queue
  static Future<void> removeAwardFromQueue(
    String stickerId,
    int section,
  ) async {
    try {
      print(
        '➖ Removing award from queue: stickerId=$stickerId, section=$section',
      );

      // Load current queue
      final queueData = await Initialize.loadQueueAwards();
      final awards = List<Map<String, dynamic>>.from(
        queueData['Obtained awards'] ?? [],
      );

      // Remove the award
      awards.removeWhere(
        (award) => award['id'] == stickerId && award['section'] == section,
      );

      // Update number and save
      await Initialize.saveQueueAwards({
        'number': awards.length,
        'Obtained awards': awards,
      });

      print('✅ Award removed from queue successfully');
    } catch (e) {
      print('❌ Error removing award from queue: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get all awards in the queue
  static Future<List<Map<String, dynamic>>> getAllAwardsInQueue() async {
    try {
      print('📋 Getting all awards in queue...');

      final queueData = await Initialize.loadQueueAwards();
      final awards = List<Map<String, dynamic>>.from(
        queueData['Obtained awards'] ?? [],
      );

      print('✅ Retrieved ${awards.length} awards from queue');
      return awards;
    } catch (e) {
      print('❌ Error getting awards from queue: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get awards in queue by section
  static Future<List<Map<String, dynamic>>> getAwardsInQueueBySection(
    int section,
  ) async {
    try {
      print('📋 Getting awards in queue for section $section...');

      final queueData = await Initialize.loadQueueAwards();
      final allAwards = List<Map<String, dynamic>>.from(
        queueData['Obtained awards'] ?? [],
      );
      final sectionAwards =
          allAwards.where((award) => award['section'] == section).toList();

      print('✅ Retrieved ${sectionAwards.length} awards for section $section');
      return sectionAwards;
    } catch (e) {
      print('❌ Error getting awards by section: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get number of awards in queue
  static Future<int> getQueueCount() async {
    try {
      print('🔢 Getting queue count...');

      final queueData = await Initialize.loadQueueAwards();
      final count = queueData['number'] as int? ?? 0;

      print('✅ Queue count: $count');
      return count;
    } catch (e) {
      print('❌ Error getting queue count: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Clear all awards from queue
  static Future<void> clearQueue() async {
    try {
      print('🧹 Clearing queue...');

      await Initialize.saveQueueAwards({'number': 0, 'Obtained awards': []});

      print('✅ Queue cleared successfully');
    } catch (e) {
      print('❌ Error clearing queue: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Check if an award exists in queue
  static Future<bool> isAwardInQueue(String stickerId, int section) async {
    try {
      print(
        '🔍 Checking if award exists in queue: stickerId=$stickerId, section=$section',
      );

      final queueData = await Initialize.loadQueueAwards();
      final awards = List<Map<String, dynamic>>.from(
        queueData['Obtained awards'] ?? [],
      );

      final exists = awards.any(
        (award) => award['id'] == stickerId && award['section'] == section,
      );

      print('✅ Award ${exists ? 'exists' : 'does not exist'} in queue');
      return exists;
    } catch (e) {
      print('❌ Error checking award in queue: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
