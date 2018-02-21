//
//  RxAudioEffectIndicator.swift
//  RxAudioEffectIndicator
//
//  Created by Roman Tutubalin on 21.02.18.
//  Copyright © 2018 Roman Tutubalin. All rights reserved.
//

import RxSwift

class RxAudioEffectIndicator: UIView {
    let inProgress = BehaviorSubject<Bool>(value: false)
    
    var overlayColor: UIColor = UIColor.white.withAlphaComponent(0.9) {
        didSet {
            self.backgroundColor = self.overlayColor
        }
    }
    
    var linesColor: UIColor = .black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private let lines: [RxAudioEffectIndicatorLine] = [
        RxAudioEffectIndicatorLine(beginHeight: 10, endHeight: 50, animationOptions: nil),
        RxAudioEffectIndicatorLine(beginHeight: 20, endHeight: 65, animationOptions: nil),
        RxAudioEffectIndicatorLine(beginHeight: 10, endHeight: 50, animationOptions: kCAMediaTimingFunctionEaseInEaseOut),
        RxAudioEffectIndicatorLine(beginHeight: 20, endHeight: 65, animationOptions: kCAMediaTimingFunctionEaseIn),
        RxAudioEffectIndicatorLine(beginHeight: 10, endHeight: 50, animationOptions: kCAMediaTimingFunctionEaseInEaseOut),
        RxAudioEffectIndicatorLine(beginHeight: 20, endHeight: 65, animationOptions: nil)
    ]
    
    private var lineShapes: [CAShapeLayer] = []
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        bind()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if frame.size == .zero {
            frame.size = CGSize(width: 1, height: 1)
        }
    }
    
    override func draw(_ rect: CGRect) {
        let indicatorSize = CGSize(width: 75, height: 65)
        let indicatorRect = CGRect(origin: CGPoint(x: rect.midX - indicatorSize.width / 2, y: rect.midY - indicatorSize.height / 2), size: indicatorSize)
        
        for index in 0..<lineShapes.count {
            let line = lines[index]
            let lineShape = lineShapes[index]
            
            lineShape.lineWidth = 2
            lineShape.masksToBounds = false
            lineShape.strokeColor = linesColor.cgColor
            
            let animation = animationBy(index: index, rect: indicatorRect, line: line)
            lineShape.add(animation, forKey: "PathAnimation")
        }
    }
    
    private func setupViews() {
        backgroundColor = overlayColor
        
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    private func bind() {
        inProgress
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] active in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: { [weak self] in self?.alpha = active ? 1.0 : 0.0 },
                    completion: { [unowned self] _ in
                        if active {
                            self.lineShapes = self.lines.map { _ in CAShapeLayer() }
                            self.lineShapes.forEach(self.layer.addSublayer)
                            self.setNeedsDisplay()
                        } else {
                            self.lineShapes.forEach {
                                $0.removeAllAnimations()
                                $0.removeFromSuperlayer()
                            }
                            self.lineShapes.removeAll()
                        }
                    }
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func animationBy(index: Int, rect: CGRect, line: RxAudioEffectIndicatorLine) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.isRemovedOnCompletion = false
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.duration = 0.5
        animation.fromValue = beginPath(index: index, rect: rect, line: line)
        animation.toValue = endPath(index: index, rect: rect, line: line)
        animation.beginTime = CACurrentMediaTime() + 0.1 * Double(index)
        if let function = line.animationOptions {
            animation.timingFunction = CAMediaTimingFunction(name: function)
        }
        return animation
    }
    
    private func beginPath(index: Int, rect: CGRect, line: RxAudioEffectIndicatorLine) -> CGPath {
        let offset = offsetBy(index: index)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + offset, y: rect.maxY - line.beginHeight))
        
        return path.cgPath
    }
    
    private func endPath(index: Int, rect: CGRect, line: RxAudioEffectIndicatorLine) -> CGPath {
        let offset = offsetBy(index: index)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX + offset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + offset, y: rect.maxY - line.endHeight))
        
        return path.cgPath
    }
    
    private func offsetBy(index: Int) -> CGFloat {
        return CGFloat(index) * 15.0
    }
}

struct RxAudioEffectIndicatorLine {
    let beginHeight: CGFloat
    let endHeight: CGFloat
    let animationOptions: String?
}
