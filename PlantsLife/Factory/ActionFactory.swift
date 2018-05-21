//
//  ActionFactory.swift
//  PlantsLife
//
//  Created by Sonam Dhingra on 5/20/18.
//  Copyright © 2018 Sonam Dhingra. All rights reserved.
//

import Foundation
import SceneKit


struct ActionFactory {
    
    func moveAction(to newPos: SCNVector3, with duration: TimeInterval) -> SCNAction {
        return SCNAction.move(to: newPos, duration: duration)        
    }
    
    func scaleOutAndIn(_ scaleByFactor: CGFloat, with duration: TimeInterval) -> SCNAction {
        let scaleLarger = SCNAction.scale(by: scaleByFactor, duration: duration)
        scaleLarger.timingMode = .easeOut
        let scaleSmaller = SCNAction.scale(by: -scaleByFactor, duration: duration)
        scaleSmaller.timingMode = .easeInEaseOut;
        let scaleSequence = SCNAction.sequence([scaleLarger, scaleSmaller])
        let scaleLoop = SCNAction.repeatForever(scaleSequence)
        return scaleLoop
    }
}
