//
//  GraphSquare.swift
//  DopplMotion
//
//  Created by Dan Appel on 9/19/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import Cocoa

class GraphSquare: NSView {
    override func drawRect(dirtyRect: NSRect) {

        NSColor.greenColor().setFill()
        NSRectFill(self.bounds)
    }

    var originalFrame: CGRect?
}
