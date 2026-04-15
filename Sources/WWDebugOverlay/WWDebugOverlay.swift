//
//  WWDebugOverlay.swift
//  WWDebugOverlay
//
//  Created by William.Weng on 2026/4/14.
//

import UIKit
import QuartzCore

/// 用於在畫面上疊加除錯資訊的視圖。
/// `WWDebugOverlayView` 會繪製容器邊界、水平／垂直中心線、目標框架、參考框架，
/// 並在左上角顯示相關幾何資訊，方便檢查版面配置、對齊與座標位置。
public final class WWDebugOverlayView: UIView {
    
    public var style: Style { didSet { applyStyle() }}  // 目前套用的顯示樣式。當樣式變更時，會立即重新套用到所有圖層與資訊標籤。
    
    private let overlayLayer = OverlayLayer()           // 所有的Layer
    private let infoLabel = PaddingLabel()              // 顯示除錯文字資訊的標籤。
    
    private var snapshot: Snapshot?                     // 目前的快照資料。用於描述當前要繪製的容器範圍、目標框架、參考框架及標題。
    
    /// 建立一個除錯疊加視圖。
    /// - Parameter style: 初始樣式設定，預設為 `.default`。
    public init(style: WWDebugOverlayView.Style = .default) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    /// 以指定框架建立除錯疊加視圖。
    /// - Parameter frame: 視圖初始框架。
    public override init(frame: CGRect) {
        self.style = .default
        super.init(frame: frame)
        setup()
    }
    
    /// 由 Interface Builder / NSCoder 建立除錯疊加視圖。
    /// - Parameter coder: 解碼器。
    required init?(coder: NSCoder) {
        self.style = .default
        super.init(coder: coder)
        setup()
    }
    
    /// 當子視圖重新布局時更新資訊標籤位置並重新繪製。
    public override func layoutSubviews() {
        super.layoutSubviews()
        infoLabel.frame = CGRect(x: 8, y: 8, width: min(bounds.width - 16, 320), height: 96)
        redraw()
    }
}

// MARK: - 小工具
public extension WWDebugOverlayView {
    
    /// 更新除錯視圖的快照內容並重新繪製。
    /// - Parameter snapshot: 最新的除錯快照資料。
    func update(_ snapshot: WWDebugOverlayView.Snapshot) {
        self.snapshot = snapshot
        redraw()
    }
}

// MARK: - 小工具
private extension WWDebugOverlayView {
    
    /// 初始化視圖內容與圖層配置。
    func setup() {
        
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        overlayLayer.append(to: layer)
                
        infoLabel.numberOfLines = 0
        infoLabel.layer.cornerRadius = 8
        infoLabel.layer.masksToBounds = true
        addSubview(infoLabel)
        
        applyStyle()
    }
    
    /// 將目前樣式套用到所有圖層與資訊標籤。
    func applyStyle() {
        
        overlayLayer.drawSetting(with: style)
        
        infoLabel.font = style.infoFont
        infoLabel.textColor = style.color.infoText
        infoLabel.backgroundColor = style.color.infoBackground
        infoLabel.contentInset = style.infoInsets
        
        redraw()
    }
    
    /// 根據目前快照資料重新繪製所有除錯圖層與資訊文字。
    func redraw() {
        
        let containerBounds = snapshot?.containerBounds ?? bounds
        
        overlayLayer.frameSetting(bounds)
        overlayLayer.panelBorder.path = UIBezierPath(rect: containerBounds.insetBy(dx: 0.5, dy: 0.5)).cgPath
        overlayLayer.horizontalCenter.path = UIBezierPath.horizontalPath(by: containerBounds).cgPath
        overlayLayer.verticalCenter.path = UIBezierPath.verticalPath(by: containerBounds).cgPath
        
        updateBorder(overlayLayer.targetBorder, frame: snapshot?.targetFrame, inset: 0.5)
        updateBorder(overlayLayer.referenceBorder, frame: snapshot?.referenceFrame, inset: 0.5)
        updateInformation(with: snapshot, frame: containerBounds)
    }
    
    /// 更新除錯資訊面板的文字內容。
    /// - Parameters:
    ///   - snapshot: 目前的除錯快照，可為 nil。
    ///   - frame: 容器視圖的框架，用來顯示 `container.midY`。
    func updateInformation(with snapshot: Snapshot?, frame: CGRect) {
        
        let title = snapshot?.title ?? "WWDebugOverlay"
        
        let targetMid = snapshot?.targetFrame.map { targetFrame in
            "(\(targetFrame.midX.debugString), \(targetFrame.midY.debugString))"
        } ?? "-"
        
        let refMidY = snapshot?.referenceFrame.map { $0.midY.debugString } ?? "-"
        
        infoLabel.text = """
        \(title)
        container.midY: \(frame.midY.debugString)
        target.center: \(targetMid)
        reference.midY: \(refMidY)
        """
    }
    
    /// 更新邊框圖層的顯示狀態與路徑。
    /// - Parameters:
    ///   - layer: 要更新的 `CAShapeLayer`。
    ///   - frame: 框架矩形，如果為 nil 則隱藏圖層。
    ///   - inset: 內縮距離，用於產生清晰的邊框效果（通常為 `lineWidth / 2`）。
    func updateBorder(_ layer: CAShapeLayer, frame: CGRect?, inset: CGFloat) {
        layer.isHidden = (frame == nil)
        layer.path = frame.map { UIBezierPath(rect: $0.insetBy(dx: inset, dy: inset)).cgPath }
    }
}

