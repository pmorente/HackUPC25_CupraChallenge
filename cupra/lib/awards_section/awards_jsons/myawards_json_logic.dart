import 'dart:convert';
import 'dart:io';
import '../../../initialize.dart';

class MyAwardsJsonLogic {
  // Find a sticker in cupraStickers.json by section and id
  static Future<Map<String, dynamic>?> findStickerInCupraStickers(
    int section,
    String stickerId,
  ) async {
    try {
      print('🔍 Finding sticker: section=$section, id=$stickerId');

      final stickersData = await Initialize.loadStickers();

      // Find the section that matches the given section number
      final sectionEntry = stickersData.entries.firstWhere(
        (entry) => entry.value['section'] == section,
        orElse: () => MapEntry('', {}),
      );

      if (sectionEntry.key.isEmpty) {
        print('❌ Section $section not found in cupraStickers.json');
        return null;
      }

      // Find the sticker in the section's items
      final sticker = (sectionEntry.value['items'] as List).firstWhere(
        (item) => item['id'] == stickerId,
        orElse: () => null,
      );

      if (sticker == null) {
        print('❌ Sticker $stickerId not found in section $section');
        return null;
      }

      print('✅ Found sticker: ${sticker['name']}');
      return sticker;
    } catch (e) {
      print('❌ Error finding sticker: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Add a sticker to myAwards.json
  static Future<void> addStickerToMyAwards(
    int section,
    String stickerId,
  ) async {
    try {
      print('➕ Adding sticker to my awards: section=$section, id=$stickerId');

      // First find the sticker in cupraStickers.json
      final sticker = await findStickerInCupraStickers(section, stickerId);
      if (sticker == null) {
        throw Exception('Sticker not found in cupraStickers.json');
      }

      // Load current myAwards
      final myAwardsData = await Initialize.loadMyAwards();

      // Find the section name that matches the section number
      final stickersData = await Initialize.loadStickers();
      final sectionEntry = stickersData.entries.firstWhere(
        (entry) => entry.value['section'] == section,
        orElse: () => MapEntry('', {}),
      );

      if (sectionEntry.key.isEmpty) {
        throw Exception('Section $section not found in cupraStickers.json');
      }

      final sectionName = sectionEntry.key;

      // Initialize section if it doesn't exist
      if (!myAwardsData.containsKey(sectionName)) {
        myAwardsData[sectionName] = {'count': 0, 'items': []};
      }

      // Add the sticker to the section
      final sectionData = myAwardsData[sectionName] as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(sectionData['items'] ?? []);

      // Check if sticker already exists
      if (items.any((item) => item['id'] == stickerId)) {
        print('ℹ️ Sticker already exists in my awards');
        return;
      }

      // Add new sticker
      items.add({
        'id': stickerId,
        'name': sticker['name'],
        'path': sticker['path'],
        'category': sticker['category'],
      });

      // Update count and save
      sectionData['count'] = items.length;
      sectionData['items'] = items;

      await Initialize.saveMyAwards(myAwardsData);
      print('✅ Sticker added to my awards successfully');
    } catch (e) {
      print('❌ Error adding sticker to my awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get all stickers in a section from myAwards.json
  static Future<List<Map<String, dynamic>>> getStickersInSection(
    int section,
  ) async {
    try {
      print('📋 Getting stickers in section $section...');

      // Load current myAwards
      final myAwardsData = await Initialize.loadMyAwards();

      // Find the section name that matches the section number
      final stickersData = await Initialize.loadStickers();
      final sectionEntry = stickersData.entries.firstWhere(
        (entry) => entry.value['section'] == section,
        orElse: () => MapEntry('', {}),
      );

      if (sectionEntry.key.isEmpty) {
        throw Exception('Section $section not found in cupraStickers.json');
      }

      final sectionName = sectionEntry.key;

      if (!myAwardsData.containsKey(sectionName)) {
        return [];
      }

      final sectionData = myAwardsData[sectionName] as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(sectionData['items'] ?? []);

      print('✅ Retrieved ${items.length} stickers from section $section');
      return items;
    } catch (e) {
      print('❌ Error getting stickers in section: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Remove a sticker from myAwards.json
  static Future<void> removeStickerFromMyAwards(
    int section,
    String stickerId,
  ) async {
    try {
      print(
        '➖ Removing sticker from my awards: section=$section, id=$stickerId',
      );

      // Load current myAwards
      final myAwardsData = await Initialize.loadMyAwards();

      // Find the section name that matches the section number
      final stickersData = await Initialize.loadStickers();
      final sectionEntry = stickersData.entries.firstWhere(
        (entry) => entry.value['section'] == section,
        orElse: () => MapEntry('', {}),
      );

      if (sectionEntry.key.isEmpty) {
        throw Exception('Section $section not found in cupraStickers.json');
      }

      final sectionName = sectionEntry.key;

      if (!myAwardsData.containsKey(sectionName)) {
        print('ℹ️ Section $sectionName not found in my awards');
        return;
      }

      final sectionData = myAwardsData[sectionName] as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(sectionData['items'] ?? []);

      // Remove the sticker
      items.removeWhere((item) => item['id'] == stickerId);

      // Update count and save
      sectionData['count'] = items.length;
      sectionData['items'] = items;

      await Initialize.saveMyAwards(myAwardsData);
      print('✅ Sticker removed from my awards successfully');
    } catch (e) {
      print('❌ Error removing sticker from my awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Check if a sticker exists in myAwards.json
  static Future<bool> isStickerInMyAwards(int section, String stickerId) async {
    try {
      print(
        '🔍 Checking if sticker exists in my awards: section=$section, id=$stickerId',
      );

      final stickers = await getStickersInSection(section);
      final exists = stickers.any((sticker) => sticker['id'] == stickerId);

      print('✅ Sticker ${exists ? 'exists' : 'does not exist'} in my awards');
      return exists;
    } catch (e) {
      print('❌ Error checking sticker in my awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
