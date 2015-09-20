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

//    var prevBlock: [Float] = [Float](count: 1024, repeatedValue: 0.0)
    
    var prevBlock: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.alloc(1024)
    let smoothingTimeConstant: Float = 0.5
    
    var microphone: EZMicrophone!
    var player: EZAudioPlayer!
    var fft: EZAudioFFTRolling!

    let workspace = NSWorkspace.sharedWorkspace()
    var currIndex = 0
    
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
        
        self.prevBlock.initializeFrom(Array<Float>(count: 1024, repeatedValue: 0.0))
        
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

    func launchNextAvailableApplication(index: Int) {
        
        // base case
        //        print(index, workspace.runningApplications.count)
        if index < workspace.runningApplications.count {
            let url = workspace.runningApplications[index].bundleURL
            let pathComponents = url?.pathComponents
            
            print(pathComponents)
            
            if pathComponents?.count == 3 {
                //                print(pathComponents![2])
                
                let applicationName = pathComponents![2]
                //                let applicationLength = applicationName.characters.count
                //                print(applicationLength)
                
                let digitIndex = applicationName.endIndex.advancedBy(-4)
                let lastThreeDigits = applicationName.substringFromIndex(digitIndex)
                //                print(lastThreeDigits)
                
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
        
        for var i = 0; i < Int(bufferSize); i++ {
            
            prevBlock.advancedBy(i).memory = (smoothingTimeConstant * prevBlock[i]) + (1 - smoothingTimeConstant) * (fftData.advancedBy(i).memory)
            
        }
        
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

        if fftcounter % 3 == 0 {
            
            let bandwidth = self.bandwidth()
            let diff = CGFloat(bandwidth.left - bandwidth.right)
            
            if bandwidth.left < 4 && bandwidth.right < 4 {
                return
            }
            
            // direction: 
            
            if diff == 0 {
                return
            }
            
            
            if diff < 0 {
                print("right")
                
            } else if diff > 0 {
                print("left")

            }
            
            
            
//            var f_r: Float = 0 // this is the highest amplitude frequency
//            
//            let pilotIndex = self.fft.indexOfFrequency(20000)
//            
//
//            
//            if diff < 0 {
//                print("right \(bandwidth.left) \(bandwidth.right)")
//                
//                var incrementor = 0
//                var arr = [Float]()
//                while incrementor < Int(bufferSize) {
//
//                    arr.append(fftData.advancedBy(incrementor).memory)
//                    print(fftData.advancedBy(incrementor).memory)
//                    incrementor++
//                }
            
////                arr.sort().forEach {
////                    print($0)
////                }
//                
//                
//                var highestAmplitude : Float = 0
//                for (var index = pilotIndex + 1; index <= pilotIndex + bandwidth.right; index++) {
////                    print(fftData.advancedBy(index + 1).memory)
//                    if fftData.advancedBy(index).memory > highestAmplitude {
//                        highestAmplitude = fftData.advancedBy(index).memory
//                        f_r = self.fft.frequencyAtIndex(UInt(index))
//                    }
//                }
//                print(highestAmplitude)
//                
//                //f_r = Float(bandwidth.right) - 20000.0
//            } else {
//                print("left \(bandwidth.left)")
//                
//                var highestAmplitude : Float = 0
//                for (var index = pilotIndex - 1; index >= pilotIndex - bandwidth.left; index--) {
//                    if fftData.advancedBy(index).memory > highestAmplitude {
//                        highestAmplitude = fftData.advancedBy(index).memory
//                        f_r = self.fft.frequencyAtIndex(UInt(index))
//                    }
//                }
//                //f_r = Float(bandwidth.left) - 20000.0
//            }
//            
            let amplifiedDiff = (diff * 10) + 200
//
//            let f_t: Float = 20000 // this is the frequency of the speaker emitted sound
//            
//            let c: Float = 343 //m/s
//            //old formula
//            //let v = ((f_t * c) / f_r) - 343
//            
//            //new formula in paper
//            let x = f_r / f_t
//            let v = c * (x - 1) / (x + 1) * 100
//            
//            print(f_r)
//            print("\(v)\n")
//            
//            if v <= -300 {
//                launchNextAvailableApplication(self.currIndex)
//            }
            
            dispatch_async(dispatch_get_main_queue(), {
                // code here
                self.graphSquare?.frame.size = CGSizeMake(amplifiedDiff, amplifiedDiff)
            })
        }
        
        fftcounter++
        
        
//        print(diff)
    }
    
    func bandwidth() -> (left: Int, right: Int) {
        
        let targetFrequency: Float = 20000
        let targetFrequencyWindow = 33
        
        let primaryTone = Int((targetFrequency / self.fft.getNyquist()) * (2048 / 2))
        let primaryVolume = prevBlock.advancedBy(primaryTone).memory
        
        /// to be determined
        let maxVolumeRatio: Float = 0.001
        
        var leftBandwidth = 0
        var rightBandwidth = 0
        
        var volume: Float = 0, normalizedVolume: Float = 0
        repeat {
            
            leftBandwidth++
            volume = prevBlock.advancedBy(primaryTone - leftBandwidth).memory
            normalizedVolume = volume / primaryVolume
            
        } while normalizedVolume > maxVolumeRatio && leftBandwidth < targetFrequencyWindow
        
        
        volume = 0
        normalizedVolume = 0
        repeat {
            
            rightBandwidth++
            volume = prevBlock.advancedBy(primaryTone + rightBandwidth).memory
            normalizedVolume = volume / primaryVolume
            
        } while normalizedVolume > maxVolumeRatio && rightBandwidth < targetFrequencyWindow
        
        
        return (left: leftBandwidth, right: rightBandwidth)
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
    
    func getNyquist() -> Float {
        return self.sampleRate / 2
    }

    /// Of type "Hamming"
    class func window(index n: Int, numValues N: Int) -> Float {
        return Float( 0.54 - ( 0.46 * cos( (2 * M_PI * Double(n)) / (Double(N) - 1) ) ) )
    }
}
