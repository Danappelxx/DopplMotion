//
//  ViewController.swift
//  DopplMotion
//
//  Created by Dan Appel on 9/19/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import Cocoa
import EZAudio
import AppKit

class ViewController: NSViewController {

    var prevBlock = [Float].init(count: 1024, repeatedValue: 0)

    let smoothingTimeConstant: Float = 0.5
    var testCount: Int = 0
    var testDiff: CGFloat = 0.0
    
    var microphone: EZMicrophone!
    var player: EZAudioPlayer!
    var fft: EZAudioFFTRolling!
    
    @IBOutlet weak var spikeCheckbox: NSButton!
    @IBOutlet weak var dropCheckbox: NSButton!
    @IBOutlet weak var tapCheckbox: NSButton!

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
        
//        self.launchMultitask()
    
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        let origin = CGPointMake(10, 10)
        let size = CGSizeMake(150, 150)
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

        if fftcounter % 3 == 0 {

            let bandwidth = self.bandwidth()
            let diff = CGFloat(bandwidth.left - bandwidth.right)

            if diff == 0 {
                return
            }
            let amplifiedDiff = max((diff * 10) + 150, 0)


            dispatch_async(dispatch_get_main_queue()) {
                self.graphSquare?.frame.size = CGSizeMake(amplifiedDiff, amplifiedDiff)
            }
            
            gestureRecognizer.update(bandwidth)
        }

        fftcounter++
    }
}

extension ViewController: GestureRecognizerDelegate {
    func updatedPossibleGestures(withGestureRecognizer gestureRecognizer: GestureRecognizer, withPrimaryCandidate primaryCandidate: Gesture) {

        let noop = { return }

        print(primaryCandidate)

        switch primaryCandidate {
        case .Spike:
            spikeCheckbox.isChecked ? launchNextAvailableApplication(currIndex) : noop()
            return
        case .Drop:
            if !dropCheckbox.isChecked {
                return
            }
            let src = CGEventSourceCreate(CGEventSourceStateID.HIDSystemState)
//            let f4d = CGEventCreateKeyboardEvent(src, 0x76, true)
//            let f4u = CGEventCreateKeyboardEvent(src, 0x76, false)
//            
//            CGEventSetFlags(f4d, CGEventFlags.MaskCommand)
//            CGEventSetFlags(f4u, CGEventFlags.MaskCommand)
            
            let cmdd = CGEventCreateKeyboardEvent(src, 0x38, true)
            let cmdu = CGEventCreateKeyboardEvent(src, 0x38, false)
            let ld = CGEventCreateKeyboardEvent(src, 0x25, true)
            let lu = CGEventCreateKeyboardEvent(src, 0x25, false)
//
            let loc = CGEventTapLocation.CGHIDEventTap
//
////            CGEventPost(loc, f4d)
////            CGEventPost(loc, f4u)
//            
            
            CGEventSetFlags(ld, CGEventFlags.MaskCommand)
            CGEventSetFlags(lu, CGEventFlags.MaskCommand)
            CGEventPost(loc, cmdd)
            CGEventPost(loc, ld)
            CGEventPost(loc, lu)
            CGEventPost(loc, cmdu)
//
//            let f3d = CGEventCreateKeyboardEvent(src, 0x63, true)
//            let f3u = CGEventCreateKeyboardEvent(src, 0x63, false)
            

//            
//            CGEventPost(loc, f3d)
//            CGEventPost(loc, f3u)

            
//            workspace.launchApplication("Terminal.app")
        default:
            print("Default")
        }
    }
}

extension ViewController {
    
    func launchMultitask() {
        let src = CGEventSourceCreate(CGEventSourceStateID.HIDSystemState)
        
        let cmdd = CGEventCreateKeyboardEvent(src, 0x38, true)
        let cmdu = CGEventCreateKeyboardEvent(src, 0x38, false)
        let tabd = CGEventCreateKeyboardEvent(src, 0x30, true)
        let tabu = CGEventCreateKeyboardEvent(src, 0x30, false)
        let lefd = CGEventCreateKeyboardEvent(src, 0x7B, true)
        let lefu = CGEventCreateKeyboardEvent(src, 0x7B, false)
        let rigd = CGEventCreateKeyboardEvent(src, 0x7C, true)
        let rigu = CGEventCreateKeyboardEvent(src, 0x7C, false)
        CGEventSetFlags(tabd, CGEventFlags.MaskCommand)
        CGEventSetFlags(tabu, CGEventFlags.MaskCommand)
        let loc = CGEventTapLocation.CGHIDEventTap
        CGEventPost(loc, cmdd)
        CGEventPost(loc, tabd)
        CGEventPost(loc, tabu)
        
        // check for swipe
        
    }
    
    func launchNextAvailableApplication(index: Int) {
        
        // base case
        //        print(index, workspace.runningApplications.count)
        if index < workspace.runningApplications.count {
            let url = workspace.runningApplications[index].bundleURL
            let pathComponents = url?.pathComponents
            
            if pathComponents?.count == 3 {
                
                print(pathComponents)
                
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


    func bandwidth() -> Bandwidth {

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

extension NSButton {
    var isChecked: Bool {
        return self.state == NSOnState
    }
}