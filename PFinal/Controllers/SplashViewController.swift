//
//  SplashViewController.swift
//  PFinal
//
//  Created by Mac20 on 8/07/23.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
            self.performSegue(withIdentifier: "splashsegue", sender: nil)
        }
    }

}
