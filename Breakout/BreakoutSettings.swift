//
//  BreakoutSettings.swift
//  Breakout
//
//  Created by admin on 6/7/15.
//  Copyright (c) 2015 appsincaps. All rights reserved.
//

import Foundation
import UIKit

class BreakoutSettings {
    
    private struct Identifiers {
        static let NumberOfBricksInRow = "Number of bricks in row"
        static let NumberOfRows = "Number of rows"
        static let RowHeight = "Row height"
        static let PaddleWidth = "Paddle width"
        static let PaddleHeight = "Paddle height"
        static let PaddleGravity = "Paddle gravity"
        static let BallSize = "Ball size"
    }
    private static var Defaults = NSUserDefaults.standardUserDefaults()
    static var updateStatus = true
    static var specialBricks = true
    
    // BRICKS
    static var numberOfBricksInRow: Int = 5 {
        didSet {
            Defaults.setObject(numberOfBricksInRow, forKey: Identifiers.NumberOfBricksInRow)
        }
    }
    static var numberOfRows: Int = 1 {
        didSet {
            Defaults.setObject(numberOfRows, forKey: Identifiers.NumberOfRows)
        }
    }
    static var rowHeight: CGFloat = 30 {
        didSet {
            Defaults.setObject(rowHeight, forKey: Identifiers.RowHeight)
        }
    }
    static var brickGap: CGFloat = 4
    
    // PADDLE
    static var paddleWidth: CGFloat = 60 {
        didSet {
            Defaults.setObject(paddleWidth, forKey: Identifiers.PaddleWidth)
        }
    }
    static var paddleHeight: CGFloat = 20 {
        didSet {
            Defaults.setObject(paddleHeight, forKey: Identifiers.PaddleHeight)
        }
    }
    
    static var paddleGravity: Bool = true {
        didSet {
            Defaults.setObject(paddleGravity, forKey: Identifiers.PaddleGravity)
        }
    }
    
    // BALL
    static var ballSize: CGFloat = 20 {
        didSet {
            Defaults.setObject(ballSize, forKey: Identifiers.BallSize)
        }
    }
    static var numberOfBalls: Int = 3
    
    // CLASS FUNCTIONS
    class func Initialize() {
        if let value = Defaults.objectForKey(Identifiers.NumberOfBricksInRow) as? Int {
            numberOfBricksInRow = value
        }
        if let value = Defaults.objectForKey(Identifiers.NumberOfRows) as? Int {
            numberOfRows = value
        }
        if let value = Defaults.objectForKey(Identifiers.RowHeight) as? CGFloat {
            rowHeight = value
        }
        if let value = Defaults.objectForKey(Identifiers.PaddleWidth) as? CGFloat {
            paddleWidth = value
        }
        if let value = Defaults.objectForKey(Identifiers.PaddleHeight) as? CGFloat {
            paddleHeight = value
        }
        if let value = Defaults.objectForKey(Identifiers.BallSize) as? CGFloat {
            ballSize = value
        }
    }
}
