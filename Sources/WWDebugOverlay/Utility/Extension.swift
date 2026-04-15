//
//  WWDebugOverlay.swift
//  Extension
//
//  Created by William.Weng on 2026/4/14.
//

import UIKit
import ObjectiveC

// MARK: - CGFloat
extension CGFloat {
    
    /// 將浮點數格式化為除錯顯示用字串，保留一位小數。
    var debugString: String { String(format: "%.1f", self) }
}

// MARK: - UIBezierPath
extension UIBezierPath {
    
    /// 建立容器的水平中心線路徑。這條線會從指定框架的左邊緣 (`minX`) 出發，經過中點 (`midY`)，畫到右邊緣 (`maxX`)，用於視覺化顯示框架的水平中心位置。
    /// - Parameter frame: 容器框架。
    /// - Returns: 水平中心線的 `UIBezierPath`。
    static func horizontalPath(by frame: CGRect) -> Self {
        
        let horizontalPath = Self()
        
        horizontalPath.move(to: CGPoint(x: frame.minX, y: frame.midY))
        horizontalPath.addLine(to: CGPoint(x: frame.maxX, y: frame.midY))
        
        return horizontalPath
    }
    
    /// 建立容器的垂直中心線路徑。這條線會從指定框架的上邊緣 (`minY`) 出發，經過中點 (`midX`)，畫到下邊緣 (`maxY`)，用於視覺化顯示框架的垂直中心位置。
    /// - Parameter frame: 容器框架。
    /// - Returns: 垂直中心線的 `UIBezierPath`。
    static func verticalPath(by frame: CGRect) -> Self {
        
        let verticalPath = Self()
        verticalPath.move(to: CGPoint(x: frame.midX, y: frame.minY))
        verticalPath.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))

        return verticalPath
    }
}

// MARK: - UIView
public extension UIView {
        
    /// 顯示或更新此視圖的除錯疊加層，若先前已有疊加層，則更新其樣式；否則建立新的疊加視圖。
    /// - Parameters:
    ///   - targetFrame: 要標示的目標框架 (可選)，通常為子視圖或元素的區域。
    ///   - referenceFrame: 用於比較的參考框架 (可選)，例如對齊基準或容器範圍。
    ///   - title: 顯示於疊加層的文字，方便識別。
    ///   - style: 疊加層的樣式設定，預設為 `.default`。
    func wwShowDebugOverlay(targetFrame: CGRect? = nil, referenceFrame: CGRect? = nil, title: String? = nil, style: WWDebugOverlayView.Style = .default) {
        
        let overlay: WWDebugOverlayView
        
        // 若已有除錯視圖，更新樣式；否則建立新的 Overlay。
        if let existing = debugOverlayView {
            overlay = existing
            overlay.style = style
        } else {
            overlay = WWDebugOverlayView(style: style)
            overlay.frame = bounds
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(overlay)
            debugOverlayView = overlay
        }
        
        // 確保除錯層位於最上層。
        bringSubviewToFront(overlay)
        
        // 更新疊加層內容（包含邊界與目標框架）。
        overlay.update(
            WWDebugOverlayView.Snapshot(containerBounds: bounds, targetFrame: targetFrame, referenceFrame: referenceFrame, title: title)
        )
    }
    
    /// 更新已存在的除錯疊加層，若尚未顯示除錯層則無動作。
    /// - Parameters:
    ///   - targetFrame: 更新的目標框架。
    ///   - referenceFrame: 更新的參考框架。
    ///   - title: 更新顯示的標題文字。
    func wwUpdateDebugOverlay(targetFrame: CGRect? = nil, referenceFrame: CGRect? = nil, title: String? = nil) {
        
        guard let overlay = debugOverlayView else { return }
        
        overlay.update(
            WWDebugOverlayView.Snapshot(containerBounds: bounds, targetFrame: targetFrame, referenceFrame: referenceFrame, title: title)
        )
    }
    
    /// 移除並釋放此視圖的除錯疊加層。
    func wwHideDebugOverlay() {
        debugOverlayView?.removeFromSuperview()
        debugOverlayView = nil
    }
}

// MARK: - UIView
private extension UIView {
    
    /// 用於儲存除錯疊加視圖的關聯鍵。
    struct AssociatedKeys {
        static var debugOverlayKey: UInt8 = 0
    }
    
    /// 存取與該視圖關聯的 `WWDebugOverlayView`，以 Objective‑C  Runtime 的關聯物件方式保存。
    var debugOverlayView: WWDebugOverlayView? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.debugOverlayKey) as? WWDebugOverlayView }
        set { objc_setAssociatedObject(self, &AssociatedKeys.debugOverlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

