# WWDebugOverlay

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-13.0](https://img.shields.io/badge/iOS-13.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWDebugOverlay) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## 🎉 [相關說明](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/運用-uibezierpath-繪製形-3c858e194676)

- A lightweight UIKit debug [overlay](https://developer.apple.com/documentation/uikit/uibezierpath) that visualizes view bounds, center lines, target frames, and reference frames. Ideal for layout debugging, alignment validation, and frame inspection.
- 輕量級 UIKit 除錯疊加層，用於[視覺化](https://medium.com/彼得潘的-swift-ios-app-開發教室/筆記-運用uibezierpath-cashapelayer練習簡易圖形-d292dada1de)顯示視圖邊界、中心線、目標框架與參考框架。完美適用於版面除錯、對齊驗證與框架檢查。

## 🧩 [效果示意](https://peterpanswift.github.io/iphone-bezels/)

![](https://github.com/user-attachments/assets/39350d30-b1cf-41c5-b103-886fd66c1b56)

https://github.com/user-attachments/assets/4d5c0204-b1e3-411c-99e7-9ffa7533ab0a

<div align="center">

**⭐ 覺得好用就給個 Star 吧！**

</div>

## ✨ 功能特色

- 🟥 容器邊界視覺化
- ➖ 水平/垂直中心線（虛線）
- 🟩 目標框架高亮標示
- 🟨 參考框架高亮標示
- 📊 座標資訊面板與標題
- 🎨 完全可自訂的顏色、字型、線條樣式
- 🔗 簡單的 `UIView` 擴充 API
- 📱 自動調整大小支援

## 📦 [安裝方式](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)

使用 **Swift Package Manager (SPM)**：

```swift
dependencies: [
    .package(url: "https://github.com/William-Weng/WWDebugOverlay.git", from: "1.0.0")
]
```

## 🧲 內部方法

以下函式為內部使用，一般情況下不需直接呼叫：

| 函式名稱 | 說明 |
|-----------|------|
| `wwShowDebugOverlay(targetFrame:referenceFrame:title:)` | 顯示除錯疊加層 |
| `wwUpdateDebugOverlay(targetFrame:referenceFrame:)` | 更新（版面變更） |
| `wwHideDebugOverlay()` | 隱藏 |

## 💡 完整範例

```swift
import UIKit
import WWDebugOverlay

final class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var timer: Timer?
    private var direction: CGFloat = 1
    private var movingX: CGFloat = 40
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layoutIfNeeded()
        showDebugOverlay()
        startMovingImageView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDebugOverlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        timer = nil
        view.wwHideDebugOverlay()
    }
}

private extension ViewController {
    
    func startMovingImageView() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            
            guard let this = self else { return }
            
            let maxX = this.view.bounds.width - this.imageView.bounds.width - 40
            this.movingX += 20 * this.direction
            
            defer {
                UIView.animate(withDuration: 0.25) { this.imageView.frame.origin.x = this.movingX }
                this.updateDebugOverlay()
            }
            
            if (this.movingX >= maxX) { this.movingX = maxX; this.direction = -1; return }
            if (this.movingX <= 40) { this.movingX = 40; this.direction = 1; return }
        }
    }
    
    func showDebugOverlay() {
        
        view.wwShowDebugOverlay(
            targetFrame: imageView.frame,
            referenceFrame: view.bounds,
            title: "Image View Moving Demo"
        )
    }
    
    func updateDebugOverlay() {
        
        view.wwUpdateDebugOverlay(
            targetFrame: imageView.frame,
            referenceFrame: view.bounds,
            title: "Image View Moving Demo"
        )
    }
}
```

## 🎨 自訂樣式

### 自訂樣式

```swift
let customStyle = WWDebugOverlayView.Style(
    panelBorderColor: .systemRed,
    horizontalCenterColor: .systemBlue.withAlphaComponent(0.8),
    verticalCenterColor: .systemTeal,
    targetBorderColor: .systemGreen,
    referenceBorderColor: .systemOrange,
    infoTextColor: .white,
    infoBackgroundColor: UIColor.black.withAlphaComponent(0.7),
    lineWidth: 1.5,
    dashPattern: ,
    infoFont: .monospacedSystemFont(ofSize: 11, weight: .medium),
    infoInsets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
)

view.wwShowDebugOverlay(
    targetFrame: targetView.frame,
    style: customStyle
)
```

### 預設顏色對照表

| 元素 | 預設顏色 |
|------|----------|
| 容器邊框 | `systemRed` |
| 水平中心線 | `systemBlue` (90% 透明度) |
| 垂直中心線 | `systemTeal` (90% 透明度) |
| 目標框架 | `systemGreen` |
| 參考框架 | `systemYellow` |
| 資訊文字 | `white` |
| 資訊背景 | `black` (58% 透明度) |

## 📱 最佳實踐

✅ **建議：**
- 在 `viewDidLayoutSubviews()` 中呼叫 `wwupdateDebugOverlay()`
- 用於 Auto Layout 除錯流程
- 依應用程式設計系統自訂顏色
- 出貨前移除疊加層 (`wwHideDebugOverlay()`)

❌ **避免：**
- 版面完成後忘記更新框架
- 在正式版本留下疊加層
- 與 UIKit Snapshot Testing 一起使用（會干擾視圖層次）

## 🎯 適用場景

- 🔍 **Auto Layout 驗證** - 檢查約束結果
- 🎯 **框架對齊** - 驗證按鈕/標籤位置
- 📐 **安全區域除錯** - 容器邊界檢查
- 🧪 **動畫框架追蹤** - 視覺化框架變更
- 👥 **元件定位** - 函式庫/元件驗證

