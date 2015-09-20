# DopplMotion

## Inspiration
We saw a fascinating [paper](http://research.microsoft.com/en-us/um/redmond/groups/cue/publications/GuptaSoundWaveCHI2012.pdf) which explains how it is possible to detect movement using the doppler effect by playing a constant frequency, observing it, and searching for changes in frequency that are caused by movement.

## What it does
DopplMotion implements the ideas mentioned in the paper above, allowing the user to perform basic gestures such as _spike_ and _drop_. For example, if the user were to _spike_, or throw their hand off the keyboard quickly, DopplMotion registers it and automatically performs the `cmd+tab` action (switching to the next window). Likewise, the _drop_ action launches the launchpad application. As the cliche often goes, the possibilities are _endless_.

## How we built it
DopplMotion was build on Swift 2 using Cocoa and EZAudio, along with a **lot** of research (believe it or not, phsyics is pretty hard!).

## Challenges we ran into
There were challenges on every step of the way for us. Perhaps the biggest one was implementing the gesture recognition technology - how do you differentiate between a _tap_ and a _spike_, when they both go in the same direction at same (initial) velocities? Not easily, we can tell you that much. We also wandered into badly-documented lands with Swift, mostly with interfacing between C and Objective-C++ through Swift.

## Accomplishments that we're proud of
We're really excited that we can track basic and movements through just audio input and output - it still baffles us that its possible in the first place. We're also really proud that we managed to finish so much in such a short amount of time. Pretty sure it took the creators of leap motion more than 36 hours to create their inital mvp ;).

## What we learned
We definitely learned more than we expected, for sure. When we began working on the hack, we thought it would be fairly trivial to follow the paper (linked earlier) step by step. However, implementing it turned out to be a much greater challenge than we expected. Even with reference implementations (in Javascript), there were many difficulties that we did not anticipate.
