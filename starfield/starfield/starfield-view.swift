//
//  starfield-view.swift
//  starfield
//
//  Created by Hugh Parsons on 3/06/23.
//

import Foundation
import ScreenSaver

class StarfieldView: ScreenSaverView {
    private var stars: [Star] = [];

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        self.stars = (0...1000).map { _ in Star() };
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        // Draw a single frame in this function
        drawBackground(.black)
        let context = NSGraphicsContext.current?.cgContext;
        context?.setShouldAntialias(true)
        for star in self.stars {
            star.render();
        }
    }
    
    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        // Update the "state" of the screensaver in this function
        for star in self.stars {
            star.update();
        }

        setNeedsDisplay(bounds)
    }

}


func polarToCartesian(r: Double, theta: Double) -> (Double, Double) {
    let x = r * cos(theta);
    let y = r * sin(theta);
    return (x, y);
}

func scaleToScreensize(x: Double, y: Double) -> (Double, Double) {
    let screen_width = Double(NSScreen.main?.frame.width ?? 0);
    let screen_height = Double(NSScreen.main?.frame.height ?? 0);
    
    let x = (x * screen_width) + (screen_width / 2);
    let y = (y * screen_height) + (screen_height / 2);
    
    return (x, y);
}

class Star {
    private var theta: Double = .zero;
    private var r: Double = .zero;
    private var prev_r: Double = .zero;
    
    private var t: Double = .zero;
//    private var color;
    
    init() {
        self.initialise();
    }
    
    func initialise() {
        self.theta = Double.random(in: .zero ... 2 * Double.pi);
        self.r = Double.random(in: .zero ... 1.0);
        self.prev_r = self.r;
        self.t = 1e-7;
    }
    
    
    func update() {
        self.prev_r = self.r;
        
        self.r = self.r + self.t;
        self.t *= 1 + 0.05 + (self.r * 0.35);
        
        if (self.prev_r > 1.0) {
            self.initialise();
        }
    }
    
   func render() {
        let (_x, _y) = polarToCartesian(r: self.r, theta: self.theta)
        let (x, y) = scaleToScreensize(x: _x, y: _y);
        let (_prev_x, _prev_y) = polarToCartesian(r: self.prev_r, theta: self.theta);
        let (prev_x, prev_y) = scaleToScreensize(x: _prev_x, y: _prev_y);
        
        let context = NSGraphicsContext.current?.cgContext;
        context?.setLineWidth(0.5);
        context?.setStrokeColor(NSColor.white.cgColor);
        context?.move(to: CGPoint(x: prev_x, y: prev_y));
        context?.addLine(to: CGPoint(x: x, y: y));
        context?.strokePath();
   }

    
}
