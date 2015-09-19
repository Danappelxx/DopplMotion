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
    var fft: EZAudioFFTRolling!

    var graphSquare: GraphSquare!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.fft = EZAudioFFTRolling(windowSize: 2048, sampleRate: 44100, delegate: self)


        let fileURL = NSBundle.mainBundle().URLForResource("20kHz", withExtension: "wav")!
//        let fileURL = NSBundle.mainBundle().URLForResource("Pretender", withExtension: "mp3")!

        self.player = EZAudioPlayer(URL: fileURL)
        self.player.shouldLoop = true
        self.player.play()

        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)

    }

    override func viewDidAppear() {
        super.viewDidAppear()

        let origin = CGPointMake(self.view.frame.width / 2 - 20, self.view.frame.height / 2)
        let size = CGSizeMake(200, 200)
        let rect = NSRect(origin: origin, size: size)

        self.graphSquare = GraphSquare(frame: rect)
        self.graphSquare.originalFrame = self.graphSquare.frame

        self.view.addSubview(self.graphSquare)
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

extension ViewController: EZMicrophoneDelegate {
    func microphone(microphone: EZMicrophone!, changedPlayingState isPlaying: Bool) {
//        print(isPlaying)
    }

    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {


        // apply Hamming's window to each element of each channel
        var incrementor1 = 0
        while incrementor1 < Int(numberOfChannels) {

            let channel = buffer.advancedBy(incrementor1).memory

            var incrementor2 = 0
            while incrementor2 < Int(bufferSize) {

                let curr = channel.advancedBy(incrementor2).memory

                let newCurr = curr * EZAudioFFT.window(index: incrementor2, numValues: Int(bufferSize))

                channel.advancedBy(incrementor2).initialize(newCurr)
                incrementor2++
            }
            incrementor1++
        }

        self.fft.computeFFTWithBuffer(buffer.memory, withBufferSize: bufferSize)
    }
}

var fftcounter = 0
extension ViewController: EZAudioFFTDelegate {
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {

        if fftcounter % 3 == 0 {

            let bandwidth = self.fft.bandwidth()
            let diff = CGFloat(bandwidth.left - bandwidth.right)

            let amplifiedDiff = max( (diff * 10) + 200, 0 )
            
            dispatch_async(dispatch_get_main_queue()) {
                self.graphSquare?.frame.size = CGSizeMake(amplifiedDiff, amplifiedDiff)
            }
        }

        fftcounter++
    }
}