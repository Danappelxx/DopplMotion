# DopplMotion

## Inspiration
We saw a fascinating [paper](http://research.microsoft.com/en-us/um/redmond/groups/cue/publications/GuptaSoundWaveCHI2012.pdf) which explained how it was possible to detect movement using only a microphone and speaker. By playing a high pitched sound and listening to its echos, we can use the changes in frequency (caused by the Doppler effect) to detect movement.

## What It Does
By implementing the ideas mentioned above, DopplMotion allows the user to perform basic gestures such as "spike" and "drop." For example, if the user does a "spike: gesture by lifting their hand off the keyboard quickly, DopplMotion will switch to the next application. If the user performs the "drop" gesture and quickly drops their hand onto the keyboard, DopplMotion will open the Launchpad. Because DopplMotion can perform arbitrary commands for any detectable gesture, the possibilities are _endless_.

## How We Built It
DopplMotion was written in Swift 2 using Cocoa and EZAudio, along with a **lot** of research (believe it or not, physics is pretty hard!).

## Challenges We Ran Into
There were challenges for us on every step of the way. Perhaps the biggest one was implementing the actual gesture recognition technology—how do you differentiate between a "tap" and a "drop", when both gestures go in the same direction with the same initial velocities? Not easily, we can tell you. We also had to wander through the badly-documented lands of Swif  because of interfacing issues between Swift, C, and Objective-C++.

## Accomplishments That We're Proud Of
We're really excited that we can track basic movements through just audio input and output—it still baffles us that it's even possible in the first place. We're also really proud that we managed to finish so much in such a short amount of time. We're pretty sure it took the creators of Leap Motion more than 36 hours to create their inital MVP ;).

## What We Learned
We definitely learned more than we expected. When we began working on DopplMotion, we thought it would be trivial to follow the paper and implement it step-by-step. However, like most projects, we ran into many unforseen bugs and challenges. Even with reference implementations, it was difficult to calibrate the program and make it respond correctly to the chaotic real world.
