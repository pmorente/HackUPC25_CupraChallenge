import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Initialize {
  static Future<void> initializeFiles() async {
    try {
      print('🔄 Starting initialization process...');

      // Create json_awards directory if it doesn't exist
      final directory = Directory('json_awards');
      if (!await directory.exists()) {
        print('📁 Creating json_awards directory...');
        await directory.create(recursive: true);
        print('✅ json_awards directory created successfully');
      } else {
        print('ℹ️ json_awards directory already exists');
      }

      // Initialize myAwards.json with empty structure
      final myAwardsFile = File('json_awards/myAwards.json');
      if (!await myAwardsFile.exists()) {
        print('📄 Creating myAwards.json...');
        await myAwardsFile.writeAsString(jsonEncode({}));
        print('✅ myAwards.json created successfully');
      } else {
        print('ℹ️ myAwards.json already exists');
      }

      // Initialize queueAwards.json with empty structure
      final queueAwardsFile = File('json_awards/queueAwards.json');
      if (!await queueAwardsFile.exists()) {
        print('📄 Creating queueAwards.json...');
        await queueAwardsFile.writeAsString(
          jsonEncode({"number": 0, "Obtained awards": []}),
        );
        print('✅ queueAwards.json created successfully');
      } else {
        print('ℹ️ queueAwards.json already exists');
      }

      // Copy cupraStickers.json from assets to json_awards directory
      print('📦 Loading cupraStickers.json from assets...');
      final stickersContent = await rootBundle.loadString(
        'assets/cupraStickers.json',
      );
      final stickersFile = File('json_awards/cupraStickers.json');
      print('💾 Saving cupraStickers.json to json_awards directory...');
      await stickersFile.writeAsString(stickersContent);
      print('✅ cupraStickers.json saved successfully');

      print('🎉 Initialization completed successfully!');
    } catch (e) {
      print('❌ Error during initialization: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> loadStickers() async {
    try {
      print('📥 Loading stickers data...');
      final stickersFile = File('json_awards/cupraStickers.json');
      final content = await stickersFile.readAsString();
      final data = jsonDecode(content);
      print('✅ Successfully loaded ${data['stickers']?.length ?? 0} stickers');
      return data;
    } catch (e) {
      print('❌ Error loading stickers: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> loadMyAwards() async {
    try {
      print('📥 Loading my awards data...');
      final myAwardsFile = File('json_awards/myAwards.json');
      final content = await myAwardsFile.readAsString();
      final data = jsonDecode(content);
      print('✅ Successfully loaded my awards data');
      return data;
    } catch (e) {
      print('❌ Error loading my awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> loadQueueAwards() async {
    try {
      print('📥 Loading queue awards data...');
      final queueAwardsFile = File('json_awards/queueAwards.json');
      final content = await queueAwardsFile.readAsString();
      final data = jsonDecode(content);
      print('✅ Successfully loaded queue awards data');
      return data;
    } catch (e) {
      print('❌ Error loading queue awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<void> saveMyAwards(Map<String, dynamic> data) async {
    try {
      print('💾 Saving my awards data...');
      final myAwardsFile = File('json_awards/myAwards.json');
      await myAwardsFile.writeAsString(jsonEncode(data));
      print('✅ Successfully saved my awards data');
    } catch (e) {
      print('❌ Error saving my awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<void> saveQueueAwards(Map<String, dynamic> data) async {
    try {
      print('💾 Saving queue awards data...');
      final queueAwardsFile = File('json_awards/queueAwards.json');
      await queueAwardsFile.writeAsString(jsonEncode(data));
      print('✅ Successfully saved queue awards data');
    } catch (e) {
      print('❌ Error saving queue awards: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<void> initializeApp() async {
    try {
      print('🔄 Starting app initialization...');

      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String metadataPath = '${appDir.path}/metadata.json';
      final String imagesDirPath = '${appDir.path}/images';

      // Check if metadata.json exists in the app directory
      final File metadataFile = File(metadataPath);
      bool needsUpdate = false;

      if (await metadataFile.exists()) {
        // Read the current metadata file
        final String currentMetadata = await metadataFile.readAsString();
        final List<dynamic> currentData = json.decode(currentMetadata);

        // Read the bundled metadata file
        final String bundledMetadata =
            await rootBundle.loadString('assets/metadata.json');
        final List<dynamic> bundledData = json.decode(bundledMetadata);

        // Compare the data to check if an update is needed
        needsUpdate = !_areMetadataEqual(currentData, bundledData);
      } else {
        needsUpdate = true;
      }

      // If update is needed, update both metadata and images
      if (needsUpdate) {
        print('📦 Updating metadata and images...');

        // Update metadata file
        final String bundledMetadata =
            await rootBundle.loadString('assets/metadata.json');
        await metadataFile.writeAsString(bundledMetadata);
        print('✅ Metadata file updated successfully');

        // Handle images directory
        final Directory imagesDir = Directory(imagesDirPath);
        if (await imagesDir.exists()) {
          print('🗑️ Removing old images directory...');
          await imagesDir.delete(recursive: true);
        }

        print('📁 Creating new images directory...');
        await imagesDir.create(recursive: true);

        // Copy images from assets to app directory
        final List<dynamic> metadata = json.decode(bundledMetadata);
        for (var item in metadata) {
          final String imagePath = item['image'] as String;
          final String imageName = imagePath.split('/').last;

          try {
            final ByteData imageData =
                await rootBundle.load('assets/images/$imageName');
            final File imageFile = File('$imagesDirPath/$imageName');
            await imageFile.writeAsBytes(imageData.buffer.asUint8List());
            print('✅ Copied image: $imageName');
          } catch (e) {
            print('⚠️ Failed to copy image $imageName: $e');
          }
        }

        print('🎉 Images update completed');
      } else {
        print('ℹ️ No updates needed for metadata and images');
      }

      // Initialize other components
      await _initializeOtherComponents();
    } catch (e) {
      print('❌ Error during initialization: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static bool _areMetadataEqual(List<dynamic> data1, List<dynamic> data2) {
    if (data1.length != data2.length) return false;

    for (int i = 0; i < data1.length; i++) {
      final item1 = data1[i] as Map<String, dynamic>;
      final item2 = data2[i] as Map<String, dynamic>;

      if (item1['title'] != item2['title'] ||
          item1['description'] != item2['description'] ||
          item1['image'] != item2['image'] ||
          item1['text'] != item2['text']) {
        return false;
      }
    }
    return true;
  }

  static Future<void> _initializeOtherComponents() async {
    // Add other initialization tasks here
    // For example:
    // - Initialize Firebase
    // - Set up local storage
    // - Initialize other services
  }
}
