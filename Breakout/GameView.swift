//
//  GameView.swift
//  Breakout
//
//  Created by admin on 6/8/15.
//  Copyright (c) 2015 appsincaps. All rights reserved.
//

import UIKit

class GameView: UIView {
    
    private var paths = [Int: UIBezierPath]()
    private var fills = [Int: UIBezierPath]()
    
    func addPath(path: UIBezierPath, withId identifier: Int) {
        paths[identifier] = path
        setNeedsDisplay()
    }
    
    func addFill(path: UIBezierPath, withId identifier: Int) {
        fills[identifier] = path
        setNeedsDisplay()
    }
    
    func removePath(identifier: Int) {
        paths[identifier] = nil
    }

    override func drawRect(rect: CGRect) {
        for (_, path) in paths {
            path.stroke()
        }
        for (_, path) in fills {
            path.fill()
        }
    }
}

