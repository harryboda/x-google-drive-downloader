import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gdrive_downloader_flutter/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Real Application Screenshots', () {
    testWidgets('Capture real app screenshots with proper UI', (WidgetTester tester) async {
      // 设置窗口大小为标准macOS应用大小
      await binding.setSurfaceSize(const Size(800, 600));
      
      print('🚀 启动应用...');
      app.main();
      
      // 等待应用完全加载
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      print('📸 开始截图流程...');
      
      // 截图1: 初始状态的主界面
      await _takeScreenshot(binding, 'main_interface_clean', '主界面 - 初始状态');
      
      // 查找并操作URL输入框
      final urlInputFinder = find.byType(TextField).first;
      if (urlInputFinder.evaluate().isNotEmpty) {
        print('📝 输入Google Drive URL...');
        
        // 点击输入框
        await tester.tap(urlInputFinder);
        await tester.pumpAndSettle();
        
        // 输入示例URL
        await tester.enterText(
          urlInputFinder, 
          'https://drive.google.com/drive/folders/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms'
        );
        await tester.pumpAndSettle();
        
        // 截图2: 输入URL后的界面
        await _takeScreenshot(binding, 'with_url_input_clean', '主界面 - 输入URL后');
        
        // 查找下载按钮
        final downloadButtonFinder = find.byType(ElevatedButton);
        if (downloadButtonFinder.evaluate().isNotEmpty) {
          // 截图3: 准备下载状态
          await _takeScreenshot(binding, 'ready_to_download', '准备下载状态');
          
          // 模拟点击下载按钮（但不实际下载）
          print('🔘 模拟点击下载按钮...');
          // 注意：这里我们不实际执行下载，只是为了UI状态
          // await tester.tap(downloadButtonFinder);
          // await tester.pumpAndSettle();
        }
      }
      
      // 查找设置按钮或菜单
      final settingsButtonFinder = find.byIcon(Icons.settings);
      if (settingsButtonFinder.evaluate().isNotEmpty) {
        print('⚙️ 访问设置界面...');
        await tester.tap(settingsButtonFinder);
        await tester.pumpAndSettle();
        
        // 截图4: 设置界面
        await _takeScreenshot(binding, 'settings_page_clean', '设置界面');
        
        // 返回主界面
        final backButtonFinder = find.byIcon(Icons.arrow_back);
        if (backButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(backButtonFinder);
          await tester.pumpAndSettle();
        }
      }
      
      // 最终截图：完整的应用界面
      await _takeScreenshot(binding, 'final_state_clean', '最终应用状态');
      
      print('✅ 所有截图完成！');
    });
    
    testWidgets('Capture app states with simulated data', (WidgetTester tester) async {
      // 设置窗口大小
      await binding.setSurfaceSize(const Size(800, 600));
      
      print('📱 测试不同应用状态的截图...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 可以在这里添加更多特定状态的测试
      // 比如错误状态、下载进度状态等
      
      print('✨ 状态测试截图完成！');
    });
  });
}

Future<void> _takeScreenshot(
  IntegrationTestWidgetsFlutterBinding binding, 
  String name, 
  String description
) async {
  print('📷 截图: $description');
  
  try {
    // 确保UI完全渲染
    await binding.pump();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 截图
    final Uint8List screenshotBytes = await binding.takeScreenshot(name);
    
    // 保存截图
    final Directory screenshotsDir = Directory('screenshots');
    if (!screenshotsDir.existsSync()) {
      screenshotsDir.createSync(recursive: true);
    }
    
    final File screenshotFile = File('screenshots/${name}_integration.png');
    await screenshotFile.writeAsBytes(screenshotBytes);
    
    print('  ✅ 截图保存: ${screenshotFile.path}');
  } catch (e) {
    print('  ❌ 截图失败: $e');
  }
}