//
//  ViewController.swift
//  RxAudioEffectIndicator
//
//  Created by Roman Tutubalin on 21.02.18.
//  Copyright © 2018 Roman Tutubalin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let indicator = RxAudioEffectIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        indicator.linesColor = UIColor.red.withAlphaComponent(0.7)
        indicator.overlayColor = UIColor.red.withAlphaComponent(0.1)
        
        indicator.inProgress.onNext(true)
        
        view.addSubview(indicator)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        indicator.frame = CGRect(origin: .zero, size: view.frame.size)
    }

}

