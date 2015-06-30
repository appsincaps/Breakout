//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by admin on 6/7/15.
//  Copyright (c) 2015 appsincaps. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    struct Identifiers {
        static let PaddleBoundary = -1
    }
    
    lazy var collider: UICollisionBehavior = {
        var lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = false
        return lazyCollider
    }()
    
    lazy var cage: UICollisionBehavior = {
        var lazyCage = UICollisionBehavior()
        lazyCage.translatesReferenceBoundsIntoBoundary = false
        return lazyCage
    }()
    
    lazy var bouncer: UIDynamicItemBehavior = {
        var lazyBouncer = UIDynamicItemBehavior()
        lazyBouncer.elasticity = 1
        lazyBouncer.friction = 0
        lazyBouncer.resistance = 0
        lazyBouncer.allowsRotation = false
        return lazyBouncer
    }()
    
    lazy var fall: UIDynamicItemBehavior = {
        var lazyFall = UIDynamicItemBehavior()
        lazyFall.elasticity = 1
        lazyFall.friction = 0
        lazyFall.resistance = 0
        lazyFall.allowsRotation = true
        lazyFall.action = { [unowned self] in
            for item in lazyFall.items {
                var thing = item as! UIView
                if let view = self.dynamicAnimator?.referenceView {
                    if !CGRectContainsPoint(view.bounds, thing.center) {
                        self.removeFallingBrick(thing)
                    }
                }
            }
        }
        return lazyFall
    }()
    
    lazy var slide: UIDynamicItemBehavior = { // used for animating paddle motion cuased by tilting
        var lazySlide = UIDynamicItemBehavior()
        lazySlide.elasticity = 0.25
        lazySlide.friction = 0
        lazySlide.resistance = 0
        lazySlide.allowsRotation = false
        lazySlide.action = { [unowned self] in
            for item in lazySlide.items {
                self.addBoundary(Identifiers.PaddleBoundary, withPath: UIBezierPath(ovalInRect: item.frame))
            }
        }
        return lazySlide
        }()
        
    var gravity = UIGravityBehavior() // for falling brick
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(bouncer)
        addChildBehavior(fall)
        
        //addChildBehavior(slide)
        //addChildBehavior(gravity)
        //addChildBehavior(cage)
    }
    
    func setCollisionDelegate(delegate: UICollisionBehaviorDelegate) {
        collider.collisionDelegate = delegate
    }
    
    func shootItem(item: UIView, withVelocity velocity: CGPoint) {
        bouncer.addLinearVelocity(velocity, forItem: item)
    }
    
    func stopItem(item: UIView) {
        let velocity = bouncer.linearVelocityForItem(item)
        bouncer.addLinearVelocity(CGPoint(x: -velocity.x, y: -velocity.y), forItem: item)
    }
    
    func pushItem(item: UIView) {
        var push = UIPushBehavior(items: [item], mode: .Instantaneous)!
        push.setAngle(CGFloat(arc4random() % 6), magnitude: 0.05)
        push.action = { [unowned push] in
            push.dynamicAnimator!.removeBehavior(push)
        }
        addChildBehavior(push)
    }
   
    func addDynamicItem(item: UIView) {
        dynamicAnimator?.referenceView?.addSubview(item)
        collider.addItem(item)
        bouncer.addItem(item)
    }
    
    func removeDynamicItem(item: UIView) {
        bouncer.removeItem(item)
        collider.removeItem(item)
        item.removeFromSuperview()
    }
    
    func addBoundary(identifier: NSCopying, withPath path: UIBezierPath) {
        removeBoundary(identifier)
        collider.addBoundaryWithIdentifier(identifier, forPath: path)
    }
    
    func removeBoundary(identifier: NSCopying) {
        collider.removeBoundaryWithIdentifier(identifier)
    }
    
    func addFallingBrick(item: UIView) {
        item.layer.opacity = 0.25
        fall.addItem(item)
        let angVelocity = CGFloat(arc4random() % 19) - 9
        let linVelocity = CGFloat(arc4random() % 100) + 200
        fall.addAngularVelocity(angVelocity, forItem: item)
        fall.addLinearVelocity(CGPoint(x: 0, y: linVelocity), forItem: item)
    }
        
    func removeFallingBrick(item: UIView) {
        fall.removeItem(item)
        item.removeFromSuperview()
    }
    
    func addRealItem(item: UIView) {
        cage.addItem(item)
        slide.addItem(item)
        gravity.addItem(item)
    }
    
    func removeRealItem(item: UIView) {
        gravity.removeItem(item)
        cage.removeItem(item)
        slide.removeItem(item)
    }
    
    func setupCage(path: UIBezierPath) {
        cage.addBoundaryWithIdentifier(-100, forPath: path)
    }
}
