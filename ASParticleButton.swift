//
//  ASParticleButton.swift
//  ForFun
//
//  Created by Artem Shevchenko on 29.01.18.
//  Copyright © 2018 artem. All rights reserved.
//

import UIKit

class ASParticleButton: UIButton {

    var shadowView: UIView!
    
    var shadowWidthPercentage: CGFloat = 0.9
    var shadowHeightPercentage: CGFloat = 0.9
    
    var shadowRadius: CGFloat = 8
    var shadowOffset: CGSize = CGSize(width: 0, height: 6)
    
    var isParticlesEnabled: Bool = true
    
    override func draw(_ rect: CGRect) {
        setCorner()
        addShadow()
    }
    
    func setCorner(corner: CGFloat = 8) {
        layer.cornerRadius = corner
        layer.masksToBounds = true
    }
    
    private func addShadow() {
        shadowView = UIView()
        shadowView.backgroundColor = .clear
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        superview?.insertSubview(shadowView, belowSubview: self)
        
        shadowView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        shadowView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        let percentageWidth = bounds.width * shadowWidthPercentage
        let percentageHeight = bounds.height * shadowHeightPercentage
        let newBound = CGRect(x: (bounds.width - percentageWidth) / 2, y: (bounds.height - percentageHeight) / 2, width: percentageWidth, height: percentageHeight)
        
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: newBound, cornerRadius: layer.cornerRadius).cgPath
        shadowView.layer.shadowColor = backgroundColor?.cgColor
        shadowView.layer.shadowOffset = shadowOffset
        shadowView.layer.shadowRadius = shadowRadius
        shadowView.layer.shadowOpacity = 1.0
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let transformAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = transform
        transformAnimation.toValue = CGAffineTransform(scaleX: 0.95, y: 0.95).concatenating(CGAffineTransform(translationX: 0, y: self.bounds.height * 0.1))
        transformAnimation.duration = 0.15
        transformAnimation.fillMode = kCAFillModeForwards
        transformAnimation.isRemovedOnCompletion = false
        layer.add(transformAnimation, forKey: nil)
        
        let shadowOffsetAnimation: CABasicAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shadowOffsetAnimation.fromValue = shadowView.layer.shadowOffset
        shadowOffsetAnimation.toValue = CGSize(width: shadowOffset.width / 2, height: shadowOffset.height / 2)
        shadowOffsetAnimation.duration = 0.15
        shadowOffsetAnimation.fillMode = kCAFillModeForwards
        shadowOffsetAnimation.isRemovedOnCompletion = false
        shadowView.layer.add(shadowOffsetAnimation, forKey: nil)
        
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95).concatenating(CGAffineTransform(translationX: 0, y: self.bounds.height * 0.1))
        self.shadowView.layer.shadowOffset = CGSize(width: shadowOffset.width / 2, height: shadowOffset.height / 2)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        
        let transformAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = transform
        transformAnimation.toValue = CGAffineTransform(scaleX: 1.0, y: 1.0)
        transformAnimation.duration = 0.3
        transformAnimation.fillMode = kCAFillModeForwards
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        layer.add(transformAnimation, forKey: nil)
        
        let shadowOffsetAnimation: CABasicAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shadowOffsetAnimation.fromValue = shadowView.layer.shadowOffset
        shadowOffsetAnimation.toValue = shadowOffset
        shadowOffsetAnimation.duration = 0.3
        shadowOffsetAnimation.fillMode = kCAFillModeForwards
        shadowOffsetAnimation.isRemovedOnCompletion = false
        shadowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shadowView.layer.add(shadowOffsetAnimation, forKey: nil)
        
        self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.shadowView.layer.shadowOffset = shadowOffset
        
        if isParticlesEnabled {
            createParticles()
        }
    }
    
    func createParticles() {
        if let superview = superview {
            for _ in 1...25 {
                let randSize = Int.random(min: 3, max: 8)
                
                let cell = UIView(frame: CGRect(x: 0, y: 0, width: randSize, height: randSize))
                cell.translatesAutoresizingMaskIntoConstraints = false
                cell.backgroundColor = backgroundColor?.withAlphaComponent(CGFloat(Double.random(min: 0.6, max: 1.0)))
                cell.layer.cornerRadius = CGFloat(Double(randSize) / 2.0)
                
                if Int.random(min: 0, max: 1) == 0 {
                    cell.layer.borderColor = backgroundColor?.cgColor
                    cell.layer.borderWidth = CGFloat(Double.random(min: 0.3, max: 1.5))
                    cell.backgroundColor = .clear
                }
                
                superview.insertSubview(cell, belowSubview: shadowView)
                
                var cellCenter = center
                cellCenter.x += CGFloat(Double.random(min: -5, max: 5))
                cellCenter.y += CGFloat(Double.random(min: -5, max: 5))
                cell.center = cellCenter
                
                UIView.animate(withDuration: Double.random(min: 0.4, max: 2.5), delay: 0.0, options: [.curveEaseOut], animations: {
                    cell.center = self.moveRandomly(point: cellCenter, maximumRandom: 0.8)
                    cell.alpha = 0.0
                }, completion: { (finished) in
                    cell.removeFromSuperview()
                })
            }
        }
    }
    
    private func moveRandomly(point: CGPoint, maximumRandom maxRand: Double = 1.0) -> CGPoint {
        var point = point
        let randDx = Double.random(min: -maxRand, max: maxRand)
        let randDy = Double.random(min: -maxRand, max: maxRand) / Double.random(min: 1, max: 3)
        let vector = CGVector(dx: randDx, dy: randDy)
        point.x = point.x + point.x * vector.dx
        point.y = point.y + point.y * vector.dy
        return point
    }

}
