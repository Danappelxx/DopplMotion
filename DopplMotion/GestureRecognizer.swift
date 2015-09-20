//
//  GestureRecognizer.swift
//  DopplMotion
//
//  Created by Dan Appel on 9/19/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import Foundation

typealias Bandwidth = (left: Int, right: Int)
class GestureRecognizer {

    var bandwidth: Bandwidth! {
        didSet {
            processBandwidth()
        }
    }
    var difference: Int {
        return bandwidth.left - bandwidth.right
    }
    var bandwidthIsUnder4: Bool {
        return bandwidth.left < 4 || bandwidth.right < 4
    }
//    let possibleGestures: [Gesture]
//    let length: Double
    
    func processBandwidth() {

        if bandwidth.left > 4 && bandwidth.right > 4 {
            // stuff
        }
    }
}

/**
*  Gesture tags - more than one can apply
*/
enum Gesture {

    // general
    case Fast
    case Slow
    case Away
    case To
    
    // precise
    case Flick
    case Tap
    case DoubleTap

    // other
    case Sustained
}