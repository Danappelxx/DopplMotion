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

    var prevBlock = [Float].init(count: 1024, repeatedValue: 0)

    let smoothingTimeConstant: Float = 0.5

    var microphone: EZMicrophone!
    var player: EZAudioPlayer!
    var fft: EZAudioFFTRolling!

    let workspace = NSWorkspace.sharedWorkspace()
    var currIndex = 0

    var graphSquare: GraphSquare!

    let gestureRecognizer = GestureRecognizer()



    override func viewDidLoad() {
        super.viewDidLoad()

        self.fft = EZAudioFFTRolling(windowSize: 2048, sampleRate: 44100, delegate: self)


        let fileURL = NSBundle.mainBundle().URLForResource("20kHz", withExtension: "wav")!
//        let fileURL = NSBundle.mainBundle().URLForResource("Pretender", withExtension: "mp3")!

        self.player = EZAudioPlayer(URL: fileURL)
        self.player.shouldLoop = true
        self.player.play()
        
        self.microphone = EZMicrophone(delegate: self, startsImmediately: true)
        
        self.gestureRecognizer.delegate = self
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
        
        prevBlock = prevBlock.enumerate().map {
            (smoothingTimeConstant * $1) + (1 - smoothingTimeConstant) * (fftData.advancedBy($0).memory)
        }
        
//        for block in prevBlock {
//            smoothingTimeConstant * block + (1 - smoothingTimeConstant) * fftData
//        }
        
//        for var i = 0; i < Int(bufferSize); i++ {
        
//            prevBlock.advancedBy(i).memory = (smoothingTimeConstant * prevBlock[i]) + (1 - smoothingTimeConstant) * (fftData.advancedBy(i).memory)
            
//        }

        if fftcounter % 3 == 0 {
            
            
            self.gestureRecognizer.bandwidth = bandwidth()

            let diff = CGFloat(self.gestureRecognizer.difference)

            if diff == 0 {
                return
            }


            let amplifiedDiff = max((diff * 10) + 200, 0)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.graphSquare?.frame.size = CGSizeMake(amplifiedDiff, amplifiedDiff)
            })
        }

        fftcounter++
    }

    func bandwidth() -> (left: Int, right: Int) {
        
        let targetFrequency: Float = 20000
        let targetFrequencyWindow = 33

        let primaryTone = self.fft.indexOfFrequency(targetFrequency)
        let primaryVolume = prevBlock[primaryTone]
        
        /// to be determined
        let maxVolumeRatio: Float = 0.001
        
        var leftBandwidth = 0
        var rightBandwidth = 0
        
        var volume: Float = 0, normalizedVolume: Float = 0
        repeat {
            
            leftBandwidth++
            volume = prevBlock[primaryTone - leftBandwidth]
            normalizedVolume = volume / primaryVolume
            
        } while normalizedVolume > maxVolumeRatio && leftBandwidth < targetFrequencyWindow
        
        
        volume = 0
        normalizedVolume = 0
        repeat {
            
            rightBandwidth++
            volume = prevBlock[primaryTone + rightBandwidth]
            normalizedVolume = volume / primaryVolume
            
        } while normalizedVolume > maxVolumeRatio && rightBandwidth < targetFrequencyWindow
        
        
        return (left: leftBandwidth, right: rightBandwidth)
    }
}

extension ViewController: GestureRecognizerDelegate {
    func updatedPossibleGestures(withGestureRecognizer gestureRecognizer: GestureRecognizer, withMostLikelyCandidate mostLikelyCandidate: Gesture) {

        switch mostLikelyCandidate {
        case .Spike:
            print("spike!!!")
            launchNextAvailableApplication(currIndex)
            break
            
        default:
            print("other!")
        }
    }
}

extension ViewController {
    func launchNextAvailableApplication(index: Int) {
        
        // base case
        //        print(index, workspace.runningApplications.count)
        if index < workspace.runningApplications.count {
            let url = workspace.runningApplications[index].bundleURL
            let pathComponents = url?.pathComponents
            
            print(pathComponents)
            
            if pathComponents?.count == 3 {
                
                let applicationName = pathComponents![2]
                
                let digitIndex = applicationName.endIndex.advancedBy(-4)
                let lastThreeDigits = applicationName.substringFromIndex(digitIndex)
                
                if lastThreeDigits != ".app" && pathComponents![1] != "Applications" {
                    
                    launchNextAvailableApplication(index + 1)
                    
                } else {
                    currIndex = index + 1
                    print(currIndex)
                    workspace.launchApplication(applicationName)
                    sleep(1)
                    return
                }
            } else if pathComponents?.count >= 3 && pathComponents![pathComponents!.count - 1] == "DopplMotion.app" {
                currIndex = 0
                launchNextAvailableApplication(self.currIndex)
                return
            } else {
                launchNextAvailableApplication(index + 1)
            }
        }
        
        return
    }
}
