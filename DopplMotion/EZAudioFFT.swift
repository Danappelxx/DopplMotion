//
//  EZAudioFFT.swift
//  DopplMotion
//
//  Created by Dan Appel on 9/19/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import Foundation
import EZAudio


extension EZAudioFFT {

    func indexOfFrequency(frequency: Float) -> Int {
        let nyquist = self.sampleRate / 2
        return Int((frequency / nyquist) * (2048 / 2))
    }
    
    var nyquist: Float {
        return self.sampleRate / 2
    }
    
    /// Of type "Hamming"
    class func window(index n: Int, numValues N: Int) -> Float {
        return Float( 0.54 - ( 0.46 * cos( (2 * M_PI * Double(n)) / (Double(N) - 1) ) ) )
    }
}
