//
//  ContainerController.swift
//  Anton_Duda_SimplePins
//
//  Created by Anton on 2/24/18.
//  Copyright © 2018 Anton Duda. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    
    var currentVC: UIViewController?
    
    func addChild(_ vc: UIViewController) {
        guard let oldVC = currentVC else {
            currentVC = vc
            view.addSubview(vc.view)
            addChildViewController(vc)
            
            vc.didMove(toParentViewController: self)
            return
        }
    
        oldVC.willMove(toParentViewController: nil)
        
        currentVC = vc
        view.addSubview(vc.view)
        addChildViewController(vc)
      
        transition(from: oldVC,
                   to: vc,
                   duration: 0.5,
                   options: .transitionFlipFromLeft,
                   animations: nil)
        { _ in
            
            oldVC.removeFromParentViewController()
            oldVC.view.removeFromSuperview()
            
            vc.didMove(toParentViewController: self)
        }
    }
}
