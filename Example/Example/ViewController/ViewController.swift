//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2026/4/14.
//

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
