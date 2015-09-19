//
//  GestureRecognizer.swift
//  DopplMotion
//
//  Created by Dan Appel on 9/19/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import Foundation

class GestureRecognizer {

    let velocity: Double
    let direction: Direction
//    let possibleGestures: [Gesture]
//    let length: Double


    init(velocity: Double, direction: Direction) {

        self.velocity = velocity
        self.direction = direction

        // insert complicated stuff here
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
    

//    Fast/Slow - Away/To
//    Tap
//    Double Tap
//    Away + To at Same Time
//    Sustained (walk up to it)
}

/**
*  Direction the gesture came from
*/
enum Direction {
    case Far
    case Close
}