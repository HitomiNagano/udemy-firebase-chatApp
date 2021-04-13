//
//  LottieLoading.swift
//  ChatApp1
//
//  Created by Hitomi Nagano on 2021/04/13.
//

import Foundation
import Lottie
import UIKit

class LottieLoading {
    // @see https://teratail.com/questions/301168
    var view: AnimationView
    var superView: UIViewController
    
    init() {
        view = AnimationView()
        superView = UIViewController()
    }
    
    func startAnimation() {
        let animation = Animation.named("loading")
        view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/1.5)
        
        view.animation = animation
        view.contentMode = .scaleAspectFit
        view.loopMode = LottieLoopMode.loop
        
        superView.view.addSubview(view)
    }
    
    func stopAnimation() {
        view.removeFromSuperview()
    }
}
