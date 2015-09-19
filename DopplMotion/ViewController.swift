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

        self.player = EZAudioPlayer(URL: fileURL, delegate: self)
        self.player.shouldLoop = true
        self.player.play()

        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)

    }

    override func viewDidAppear() {
        super.viewDidAppear()

        let origin = CGPointMake(self.view.frame.width / 2 - 20, self.view.frame.height / 2)
        let size = CGSizeMake(75, 75)
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


        self.fft.computeFFTWithBuffer(buffer.memory, withBufferSize: bufferSize)
    }
}

var fftcounter = 0
extension ViewController: EZAudioFFTDelegate {
    func fft(fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
//        print("updated fft")


//        var incrementor = 0
//        while incrementor < Int(bufferSize) {
//
//            let curr = fftData.advancedBy(incrementor).memory
//
//            print(curr * 10000000)
//
//            incrementor++
//        }

//        print("done")

        if fftcounter % 5 == 0 {
            
            let bandwidth = self.fft.bandwidth()
            let diff = CGFloat(bandwidth.left - bandwidth.right)
            let amplifiedDiff = diff + 75
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.graphSquare?.frame.size = CGSizeMake(amplifiedDiff, amplifiedDiff)
            }
        }
        
        fftcounter++
        
        

//        print(diff)
    }
}


class GraphSquare: NSView {
    override func drawRect(dirtyRect: NSRect) {

        NSColor.greenColor().setFill()
        NSRectFill(self.bounds)
    }

    var originalFrame: CGRect?
}




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
}



