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
    
    init(delegate: GestureRecognizerDelegate? = nil) {
        self.delegate = delegate
    }

    var spikeCounter = 0
    var delegate: GestureRecognizerDelegate?
    var possibleGestures = [Gesture]()
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
    
    func processBandwidth() {

        if bandwidth.left > 14 || bandwidth.right > 14 {

            if spikeCounter >= 4 {
                spikeCounter = 0

                self.possibleGestures = [.Spike]
                self.delegate?.updatedPossibleGestures(withGestureRecognizer: self, withMostLikelyCandidate: .Spike)

            } else {

                spikeCounter++
            }
        } else {

            spikeCounter = 0
        }
    }
}

protocol GestureRecognizerDelegate {
    func updatedPossibleGestures(withGestureRecognizer gestureRecognizer: GestureRecognizer, withMostLikelyCandidate mostLikelyCandidate: Gesture)
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
    case Spike

    // other
    case Sustained
}