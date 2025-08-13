import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    
    // 设置窗口大小以避免滚动条
    self.setContentSize(NSSize(width: 700, height: 850))
    self.center()
    
    // 设置窗口最小尺寸
    self.minSize = NSSize(width: 600, height: 700)
    
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
