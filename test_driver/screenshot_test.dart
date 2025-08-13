import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gdrive_downloader_flutter/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Screenshots', () {
    testWidgets('Take app screenshots', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();
      
      // 等待应用完全加载
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 1. 主界面截图
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await takeScreenshot(binding, 'main_interface');
      
      // 2. 查找URL输入框并输入示例链接
      final urlField = find.byKey(const Key('url_input_field'));
      if (urlField.evaluate().isNotEmpty) {
        await tester.enterText(urlField, 'https://drive.google.com/drive/folders/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms');
        await tester.pumpAndSettle();
        await takeScreenshot(binding, 'with_url_input');
      }
      
      // 3. 如果有下载按钮，点击并截图
      final downloadButton = find.byKey(const Key('download_button'));
      if (downloadButton.evaluate().isNotEmpty) {
        await tester.tap(downloadButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await takeScreenshot(binding, 'download_initiated');
      }
      
      // 4. 查找设置按钮并截图设置页面
      final settingsButton = find.byKey(const Key('settings_button'));
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        await takeScreenshot(binding, 'settings_page');
      }
      
      print('Screenshots saved successfully!');
    });
  });
}

Future<void> takeScreenshot(IntegrationTestWidgetsFlutterBinding binding, String name) async {
  final screenshotData = await binding.takeScreenshot(name);
  final screenshotsDir = Directory('screenshots');
  if (!screenshotsDir.existsSync()) {
    screenshotsDir.createSync();
  }
  
  final file = File('screenshots/${name}.png');
  await file.writeAsBytes(screenshotData);
  print('Screenshot saved: ${file.path}');
}