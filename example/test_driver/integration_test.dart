import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, dynamic>? args,
    ]) async {
      // Save directly to the example/doc/screenshots directory
      final File localDocImage = File('doc/screenshots/$screenshotName.png');
      await localDocImage.parent.create(recursive: true);
      await localDocImage.writeAsBytes(screenshotBytes);

      // Mirror to artifact directory if it exists
      const String artifactDir =
          '/Users/manesh/.gemini/antigravity/brain/d28f8082-76bf-42f9-85e0-c57cac7db5d2/screenshots';
      final artifactDirFile = Directory(artifactDir);
      if (await artifactDirFile.exists()) {
        final File artImage = File('$artifactDir/$screenshotName.png');
        await artImage.writeAsBytes(screenshotBytes);
      }

      // ignore: avoid_print
      print(
          '📸 [Flutter Screenshot Saved]: ${localDocImage.path} (${screenshotBytes.length} bytes)');
      return true;
    },
  );
}
