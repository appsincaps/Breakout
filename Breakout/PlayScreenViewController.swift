//
//  PlayScreenViewController.swift
//  Breakout
//
//  Created by admin on 6/6/15.
//  Copyright (c) 2015 appsincaps. All rights reserved.
//

import UIKit
import AVFoundation

class PlayScreenViewController: UIViewController, UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate {
    
    struct Identifiers {
        static let PaddleBoundary = -1
        static let TopBoundary = -2
        static let RightBoundary = -3
        static let BottomBoundary = -4
        static let LeftBoundary = -5
        static let BallBoundary = -100
    }
    
    lazy var animator: UIDynamicAnimator = {
        var lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    let behavior = BreakoutBehavior()
    var savedStartButton: UIButton?

    @IBOutlet weak var gameView: GameView!
    @IBAction func startButton(sender: UIButton) {
        savedStartButton = sender
        sender.hidden = true
        behavior.shootItem(ballView!, withVelocity: CGPoint(x: 0, y: 400))
    }
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var ballsLabel: UILabel!
    
    @IBAction func tapGesture(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            behavior.pushItem(ballView!)
        default: break
        }
    }
    
    private lazy var alert: UIAlertController = { [unowned self] in
        let lazyAlert = UIAlertController(
            title: "GAME OVER",
            message: "Your score is \(self.score)",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        lazyAlert.addAction(UIAlertAction(
            title: "Restart",
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                self.restart()
            })
        lazyAlert.modalPresentationStyle = .Popover
        
        return lazyAlert
    }()
    
    @IBAction func movePaddleGesture(gesture: UIPanGestureRecognizer) {
        if !BreakoutSettings.paddleGravity {
            switch gesture.state {
            case .Ended: fallthrough
            case .Changed:
                let translation = gesture.translationInView(gameView)
                let positionChange = translation.x
                if positionChange != 0 {
                    paddleView?.frame.offset(dx: positionChange, dy: 0)
                    behavior.addBoundary(Identifiers.PaddleBoundary, withPath: UIBezierPath(ovalInRect: paddleView!.frame))
                    gesture.setTranslation(CGPointZero, inView: gameView)
                }
            default: break
            }
        }
    }
    
    var paddleView: UIView?
    var ballView: UIView?
    
    private enum GameObjectType: Printable {
        case Brick
        case Paddle
        case Ball
        
        var description: String {
            switch self {
            case .Brick: return "Brick"
            case .Paddle: return "Paddle"
            case .Ball: return "Ball"
            default: return ""
            }
        }
    }
    
    private class GameObject {
        var view: UIView?
        var path: UIBezierPath?
        var color: Int?
        var descriptor: GameObjectType?
    }
    
    private var bricks = [Int: GameObject]()
    
    private var brickCount: Int {
        return bricks.count
    }
    
    // MARK: Labels
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    private var remainingBalls = BreakoutSettings.numberOfBalls {
        didSet {
            ballsLabel.text = createLabel(remainingBalls)
        }
    }
    
    func createLabel(var number: Int) -> String {
        let character = "⚈"
        var string = ""
        while number > 0 {
            string += character
            number -= 1
        }
        return string
    }
    
    private func updateBallsLabel() {
        if remainingBalls == 0 {
            remainingBalls = BreakoutSettings.numberOfBalls
            popAlert()
        } else {
            remainingBalls -= 1
        }
    }
    
    // MARK: Bricks functionality
    
    private var maxId: Int {
        return BreakoutSettings.numberOfBricksInRow * BreakoutSettings.numberOfRows
    }
    
    private var gridLength: CGFloat {
        return gameView.bounds.width / CGFloat(BreakoutSettings.numberOfBricksInRow)
    }
    
    private var gridHeight: CGFloat {
        return BreakoutSettings.rowHeight
    }
    
    private var brickSize: CGSize {
        let width = gridLength - BreakoutSettings.brickGap
        let height = gridHeight - BreakoutSettings.brickGap
        return CGSize(width: width, height: height)
    }
    
    private func createBrickAt(point: CGPoint?) -> GameObject {
        let frame = CGRect(origin: point!, size: brickSize)
        let brickView = UIView(frame: frame)
        let factor = colorArray.count - 1
        let colorId = Int(arc4random()%UInt32(factor))
        brickView.backgroundColor = colorArray[colorId]
        brickView.layer.cornerRadius = frame.height / 10
        brickView.layer.shadowOpacity = 0.35
        brickView.layer.shadowOffset = CGSize(width: 0, height: 0)
        var brick = GameObject()
        brick.view = brickView
        brick.path = UIBezierPath(rect: frame)
        brick.color = colorId
        return brick
    }
    
    func createBrickRows() {
        let numberOfRows = BreakoutSettings.numberOfRows
        let numberOfBricks = BreakoutSettings.numberOfBricksInRow
        let offset = BreakoutSettings.brickGap / 2
        
        for row in 0..<numberOfRows {
            for col in 0..<numberOfBricks {
                let point = CGPoint(x: offset + gridLength * CGFloat(col), y: offset + gridHeight * CGFloat(row))
                let brick = createBrickAt(point)
                bricks[row * numberOfBricks + col] = brick
            }
        }
    }
    
    private func updateBrickRows() {
        
        let numberOfRows = BreakoutSettings.numberOfRows
        let numberOfBricks = BreakoutSettings.numberOfBricksInRow
        let offset = BreakoutSettings.brickGap / 2
        let size = brickSize
        
        for (id, brick) in bricks {
            let col = id % numberOfBricks
            let row = (id - col) / numberOfBricks
            let point = CGPoint(x: offset + gridLength * CGFloat(col), y: offset + gridHeight * CGFloat(row))
            brick.view!.frame = CGRect(origin: point, size: size)
            behavior.addBoundary(id, withPath: brick.path!)
        }
    }
    
    private func showAllBricks() {
        for (id, brick) in bricks {
            gameView?.addSubview(brick.view!)
            behavior.addBoundary(id, withPath: brick.path!)
        }
    }
    
    private func drawBricks() {
        if BreakoutSettings.updateStatus {
            removeAllBricks()
            BreakoutSettings.updateStatus = false
        }
        if bricks.isEmpty {
            createBrickRows()
            showAllBricks()
        } else {
            updateBrickRows()
        }
    }
    
    private func removeAllBricks() {
        for (id, brick) in bricks {
            killBrick(id)
        }
    }
    
    private func killBrick(id: Int) {
        if let brick = bricks[id] {
            brick.view!.removeFromSuperview()
            behavior.removeBoundary(id)
        }
        bricks[id] = nil
    }
    
    private func playBrick(id: Int) {
        if let brick = bricks[id] {
            if let color = brick.color {
                if color == colorArray.count - 1 {
                    removeBrick(id)
                } else {
                    solidBrickSound.play()
                    brick.color = color + 1
                    updateBrickColor(id)
                } 
            }
        }
    }
    
    private func updateBrickColor(id: Int) {
        if let brick = bricks[id] {
            UIView.animateWithDuration(1.0, animations: {
                brick.view!.backgroundColor = colorArray[brick.color!]
            })
        }
    }
    
    private func removeBrick(id: Int) {
        brokenBrickSound.play()
        if let brick = bricks[id] {
            animateBrick(brick.view!)
            behavior.removeBoundary(id)
        }
        bricks[id] = nil
        if brickCount == 0 {
            endSound.play()
            popAlert()
        }
    }
    
    private func animateBrick(view: UIView) {
        UIView.transitionWithView(view,
            duration: 1.0,
            options: UIViewAnimationOptions.TransitionFlipFromBottom,
            animations: {
                self.behavior.addFallingBrick(view)
            },
            completion: nil)
    }
    
    // MARK: Paddle functionality
    
    private var paddleWidth: CGFloat {
        return BreakoutSettings.paddleWidth
    }
    
    private var paddleHeight: CGFloat {
        return BreakoutSettings.paddleHeight
    }
    
    func drawPaddle() {
        let size = CGSize(width: paddleWidth, height: paddleHeight)
        let point = CGPoint(x: (gameView.bounds.width - size.width) / 2,
            y: gameView.bounds.height - size.height - 1)
        let frame = CGRect(origin: point, size: size)
        if paddleView == nil {
            paddleView = UIView(frame: frame)
            paddleView!.layer.cornerRadius = size.height / 2
            paddleView!.backgroundColor = UIColor.grayColor()
            gameView.addSubview(paddleView!)
            //behavior.addRealItem(paddleView!)
        } else {
            paddleView!.frame = frame
            paddleView!.layer.cornerRadius = size.height / 2
            //animator.updateItemUsingCurrentState(paddleView!)
        }
        behavior.addBoundary(Identifiers.PaddleBoundary, withPath: UIBezierPath(ovalInRect: frame))
    }
    
    // MARK: Ball functionality
    
    private var ballSize: CGFloat {
        return BreakoutSettings.ballSize
    }
    
    private func drawBall() {
        let size = ballSize
        let point = CGPoint(x: (gameView.bounds.width - size) / 2,
            y: gameView.bounds.height - size - paddleHeight - 50)
        let frame = CGRect(origin: point, size: CGSize(width: size, height: size))
        if ballView == nil {
            ballView = UIView(frame: frame)
            ballView!.backgroundColor = UIColor.blackColor()
            ballView!.layer.cornerRadius = size / 2
            behavior.addDynamicItem(ballView!)
        } else {
            ballView!.frame = frame
            ballView!.layer.cornerRadius = size / 2
            animator.updateItemUsingCurrentState(ballView!)
        }
    }
    
    private func removeBall() {
        if ballView != nil {
            behavior.removeDynamicItem(ballView!)
            ballView = nil
        }
    }
    
    // MARK: Setting up views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BreakoutSettings.Initialize()
        animator.addBehavior(behavior)
        behavior.setCollisionDelegate(self)
        remainingBalls = BreakoutSettings.numberOfBalls
        solidBrickSound.prepareToPlay()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !collision {
            setCage()
            setBoundary()
            drawBricks()
            drawPaddle()
            drawBall()
        }
    }
    
    var samples = [CGFloat]()
    let numberOfSamples = 30
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let motionManager = AppDelegate.Motion.Manager
        if motionManager.accelerometerAvailable {
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue()) { [unowned self] (data, error) -> Void in
                
                func average(sample: CGFloat) -> CGFloat { // helper function
                    if self.samples.count < self.numberOfSamples {
                        self.samples.append(sample)
                    } else {
                        self.samples.removeAtIndex(0)
                        self.samples.append(sample)
                    }
                    return self.samples.reduce(0) { (sum: CGFloat, elem: CGFloat) -> CGFloat in
                        return sum + elem
                    } / CGFloat(self.samples.count)
                }
                
                if self.paddleView != nil && BreakoutSettings.paddleGravity {
                    let scale = self.gameView!.bounds.width
                    self.paddleView!.center.x = scale/2 * (1 + 2 * average(CGFloat(data.acceleration.x)))
                    self.behavior.addBoundary(Identifiers.PaddleBoundary, withPath: UIBezierPath(ovalInRect: self.paddleView!.frame))
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
    }
    
    private func setBoundary() {
        behavior.addBoundary(Identifiers.LeftBoundary,
            withPath: UIBezierPath(rect: CGRect(origin: CGPointZero,
                size: CGSize(width: 1, height: gameView.bounds.height))))
        behavior.addBoundary(Identifiers.TopBoundary,
            withPath: UIBezierPath(rect: CGRect(origin: CGPointZero,
                size: CGSize(width: gameView.bounds.width, height: 1))))
        behavior.addBoundary(Identifiers.RightBoundary,
            withPath: UIBezierPath(rect: CGRect(origin: CGPoint(x: gameView.bounds.width - 1, y: 0),
                size: CGSize(width: 1, height: gameView.bounds.height))))
        behavior.addBoundary(Identifiers.BottomBoundary,
            withPath: UIBezierPath(rect: CGRect(origin: CGPoint(x: 0, y: gameView.bounds.height - 1),
                size: CGSize(width: gameView.bounds.width, height: 10))))
    }
    
    private func setCage() {
        let size = CGSize(width: gameView.bounds.width + paddleWidth, height: paddleHeight + 2)
        let point = CGPoint(x: -paddleWidth / 2, y: gameView.bounds.height - size.height)
        let frame = CGRect(origin: point, size: size)
        let path = UIBezierPath(rect: frame)
        behavior.setupCage(path)
    }
    
    private func restart() {
        createBrickRows()
        showAllBricks()
        drawPaddle()
        drawBall()
        remainingBalls = BreakoutSettings.numberOfBalls
        score = 0
        savedStartButton?.hidden = false
    }
    
    private func resume() {
        drawBall()
        behavior.stopItem(ballView!)
        animator.updateItemUsingCurrentState(ballView!)
    }
    
    private func popAlert() {
        removeBall()
        alert.message = "Your score is \(self.score)"
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Dynamic behaviors
    
    var collision = false
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying) {
        if let id = identifier as? Int {
            switch id {
            case Identifiers.LeftBoundary, Identifiers.RightBoundary, Identifiers.TopBoundary:
                wallSound.play()
            case Identifiers.BottomBoundary:
                collision = false
                updateBallsLabel()
                savedStartButton?.hidden = false
                resume()
            case 0...maxId:
                collision = true
                score += 1
                if BreakoutSettings.specialBricks {
                    playBrick(id)
                } else {
                    removeBrick(id)
                }
            default:
                collision = false
            }
        }
    }
    
    // MARK: - Sound behaviors
    
    lazy var solidBrickSound: AVAudioPlayer = { [unowned self] in
        let lazySound: AVAudioPlayer = self.setupAudioPlayerWithFile("impact_glass_window_thin_001", type: "mp3")
        return lazySound
    }()
    
    lazy var brokenBrickSound: AVAudioPlayer = { [unowned self] in
        let lazySound: AVAudioPlayer = self.setupAudioPlayerWithFile("impact_glass_window_smash_001", type: "mp3")
        return lazySound
        }()
    
    lazy var wallSound: AVAudioPlayer = { [unowned self] in
        let lazySound: AVAudioPlayer = self.setupAudioPlayerWithFile("impact_glass_window_thin_002", type: "mp3")
        return lazySound
        }()
    
    lazy var endSound: AVAudioPlayer = { [unowned self] in
        let lazySound: AVAudioPlayer = self.setupAudioPlayerWithFile("ooweee", type: "mp3")
        return lazySound
        }()
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        var error: NSError?
        return AVAudioPlayer(contentsOfURL: url, error: &error)
    }
}

private let colorArray = [
    UIColor.greenColor(),
    UIColor.blueColor(),
    UIColor.orangeColor(),
    UIColor.redColor(),
    UIColor.yellowColor(),
    UIColor.grayColor()]

private extension UIColor {
    class var random: UIColor {
        return colorArray[Int(arc4random()%5)]
    }
}

