//
//  SCNNode+Convenience.swift
//  PlantsLife
//
//  Created by Sonam Dhingra on 5/20/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    @discardableResult
    func addMorphingAnimation(morpherIndex: Int = 0,
                                     autoreverses: Bool = false,
                                     duration: CFTimeInterval = 1.0,
                                     repeatCount: Float = Float.infinity,
                                     fromValue: Float = 0,
                                     newValue: Float,
                                     removedOnCompletion: Bool = true) -> CAAnimation {
        let morpher = CABasicAnimation(keyPath: "morpher.weights[\(morpherIndex)]")
        morpher.fromValue = fromValue
        morpher.toValue = newValue
        morpher.autoreverses = autoreverses
        morpher.repeatCount = repeatCount
        morpher.duration = duration
        morpher.isRemovedOnCompletion = removedOnCompletion
        morpher.fillMode = kCAFillModeForwards
        self.addAnimation(morpher, forKey: "morph")
        
        return morpher
    }
    
    @discardableResult
    func fade(from startVal: Float, to toVal: Float, with duration: CFTimeInterval, should autoReverse: Bool = false, with repeatCount: Float = 0.0) -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = startVal
        animation.toValue = toVal
        animation.duration = duration
        animation.autoreverses = autoReverse
        animation.repeatCount = repeatCount
        self.addAnimation(animation, forKey: "fade")
        
        return animation
    }
}
