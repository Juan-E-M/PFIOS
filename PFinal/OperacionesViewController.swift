//
//  OperacionesViewController.swift
//  PFinal
//
//  Created by Mac20 on 24/06/23.
//

import UIKit

class OperacionesViewController: UIViewController {

    @IBAction func btncombustible(_ sender: Any) {
        performSegue(withIdentifier: "fuelSegue", sender: nil)
    }
    @IBAction func btntraslado(_ sender: Any) {
        performSegue(withIdentifier: "moveSegue", sender: nil)
    }
    @IBAction func btnpeaje(_ sender: Any) {
        performSegue(withIdentifier: "tariffSegue", sender: nil)
    }
    @IBAction func btnotros(_ sender: Any) {
        performSegue(withIdentifier: "othersSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
