//
//  VisualEffects.swift
//  VoiceOpenAI
//
//

import SwiftUI

struct VisualEffects: NSViewRepresentable {
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode =  .behindWindow
        view.state = .active
        view.isEmphasized = true
        view.material = .underWindowBackground
        return view
    }
    
    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
    
    func addOpacityAnimation(view:NSView) {
        let key = "opacity"
        let animation = CABasicAnimation(keyPath: key)
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.autoreverses = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        view.layer!.add(animation, forKey: key)
    }
    
}
