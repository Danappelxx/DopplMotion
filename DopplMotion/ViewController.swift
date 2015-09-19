//
//  ViewController.swift
//  DopplMotion
//
//  Created by Dan Appel on 9/19/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import Cocoa
import EZAudio

class ViewController: NSViewController {

    var microphone: EZMicrophone!
    var player: EZAudioPlayer!
    
    @IBOutlet weak var buffer: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)

        let fileURL = NSBundle.mainBundle().URLForResource("20kHz", withExtension: "wav")!
//        let fileURL = NSBundle.mainBundle().URLForResource("Pretender", withExtension: "mp3")!

        self.player = EZAudioPlayer(URL: fileURL, delegate: self)
        self.player.shouldLoop = true
    }

    @IBAction func didTapButton(sender: NSButton) {
        player.isPlaying ? player.pause() : player.play()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ViewController: EZAudioPlayerDelegate {
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
//        print("updated")
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
//        print("reached end")
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
//        print("played audio")
    }
}

extension ViewController: EZMicrophoneDelegate {
    func microphone(microphone: EZMicrophone!, changedPlayingState isPlaying: Bool) {
        print(isPlaying)
    }

    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {


        let buffer2D = twoDimensionalUnsafeMutablePointerOfFloatsToTwoDimensionalArrayOfFloats(buffer, withOneDSize: Int(bufferSize))

        let bufferAverage = buffer2D[0].filter { $0 != 0 }.reduce(0, combine: +) / Float(buffer2D[0].count)
        self.buffer.stringValue = "\(bufferAverage)"
//        print(bufferAverage)
        usleep(0250000)

        buffer.destroy()
    }
}


func twoDimensionalUnsafeMutablePointerOfFloatsToTwoDimensionalArrayOfFloats(twoDPointer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withOneDSize oneDSize: Int) -> [[Float]] {


    var arr1 = [[Float]]()
    var advancer1 = 0
    while twoDPointer.advancedBy(advancer1).memory != nil {

        let oneDPointer = twoDPointer.advancedBy(advancer1).memory

        var arr2 = [Float]()
        var advancer2 = 0


        while advancer2 < oneDSize {

            let curr = oneDPointer.advancedBy(advancer2).memory

            arr2.append(curr)

            advancer2++
        }

        arr1.append(arr2)

        advancer1++
    }

    return arr1
    
}





import Accelerate

// MARK: Fast Fourier Transform

public func fft(input: [Float]) -> [Float] {
    


    var real = [Float](input)
    var imaginary = [Float](count: input.count, repeatedValue: 0.0)
    var splitComplex = DSPSplitComplex(realp: &real, imagp: &imaginary)

    let length = vDSP_Length(floor(log2(Float(input.count))))
    let radix = FFTRadix(kFFTRadix2)
    let weights = vDSP_create_fftsetup(length, radix)
    vDSP_fft_zip(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))

    var magnitudes = [Float](count: input.count, repeatedValue: 0.0)
    vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(input.count))

    var normalizedMagnitudes = [Float](count: input.count, repeatedValue: 0.0).map { sqrt($0) }
    vDSP_vsmul(magnitudes, 1, [2.0 / Float(input.count)], &normalizedMagnitudes, 1, vDSP_Length(input.count))

    vDSP_destroy_fftsetup(weights)

    return normalizedMagnitudes
}