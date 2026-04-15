//
//  WWDebugOverlay.swift
//  Model
//
//  Created by William.Weng on 2026/4/14.
//

import UIKit

// MARK: - 公開模型
public extension WWDebugOverlayView {
    
    /// 用於描述除錯視圖的狀態快照，主要用來保存容器區域及標的／參考框架的位置信息。
    struct Snapshot {
        
        public var containerBounds: CGRect
        public var targetFrame: CGRect?
        public var referenceFrame: CGRect?
        public var title: String?
        
        /// 建立一個除錯視圖快照。
        /// - Parameters:
        ///   - containerBounds: 視圖所在容器的邊界區域。
        ///   - targetFrame: 所觀察的目標框架。
        ///   - referenceFrame: 參考框架 (例如對齊基準)。
        ///   - title: 顯示文字，可用於識別快照來源。
        public init(containerBounds: CGRect, targetFrame: CGRect? = nil, referenceFrame: CGRect? = nil, title: String? = nil) {
            self.containerBounds = containerBounds
            self.targetFrame = targetFrame
            self.referenceFrame = referenceFrame
            self.title = title
        }
    }
    
    /// 定義除錯疊加視圖所使用的顏色配置，用於集中管理各種邊框、中心線與資訊面板的顯示色彩。
    struct Color {
        
        /// 預設樣式設定。
        public static let `default` = Color(
            panelBorder: .systemRed,
            horizontalCenter: UIColor.systemBlue.withAlphaComponent(0.9),
            verticalCenter: UIColor.systemTeal.withAlphaComponent(0.9),
            targetBorder: .systemGray,
            referenceBorder: .systemGray,
            infoText: .label,
            infoBackground: .secondarySystemBackground
        )
        
        public var panelBorder: UIColor
        public var horizontalCenter: UIColor
        public var verticalCenter: UIColor
        public var targetBorder: UIColor
        public var referenceBorder: UIColor
        public var infoText: UIColor
        public var infoBackground: UIColor
        
        /// 建立一組除錯疊加視圖的顏色設定。
        /// - Parameters:
        ///   - panelBorder: 容器面板的邊框顏色。
        ///   - horizontalCenter: 水平中心線的顏色。
        ///   - verticalCenter: 垂直中心線的顏色。
        ///   - targetBorder: 目標框架的邊框顏色。
        ///   - referenceBorder: 參考框架的邊框顏色。
        ///   - infoText: 資訊文字的顏色。
        ///   - infoBackground: 資訊面板的背景顏色。
        public init(panelBorder: UIColor, horizontalCenter: UIColor, verticalCenter: UIColor, targetBorder: UIColor, referenceBorder: UIColor, infoText: UIColor, infoBackground: UIColor) {
            self.panelBorder = panelBorder
            self.horizontalCenter = horizontalCenter
            self.verticalCenter = verticalCenter
            self.targetBorder = targetBorder
            self.referenceBorder = referenceBorder
            self.infoText = infoText
            self.infoBackground = infoBackground
        }
    }
    
    /// 定義除錯疊加視圖的視覺樣式設定，可用於自訂顏色、線條樣式及文字資訊的外觀。
    struct Style {
        
        /// 預設樣式設定。
        public static let `default` = Style(
            color: Color(
                panelBorder: .systemRed,
                horizontalCenter: UIColor.systemBlue.withAlphaComponent(0.9),
                verticalCenter: UIColor.systemTeal.withAlphaComponent(0.9),
                targetBorder: .systemGreen,
                referenceBorder: .systemYellow,
                infoText: .white,
                infoBackground: UIColor.black.withAlphaComponent(0.58)
            ),
            lineWidth: 1,
            dashPattern: [6, 4],
            infoFont: .monospacedSystemFont(ofSize: 10, weight: .regular),
            infoInsets: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        )
            
        public var color: Color
        public var lineWidth: CGFloat
        public var dashPattern: [NSNumber]
        public var infoFont: UIFont
        public var infoInsets: UIEdgeInsets
        
        /// 建立一個樣式設定。
        /// - Parameters:
        ///   - color: 除錯疊加視圖的顏色配置。
        ///   - lineWidth: 線條寬度。
        ///   - dashPattern: 虛線樣式設定。
        ///   - infoFont: 資訊文字字型。
        ///   - infoInsets: 資訊面板內距。
        public init(color: Color, lineWidth: CGFloat, dashPattern: [NSNumber], infoFont: UIFont, infoInsets: UIEdgeInsets) {
            self.color = color
            self.lineWidth = lineWidth
            self.dashPattern = dashPattern
            self.infoFont = infoFont
            self.infoInsets = infoInsets
        }
    }
}

// MARK: - 內部模型
extension WWDebugOverlayView {
    
    /// 繪圖圖層
    struct OverlayLayer {
        
        let panelBorder: CAShapeLayer = .init()         // 容器外框圖層
        let horizontalCenter: CAShapeLayer = .init()    // 水平中心線圖層
        let verticalCenter: CAShapeLayer = .init()      // 垂直中心線圖層
        let targetBorder: CAShapeLayer = .init()        // 目標框架外框圖層
        let referenceBorder: CAShapeLayer = .init()     // 參考框架外框圖層
        
        func append(to layer: CALayer) {
            [panelBorder, horizontalCenter, verticalCenter, targetBorder, referenceBorder].forEach {
                $0.fillColor = nil
                layer.addSublayer($0)
            }
        }
        
        /// 繪圖的顏色 / 線寬設定
        /// - Parameter style: Style
        func drawSetting(with style: Style) {
            
            panelBorder.strokeColor = style.color.panelBorder.cgColor
            panelBorder.fillColor = UIColor.clear.cgColor
            panelBorder.lineWidth = style.lineWidth
            
            horizontalCenter.strokeColor = style.color.horizontalCenter.cgColor
            horizontalCenter.fillColor = UIColor.clear.cgColor
            horizontalCenter.lineWidth = style.lineWidth
            horizontalCenter.lineDashPattern = style.dashPattern
            
            verticalCenter.strokeColor = style.color.verticalCenter.cgColor
            verticalCenter.fillColor = UIColor.clear.cgColor
            verticalCenter.lineWidth = style.lineWidth
            verticalCenter.lineDashPattern = style.dashPattern
            
            targetBorder.strokeColor = style.color.targetBorder.cgColor
            targetBorder.fillColor = UIColor.clear.cgColor
            targetBorder.lineWidth = style.lineWidth
            
            referenceBorder.strokeColor = style.color.referenceBorder.cgColor
            referenceBorder.fillColor = UIColor.clear.cgColor
            referenceBorder.lineWidth = style.lineWidth
        }
        
        /// 尺寸設定
        /// - Parameter frame: CGRect
        func frameSetting(_ frame: CGRect) {
            [panelBorder, horizontalCenter, verticalCenter, targetBorder, referenceBorder].forEach {
                $0.frame = frame
            }
        }
    }
}

// MARK: - 自訂模型
extension WWDebugOverlayView {
    
    /// 具有內距能力的 `UILabel`。用於在除錯資訊面板中提供較佳的文字可讀性，讓文字不要貼邊。
    final class PaddingLabel: UILabel {
        
        var contentInset = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)   // 文字內容的內距設定。
        
        /// 以包含內距的區域繪製文字。
        /// - Parameter rect: 原始可繪製區域。
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: contentInset))
        }
        
        /// 回傳考慮內距後的固有內容大小。
        override var intrinsicContentSize: CGSize {
            
            let size = super.intrinsicContentSize
            let newSize = CGSize(width: size.width + contentInset.left + contentInset.right, height: size.height + contentInset.top + contentInset.bottom)
            
            return newSize
        }
    }
}
