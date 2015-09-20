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
    var bandwidth: Bandwidth!
    var lastDirection = Direction.None

    var difference: Int {
        return bandwidth.left - bandwidth.right
    }
    var bandwidthIsUnder4: Bool {
        return bandwidth.left < 4 || bandwidth.right < 4
    }
    
    func update(bandwidth: Bandwidth) {
        
        self.bandwidth = bandwidth

        // print("\(bandwidth.left), \(bandwidth.right)")
        if bandwidth.left > 14 { //up

            if lastDirection != Direction.Away {
                spikeCounter = 0
                lastDirection = Direction.Away
                return
            }
            
            if spikeCounter == 4 {
                spikeCounter = 0

                self.possibleGestures = [.Spike, .Fast, .Away]
                self.delegate?.updatedPossibleGestures(withGestureRecognizer: self, withPrimaryCandidate: .Spike)

            } else {

                spikeCounter++
            }

        } else if bandwidth.right > 12 { //down
            
            if lastDirection != Direction.To {
                spikeCounter = 0
                lastDirection = Direction.To
                return
            }
            
            if spikeCounter == 4 {
                spikeCounter = 0
                
                self.possibleGestures = [.Drop, .Fast, .To]
                self.delegate?.updatedPossibleGestures(withGestureRecognizer: self, withPrimaryCandidate: .Drop)
                
            } else {
                
                spikeCounter++
            }

        } else {
            spikeCounter = 0
        }
    }
}

protocol GestureRecognizerDelegate {
    func updatedPossibleGestures(withGestureRecognizer gestureRecognizer: GestureRecognizer, withPrimaryCandidate primaryCandidate: Gesture)
}

enum Direction {
    case To
    case Away

    // only for initialization
    case None
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
    
    // up & down
    case Spike // also .Fast, .Away
    case Drop // also .Fast, .To

    // other
    case Sustained
}
