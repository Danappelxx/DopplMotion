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
    
    func bandwidth() -> (left: Int, right: Int) {

        let targetFrequency: Float = 20000
        let targetFrequencyWindow = 33

        let primaryTone = self.indexOfFrequency(targetFrequency)
        let primaryVolume = fftData.advancedBy(primaryTone).memory

        /// to be determined
        let maxVolumeRatio: Float = 0.001

        var leftBandwidth = 0
        var rightBandwidth = 0

        var volume: Float = 0, normalizedVolume: Float = 0
        repeat {

            leftBandwidth++
            volume = fftData.advancedBy(primaryTone - leftBandwidth).memory
            normalizedVolume = volume / primaryVolume

        } while normalizedVolume > maxVolumeRatio && leftBandwidth < targetFrequencyWindow


        volume = 0
        normalizedVolume = 0
        repeat {

            rightBandwidth++
            volume = fftData.advancedBy(primaryTone + rightBandwidth).memory
            normalizedVolume = volume / primaryVolume

        } while normalizedVolume > maxVolumeRatio && rightBandwidth < targetFrequencyWindow


        return (left: leftBandwidth, right: rightBandwidth)
    }

    func indexOfFrequency(frequency: Float) -> Int {
        let nyquist = self.sampleRate / 2
        return Int((frequency / nyquist) * (2048 / 2))
    }

    /// Of type "Hamming" - the key to making the motion detection smooth
    class func window(index n: Int, numValues N: Int) -> Float {
        return Float( 0.54 - ( 0.46 * cos( (2 * M_PI * Double(n)) / (Double(N) - 1) ) ) )
    }
}
